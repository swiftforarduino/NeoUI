//
//  CurrentColourHighlightView.swift
//  NeoUI
//
//  Created by Carl Peto on 15/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//

import SwiftUI

// from https://www.hackingwithswift.com/books/ios-swiftui/paths-vs-shapes-in-swiftui
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

struct CurrentColourHighlightView: View {
    let lineWidth: CGFloat = 3
    let color: Color = .white

    var body: some View {
        Rectangle()
            .stroke(color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round))
            .shadow(radius: lineWidth, x: lineWidth / 2, y: lineWidth / 2)
    }
}

struct CurrentColourHighlightView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentColourHighlightView()
        .frame(width: 300, height: 300)
        .padding()
            .background(Color.gray)
    }
}
