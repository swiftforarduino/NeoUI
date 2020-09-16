//
//  View+extensions.swift
//  NeoUI
//
//  Created by Carl Peto on 16/09/2020.
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
