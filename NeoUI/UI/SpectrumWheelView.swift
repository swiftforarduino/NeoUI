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
            return colourObserver.currentColor
        }
    }

    var body: some View {
        GeometryReader { geometry in
                if self.colourObserver.currentColor.on {
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
                        ExclusiveGesture(
                            TapGesture(count: 2)
                                .onEnded{
                                    self.colourObserver.currentColor.on = false
                                    self.colourObserver.sendFadeOut()
                                },

                        DragGesture(minimumDistance: 0)
                            .updating(self.$currentDragColor) { (dragValue, currentDragColor, _) in
                                    currentDragColor = SpectrumWheelView.color(forLocation: dragValue.location)

                                // this may be possible but needs to be throttled
                                // otherwise it generates too many transmissions to the bluetooth device, which then lags
//                                if let color = currentDragColor {
//                                    self.colourObserver.currentColor =
//                                        (color.hue, color.value, self.colourObserver.currentColor.on)
//
//                                    self.colourObserver.sendCurrentColour()
//                                }
                            }
                        .onEnded { dragValue in
                            let newColor = SpectrumWheelView.color(forLocation: dragValue.location)

                            self.colourObserver.currentColor =
                                (newColor.hue, newColor.value, self.colourObserver.currentColor.on)

                            self.colourObserver.sendCurrentColour()
                        }))
                } else {
                    Circle()
                        .foregroundColor(.gray)
                        .onTapGesture(count: 2) {
                            self.colourObserver.currentColor.on = true
                            self.colourObserver.sendFadeIn()
                        }
                }
        }
        .animation(.easeInOut)
    }

    private static var radius: CGFloat = 0 // nasty hack
}

struct SpectrumWheelView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            SpectrumWheelView()
            .environmentObject(ColourObserver())
        }
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


/* private */
extension SpectrumWheelView {
    private static func spectrumWheel(
        saturation: Double,
        brightness: Double,
        size: CGSize) -> some View {

        // gradient goes "backwards" because Angular Gradient goes clockwise
        // and normal math trig functions go the other way
        let gradient = Gradient(colors: stride(from: 1.0, to: 0.0, by: -0.01).map { Color(hue: $0, saturation: saturation, brightness: brightness) })
        let radius = min(size.width, size.height) / 2
        self.radius = radius // nasty hack

        return
            Circle()
                .fill(AngularGradient(gradient: gradient, center: .center))
            .frame(width: radius * CGFloat(brightness) * 2, height: radius * CGFloat(brightness) * 2)
    }

    static func color(forLocation location: CGPoint) -> NeoColour {
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

        return (hue: angle / .pi * 255 / 2, value: normalisedRadius * 100, true)
    }
}
