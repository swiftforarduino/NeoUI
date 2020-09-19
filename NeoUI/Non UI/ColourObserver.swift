//
//  ColourObserver.swift
//  NeoUI
//
//  Created by Carl Peto on 16/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//

import Foundation
import Combine
import CoreGraphics

// in this simple version we are only representing hue and brightness, with 100% saturation always
// hue is 0-255, value is 0-100, on is boolean but ignored in some cases
typealias NeoColour = (hue: CGFloat, value: CGFloat, on: Bool)

private func getColourData(_ colour: NeoColour) -> Data {
    let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 4)
    buffer[0] = Character("H").asciiValue!
    buffer[1] = UInt8(truncatingIfNeeded: Int(colour.hue))
    buffer[2] = Character("V").asciiValue!
    buffer[3] = UInt8(truncatingIfNeeded: Int(colour.value))
    return Data(buffer: buffer)
}

private func interpretColourData(data: Data) -> NeoColour {
    if data.count >= 4 {
        return data.withUnsafeBytes { (buffer: UnsafePointer<UInt8>) -> (CGFloat, CGFloat, Bool) in
            var hue: CGFloat = 0
            var value: CGFloat = 0
            var on: Bool = true
            
            if buffer[0] == Character("H").asciiValue {
                hue = CGFloat(Int(buffer[1]))
            }
            
            if buffer[2] == Character("V").asciiValue {
                value = CGFloat(Int(buffer[3]))
            }

            if data.count >= 6, buffer[4] == Character("1").asciiValue {
                on = Int(buffer[5]) == 1
            }
            
            return (hue, value, on)
        }
    } else {
        return (0,0,true)
    }
}

// for some reason, the app sometimes gets stuck saying "connecting"
// which corresponds to the scanning state
// next time this happens, see if killing the app and restarting it fixes it
// if so it's an ios app problem and not the s4a program hanging or similar

extension Bluetooth.State: CustomStringConvertible {
    var description: String {
        switch self {
        case .undefined:
            return "---"
        case .disabled:
            return "DISABLED"
        case .disconnected:
            return "not connected"
        case .scanning:
            return "connecting"
        case .connecting:
            return "connecting."
        case .connected:
            return "connecting.."
        case .discoveredServices:
            return "connecting..."
        case .gotCharacteristics:
            return "connecting...."
        case .notifying:
            return "connected"
        }
    }
}

class ColourObserver: ObservableObject {
    @Published var currentColor: NeoColour = (0,0,true)
    @Published var currentState: String = ""
    @Published var controlsDisabled: Bool = false
    
    private var btEnabledStateObserver: AnyCancellable?
    private var colourObserver: AnyCancellable?
    private var statusObserver: AnyCancellable?
    private var controlsDisabledObserver: AnyCancellable?

    func setupSubscribers() {
        // base publishers
        let bluetoothStatus = NotificationCenter.Publisher(
            center: .default,
            name: Bluetooth.bluetoothStateChange,
            object: nil)
            .receive(on: RunLoop.main)
            .map { $0.userInfo?[Bluetooth.bluetoothStateKey] as? Bluetooth.State }
        
        let colour = NotificationCenter.Publisher(
            center: .default,
            name: Bluetooth.bluetoothUARTRX,
            object: nil)
            .receive(on: RunLoop.main)
            .map { $0.userInfo?[Bluetooth.bluetoothUARTDataKey] as? Data }
            .compactMap({$0})
            .map(interpretColourData)
        
        // derived publishers
        let bluetoothStatusName = bluetoothStatus.map { $0?.description ?? "---" }
        let bluetoothTransmitEnabled = bluetoothStatus.map{$0 == .notifying}
        // slight hack: create a publisher that needs at least one value from colour and status so we know we have
        // received a value for the colour from the board before we show the controls for the first time
        let showControls = Publishers.CombineLatest(bluetoothTransmitEnabled, colour).map{$0.0}
        let controlsDisabled = showControls.map { !$0 }
        
        // subscribers
        colourObserver = colour.assign(to: \.currentColor, on: self)
        statusObserver = bluetoothStatusName.assign(to: \.currentState, on: self)
        controlsDisabledObserver = controlsDisabled.assign(to: \.controlsDisabled, on: self)

        // when bluetooth becomes available, ask what the current colour is
        btEnabledStateObserver = bluetoothTransmitEnabled.sink { enabled in
            if enabled {
                // ask for current state
                Bluetooth.shared.send(data: "?".data(using: .ascii)!)
            }
        }
    }
    
    func sendCurrentColour() {        
        Bluetooth.shared.send(data: getColourData(currentColor))
    }

    func sendFastTurnOff() {
        Bluetooth.shared.send(data: "0".data(using: .ascii)!)
    }

    func sendFastTurnOn() {
        Bluetooth.shared.send(data: "1".data(using: .ascii)!)
    }

    func sendFadeOut() {
        Bluetooth.shared.send(data: "2".data(using: .ascii)!)
    }

    func sendFadeIn() {
        Bluetooth.shared.send(data: "3".data(using: .ascii)!)
    }
}
