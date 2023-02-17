//
//  FocusGaugeStyle.swift
//  focus Watch App
//
//  Created by feint on 2023/2/12.
//

import Foundation
import SwiftUI

struct FocusGaugeStyle: GaugeStyle {
    @State var progress = 0.0
    @Binding var size : Double
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
        
            configuration.label
            
            Circle()
                .stroke(lineWidth: size)
                .foregroundColor(.blue.opacity(0.2))
                .padding(10)
 
            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: size, lineCap: .round))
                .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
//                .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 0)
                .padding(10)
                .rotationEffect(.degrees(-90))
        }.onChange(of: configuration.value) { newValue in
            withAnimation {
                progress = newValue
            }
        }
    }
}
