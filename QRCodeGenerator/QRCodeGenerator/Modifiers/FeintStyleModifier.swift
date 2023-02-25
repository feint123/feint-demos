//
//  CapsuleModifier.swift
//  EasyEdit
//
//  Created by feint on 2023/2/19.
//

import SwiftUI
import CompactSlider

var NORMAL_COLOR: Material = .regularMaterial
var NORMAL_RADIUS: CGFloat = 16

struct CapsuleModifier: ViewModifier {

    
    func body(content: Content) -> some View {
        content
            .background(NORMAL_COLOR)
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: NORMAL_RADIUS, style: .continuous))
            .overlay {RoundedRectangle(cornerRadius: NORMAL_RADIUS, style: .continuous)
                            .strokeBorder(.quaternary, lineWidth: 0.5)}
//            .shadow(color: .secondary.opacity(0.2), radius: 5, x: 0, y: 0)
    }
}

struct NormalPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
    }
}

struct FontStyle: ViewModifier {
    var size: CGFloat
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .medium, design: .rounded))
    }
}

extension View {
    func capsule() -> some View {
        ModifiedContent(content: self, modifier: CapsuleModifier())
    }
    
    func normalPadding() -> some View {
        ModifiedContent(content: self, modifier: NormalPaddingModifier())
    }
    
    func roundFont(_ size: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: FontStyle(size: size))
    }
    
    func group() -> some View {
        ModifiedContent(content: self, modifier: GroupStyle())
    }
}


public struct CustomCompactSliderStyle: CompactSliderStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(NORMAL_COLOR)
            .clipShape(RoundedRectangle(cornerRadius: NORMAL_RADIUS, style: .continuous))
            .overlay {RoundedRectangle(cornerRadius: NORMAL_RADIUS, style: .continuous)
                            .strokeBorder(.quaternary, lineWidth: 0.5)}
    }
}

public extension CompactSliderStyle where Self == CustomCompactSliderStyle {
    static var `custom`: CustomCompactSliderStyle { CustomCompactSliderStyle() }
}


public struct SubmitButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorSchema: ColorScheme
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .normalPadding()
            .background(colorSchema == .light ? (configuration.isPressed ? .blue.opacity(0.8) : .blue) :
                            (configuration.isPressed ? .blue.opacity(0.7) : .blue.opacity(0.5)))
            .foregroundColor(colorSchema == .light ? .white : .blue)
            .clipShape(RoundedRectangle(cornerRadius: NORMAL_RADIUS, style: .continuous))
            .overlay {RoundedRectangle(cornerRadius: NORMAL_RADIUS, style: .continuous)
                .strokeBorder(.blue, lineWidth: 0.5)}
    }
}


struct ListRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}


struct GroupStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(NORMAL_COLOR)
            .clipShape(RoundedRectangle(cornerRadius: NORMAL_RADIUS))
            .overlay {RoundedRectangle(cornerRadius: NORMAL_RADIUS, style: .continuous)
                            .strokeBorder(.quaternary, lineWidth: 0.5)}
    }
}


