//
//  ContentView.swift
//  NeoUI
//
//  Created by Carl Peto on 09/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//
//  credit to: https://sarunw.com/posts/gradient-in-swiftui/#angulargradient

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

private func spectrumWheelConcentric(
    saturation: Double,
    width: CGFloat,
    height: CGFloat) -> some View {
    ZStack {
        ForEach(0..<51) { brightness in
            spectrumWheel(
                saturation: saturation,
                brightness: Double(50-brightness) / 50.0,
                width: width,
                height: height)
        }
    }
    .background(Color.black)
}

struct ContentView: View {
    var body: some View {
        spectrumWheelConcentric(saturation: 1.0, width: 300.0, height: 300.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
                               
