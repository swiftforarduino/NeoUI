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
    var body: some View {
        SpectrumWheelView(saturation: 1.0, width: 300.0, height: 300.0)
        .background(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
                               
