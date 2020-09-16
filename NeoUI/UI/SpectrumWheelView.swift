//
//  SpectrumWheel.swift
//  NeoUI
//
//  Created by Carl Peto on 14/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//

import SwiftUI

struct SpectrumWheelView: View {
    @State var saturation: Double = 1.0

    @EnvironmentObject var colourObserver: ColourObserver
    @GestureState var currentDragColor: NeoColour?

    private var colourToHighlight: NeoColour {
        if let currentDragColor = currentDragColor {
            return currentDragColor
        } else {
            return colourObserver.currentColor ?? (0,0)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<51) { brightness in
                    SpectrumWheelView.spectrumWheel(
                        saturation: self.saturation,
                        brightness: Double(50-brightness) / 50.0,
                        size: geometry.size)
                }

                CurrentColourHighlightView()
                    .frame(
                        width: 30,
                        height: 30)
                    .offset(
                        radius: geometry.size.width / 200 * self.colourToHighlight.value,
                        angle: self.colourToHighlight.hue / 255 * .pi * 2)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating(self.$currentDragColor) { (dragValue, currentDragColor, _) in
                            currentDragColor = SpectrumWheelView.color(forLocation: dragValue.location)
                    })
        }
    }

    private static func spectrumWheel(
        saturation: Double,
        brightness: Double,
        size: CGSize) -> some View {

        let gradient = Gradient(colors: stride(from: 0.0, to: 1.0, by: 0.01).map { Color(hue: $0, saturation: saturation, brightness: brightness) })
        let radius = min(size.width, size.height) / 2
        self.radius = radius // nasty hack

        return
            Circle()
            .fill(AngularGradient(gradient: gradient, center: .center))
            .frame(width: radius * CGFloat(brightness) * 2, height: radius * CGFloat(brightness) * 2)
    }

    static var radius: CGFloat = 0 // nasty hack

    static func color(forLocation location: CGPoint) -> (hue: CGFloat, value: CGFloat) {
        let screenRadius = radius // nasty hack

        let x = max(min(location.x / screenRadius - 1, 1), -1) // x as -1.0 to 1.0
        let y = max(min(location.y / screenRadius - 1, 1), -1) // y as -1.0 to 1.0
        let normalisedRadius = min(sqrt( x * x + y * y), 1) // clamp all to bounds

        var angle: CGFloat

        if y > 0 {
            // bottom half
            if abs(x) > abs(y) {
                if x > 0 {
                    // bottom right
                    angle = atan( y / x )
                } else {
                    // bottom left
                    angle = .pi - atan( y / -x )
                }
            } else {
                // when we are nearer to the upright, acos
                // should be more accurate than atan
                angle = acos(x)
            }

            angle = 2 * .pi - angle
        } else {
            // negative y, we are in the top half
            if abs(x) > abs(y) {
                if x > 0 {
                    // top right
                    angle = atan( -y / x )
                } else {
                    // top left
                    angle = .pi - atan( -y / -x )
                }
            } else {
                // when we are nearer to the upright, acos
                // should be more accurate than atan
                angle = acos(x)
            }
        }

        return (hue: angle / .pi * 255 / 2, value: normalisedRadius * 100)
    }
}


struct SpectrumWheelView_Previews: PreviewProvider {
    static var previews: some View {
        SpectrumWheelView()
        .environmentObject(ColourObserver())
//        VStack {
////            SpectrumWheelView(saturation: 0.1)
////                .frame(width: 100, height: 100)
////            SpectrumWheelView(saturation: 0.3)
////                .frame(width: 200, height: 200)
//            SpectrumWheelView(saturation: 1.0)
//                .frame(width: 300, height: 300)
//        }
//        .environmentObject(ColourObserver())
    }
}

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
