//
//  ContentView.swift
//  NeoUI
//
//  Created by Carl Peto on 09/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//
//  credit to: https://sarunw.com/posts/gradient-in-swiftui/#angulargradient

import SwiftUI

struct ContentView: View {
//    @GestureState var currentColor: (hue: CGFloat, value: CGFloat) = (0, 0)

    var body: some View {
        let wheelView = SpectrumWheelView(saturation: 1.0, currentColor: (200, 50))

//        let drag =
//            DragGesture(minimumDistance: 0)
//                .updating($currentColor) { (dragValue, currentColor, _) in
////                    print("\(dragValue.location) -> \(SpectrumWheelView.color(forLocation: dragValue.location))")
//                    currentColor = SpectrumWheelView.color(forLocation: dragValue.location)
//        }

        return wheelView
            .padding()
            .background(Color.black)
//            .gesture(drag)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
                               
