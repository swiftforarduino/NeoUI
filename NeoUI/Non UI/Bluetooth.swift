//
//  Bluetooth.swift
//  NeopixelControl
//
//  Created by Carl Peto on 18/04/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

// from Adafruit
let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
let MaxCharacters = 20

let BLEService_UUID = CBUUID(string: kBLEService_UUID)
let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

class Bluetooth: NSObject {
    static let shared = Bluetooth()

    enum State: Int {
        case undefined = 1
        case disabled
        case disconnected
        case scanning
        case connecting
        case connected
        case discoveredServices
        case gotCharacteristics
        case notifying
    }

    // notifications
    static let bluetoothStateChange = NSNotification.Name(rawValue: "bluetoothStateChange")
    static let bluetoothStateKey = "bluetoothStateKey"
    static let bluetoothUARTRX = NSNotification.Name(rawValue: "bluetoothUARTRX")
    static let bluetoothUARTDataKey = "bluetoothUARTDataKey"

    var shouldReconnect = true {
        didSet {
            if shouldReconnect {
                startReconnectionTimer()
                connect()
            } else {
                stopReconnectionTimer()
            }
        }
    }

    public var state: State = .undefined {
        didSet {
            if state == .disconnected, shouldReconnect {
                startReconnectionTimer()
            } else {
                stopReconnectionTimer()
            }

            NotificationCenter.default.post(
                name: Bluetooth.bluetoothStateChange,
                object: self,
                userInfo: [Bluetooth.bluetoothStateKey:state])
        }
    }

    func start() {
        cbManager.scanForPeripherals(withServices: [BLEService_UUID] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 17) {
            self.cbManager.stopScan()
        }

        state = .scanning
    }

    func stop() {
        cbManager.stopScan()

        if let uartDevice = uartDevice {
            cbManager.cancelPeripheralConnection(uartDevice)
        }
    }

    func send(data: Data) {
        guard let txCharacteristic = txCharacteristic, let uartDevice = uartDevice else {
            print("txCharacteristic or device not yet set, cannot transmit")
            return
        }

        uartDevice.writeValue(data, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }

    func send(string: String) {
        guard let data = string.data(using: .utf8) else {
            print("txCharacteristic or device not yet set, cannot transmit")
            return
        }

        send(data: data)
    }

    /* implementation */
    private lazy var cbQueue = DispatchQueue(label: "cbQueue")
    private lazy var cbManager = CBCentralManager(delegate: self, queue: cbQueue)
    private var uartDevice: CBPeripheral?
    private var reconnectionTimer: Timer?

    private var txCharacteristic : CBCharacteristic? {
        didSet {
            checkCharacteristics()
        }
    }

    private var rxCharacteristic : CBCharacteristic? {
        didSet {
            checkCharacteristics()
        }
    }

    private func checkCharacteristics() {
        if txCharacteristic != nil, rxCharacteristic != nil {
            state = .gotCharacteristics
        }
    }

    private func startReconnectionTimer() {
        DispatchQueue.main.async {
            self.reconnectionTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
                if self?.state == .disconnected {
                    self?.connect()
                }
            }
        }
    }

    private func stopReconnectionTimer() {
        if let reconnectionTimer = reconnectionTimer {
            reconnectionTimer.invalidate()
            self.reconnectionTimer = nil
        }
    }

    private func connect() {
        if let uartDevice = uartDevice {
            if !cbManager.retrieveConnectedPeripherals(withServices: [BLEService_UUID]).contains(uartDevice) {
                cbManager.connect(uartDevice, options: nil)
                state = .connecting
            }
        }
    }


    func disconnect() {
        if let uartDevice = uartDevice {
            if cbManager.retrieveConnectedPeripherals(withServices: [BLEService_UUID]).contains(uartDevice) {
                cbManager.cancelPeripheralConnection(uartDevice)
                state = .connecting
            }
        }
    }
}

// bluetooth should go through the following process...
// after start or bluetooth power on, start scanning for the adafruit bluefruit shield
// when the bluefruit shield CBPeripheral has been discovered, assuming connections are enabled, check if we are already
// ...connected and if not then try to connect it

// after we connect, try to discover the services available on the device, then the characteristics of each of the
// ...services we discover and finally the descriptors of those characteristics.

// as each characteristic is discovered

extension Bluetooth: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("bluetooth state updated \(central.state)")
        if central.state == .poweredOn {
            start()
        } else {
            state = .disabled
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        uartDevice = peripheral
        print("discovered device \(peripheral.name ?? "---") with rssi \(RSSI)")
        if shouldReconnect {
            connect()
        }
    }

    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print("connection event: \(event) for \(peripheral)")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected \(peripheral)")
        state = .disconnected
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        cbManager.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([BLEService_UUID])
        rxCharacteristic = nil
        txCharacteristic = nil
        state = .connected
    }
}

extension Bluetooth: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }

        guard let services = peripheral.services else {
            print("no services")
            return
        }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }

        print("Discovered Services: \(services)")
        state = .discoveredServices
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else {
            print("no characteristics")
            return
        }

        print("Found \(characteristics.count) characteristics!")

        for characteristic in characteristics {
            //looks for the right characteristic

            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic

                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }

            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                print("Tx Characteristic: \(characteristic.uuid)")
            }

            peripheral.discoverDescriptors(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if characteristic == rxCharacteristic {
            if let value = characteristic.value {
                NotificationCenter.default.post(
                    name: Bluetooth.bluetoothUARTRX,
                    object: self,
                    userInfo: [Bluetooth.bluetoothUARTDataKey:value])
            } else {
                print("unable to read or decode UART rx value")
            }
        }
    }


    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")

        if error != nil {
            print("\(error.debugDescription)")
            return
        }

        if ((characteristic.descriptors) != nil) {

            for x in characteristic.descriptors!{
                let descript = x as CBDescriptor
                print("function name: DidDiscoverDescriptorForChar \(String(describing: descript.description))")
                print("Rx Value \(String(describing: rxCharacteristic?.value))")
                print("Tx Value \(String(describing: txCharacteristic?.value))")
            }
        }
    }


    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")

        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")

        } else {
            print("Characteristic's value subscribed")
        }

        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
            if characteristic == rxCharacteristic {
                state = .notifying
            }
        }
    }
}
