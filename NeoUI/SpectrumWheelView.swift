//
//  SpectrumWheel.swift
//  NeoUI
//
//  Created by Carl Peto on 14/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//

import SwiftUI

private func spectrumWheel(
    saturation: Double,
    brightness: Double,
    scale: CGFloat,
    width: CGFloat,
    height: CGFloat) -> some View {
        let gradient = Gradient(colors: stride(from: 0.0, to: 1.0, by: 0.01).map { Color(hue: $0, saturation: saturation, brightness: brightness) })
    return Circle()
        .fill(
            AngularGradient(gradient: gradient, center: .center)
    )
    .frame(width: width * scale, height: height * scale)
}

private func spectrumWheel(
    saturation: Double,
    brightness: Double,
    width: CGFloat,
    height: CGFloat) -> some View {
    spectrumWheel(
        saturation: saturation,
        brightness: brightness,
        scale: CGFloat(brightness),
        width: width,
        height: height)
}

struct SpectrumWheelView: View {
    let saturation: Double
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<51) { brightness in
                spectrumWheel(
                    saturation: self.saturation,
                    brightness: Double(50-brightness) / 50.0,
                    width: self.width,
                    height: self.height)
            }
        }
    }
}


struct SpectrumWheelView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SpectrumWheelView(saturation: 0.1, width: 100.0, height: 100.0)
            SpectrumWheelView(saturation: 0.3, width: 200.0, height: 200.0)
            SpectrumWheelView(saturation: 1.0, width: 300.0, height: 300.0)

        }
    }
}
