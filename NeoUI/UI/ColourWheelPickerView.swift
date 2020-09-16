//
//  ColourWheelPickerView
//  NeoUI
//
//  Created by Carl Peto on 09/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//
//  credit to: https://sarunw.com/posts/gradient-in-swiftui/#angulargradient

import SwiftUI

struct ColourWheelPickerView: View {
    @Bindable var currentColour: (hue: CGFloat, value: CGFloat)?
    @Bindable var currentStatus: String = ""

    var body: some View {
        VStack {
            Text($currentStatus)
            SpectrumWheelView(saturation: 1.0, currentColor: self.$currentColour)
                .padding()
                .background(Color.black)
        }
    }
}

struct ColourWheelPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColourWheelPickerView()
    }
}
                               
