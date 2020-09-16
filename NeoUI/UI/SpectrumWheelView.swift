//
//  SpectrumWheel.swift
//  NeoUI
//
//  Created by Carl Peto on 14/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    dynamic public func offset(
        radius: CGFloat,
        angle: CGFloat) -> some View {
        let x = cos(angle) * radius
        let y = -sin(angle) * radius
        return offset(x: x, y: y)
    }
}

struct SpectrumWheelView: View {
    let saturation: Double
    @GestureState var currentColor: (hue: CGFloat, value: CGFloat)? // hue is 0-255, value is 0-100
    static var radius: CGFloat = 0 // nasty hack

    static func color(forLocation location: CGPoint) -> (hue: CGFloat, value: CGFloat) {
        let screenRadius = radius
        print("location: \(location), screenRadius: \(screenRadius)")
        let x = max(min(location.x / screenRadius - 1, 1), -1) // x as -1.0 to 1.0
        let y = max(min(location.y / screenRadius - 1, 1), -1) // y as -1.0 to 1.0
        let normalisedRadius = min(sqrt( x * x + y * y), 1) // clamp all to bounds
        print("x: \(x), y: \(y), normalisedRadius \(normalisedRadius)")
        print("acos \(acos(x))")

        var angle: CGFloat

        if y > 0 {
            // bottom half
            if abs(x) > abs(y) {
                angle = atan(y/x)
            } else {
                angle = acos(x)
            }

            angle = 2 * .pi - angle
        } else {
            if abs(x) > abs(y) {
                angle = atan(-y/x)
            } else {
                angle = acos(x)
            }
        }

        return (hue: angle / .pi * 255 / 2, value: normalisedRadius * 100)
//        if y > 0 {
//            return (hue: (2 -  angle / .pi) * 255 / 2, value: normalisedRadius * 100)
//        } else {
//            return (hue: angle / .pi * 255 / 2, value: normalisedRadius * 100)
//        }
    }

    var body: some View {
        let showCurrentColor = currentColor != nil

        return GeometryReader { geometry in
            return ZStack {
                ForEach(0..<51) { brightness in
                    SpectrumWheelView.spectrumWheel(
                        saturation: self.saturation,
                        brightness: Double(50-brightness) / 50.0,
                        size: geometry.size)
                }

                if showCurrentColor {
                    CurrentColourHighlightView()
                        .frame(
                            width: 30,
                            height: 30)
                        .offset(
                            radius: geometry.size.width / 200 * self.currentColor!.value,
                            angle: self.currentColor!.hue / 255 * .pi * 2)

                }
            }
        .gesture(
            DragGesture(minimumDistance: 0)
        .updating(self.$currentColor) { (dragValue, currentColor, _) in
                            currentColor = SpectrumWheelView.color(forLocation: dragValue.location)
                            print("\(dragValue.location) -> \(currentColor)")
                })
        }
    }

    private static func spectrumWheel(
        saturation: Double,
        brightness: Double,
        size: CGSize) -> some View {

        let gradient = Gradient(colors: stride(from: 0.0, to: 1.0, by: 0.01).map { Color(hue: $0, saturation: saturation, brightness: brightness) })
        let radius = min(size.width, size.height) / 2
        self.radius = radius
//        print("set last geometry to \(size)")

        return
            Circle()
            .fill(AngularGradient(gradient: gradient, center: .center))
            .frame(width: radius * CGFloat(brightness) * 2, height: radius * CGFloat(brightness) * 2)
    }
}


struct SpectrumWheelView_Previews: PreviewProvider {
    static var previews: some View {
        SpectrumWheelView(saturation: 1)
//        VStack {
//            SpectrumWheelView(saturation: 0.1)
//                .frame(width: 100, height: 100)
//            SpectrumWheelView(saturation: 0.3)
//                .frame(width: 200, height: 200)
//            SpectrumWheelView(saturation: 1.0, currentColor: (200, 50))
//                .frame(width: 300, height: 300)
//        }
    }
}
