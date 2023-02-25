//
//  ColorExtension.swift
//  EasyEdit
//
//  Created by feint on 2023/2/21.
//

import SwiftUI

struct RGBAColor: Codable, Hashable {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat
}

extension Color {
    var r: CGFloat { UIColor(self).colorComponents.red }
    var g: CGFloat { UIColor(self).colorComponents.green }
    var b: CGFloat { UIColor(self).colorComponents.blue }
    var a: CGFloat { UIColor(self).colorComponents.alpha }
    
    var rgbaColor: RGBAColor {
        RGBAColor(r: self.r, g: self.g, b: self.b, a: self.a)
    }
    
    init(_ rgbaColor: RGBAColor) {
        self.init(red: rgbaColor.r, green: rgbaColor.g, blue: rgbaColor.b, opacity: rgbaColor.a)
    }
}

extension UIColor {
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)

        return (r, g, b, a)
    }
}


extension Color {
    static let submitBtn = Color.blue
}

