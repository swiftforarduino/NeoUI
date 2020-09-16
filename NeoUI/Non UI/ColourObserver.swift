//
//  ColourObserver.swift
//  NeoUI
//
//  Created by Carl Peto on 16/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// in this simple version we are only representing hue and brightness, with 100% saturation always
// hue is 0-255, value is 0-100
typealias NeoColour = (hue: CGFloat, value: CGFloat)

private func getColourData(_ colour: NeoColour) -> Data {
    let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 4)
    buffer[0] = Character("H").asciiValue!
    buffer[1] = UInt8(truncatingIfNeeded: Int(colour.hue))
    buffer[2] = Character("V").asciiValue!
    buffer[3] = UInt8(truncatingIfNeeded: Int(colour.value))
    return Data(buffer: buffer)
}

private func interpretColourData(data: Data) -> NeoColour? {
    if data.count >= 4 {
        return data.withUnsafeBytes { (buffer: UnsafePointer<UInt8>) -> (CGFloat, CGFloat) in
            var hue: CGFloat = 0
            var value: CGFloat = 0
            
            if buffer[0] == Character("H").asciiValue {
                hue = CGFloat(Int(buffer[1]))
            }
            
            if buffer[2] == Character("V").asciiValue {
                value = CGFloat(Int(buffer[3]))
            }
            
            return (hue, value)
        }
    } else {
        return nil
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
    @Published var currentColor: NeoColour?
    @Published var currentState: String?
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
        let bluetoothStatusName = bluetoothStatus.map { $0?.description }
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
        guard let currentColor = currentColor else {
            return
        }
        
        Bluetooth.shared.send(data: getColourData(currentColor))
    }
}
