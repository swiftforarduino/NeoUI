//
//  ColourWheelPickerView
//  NeoUI
//
//  Created by Carl Peto on 09/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//
//  credit to: https://sarunw.com/posts/gradient-in-swiftui/#angulargradient

import SwiftUI
import Combine

struct ColourWheelPickerView: View {
    @EnvironmentObject var colourObserver: ColourObserver

    var body: some View {
        ZStack {
            Color
                .black
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text(self.colourObserver.currentState ?? "- - -")
                    .foregroundColor(.gray)

                SpectrumWheelView()
                    .padding()
                    .aspectRatio(contentMode: .fit)
            }
            .background(Color.black)
        }
    }
}

struct ColourWheelPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColourWheelPickerView()
            .environmentObject(ColourObserver())
    }
}
                               
extension CGSize {
    var aspectFitSize: CGFloat {
        width > height ? height : width
    }
}
