//
//  MilestoneProgressView.swift
//  FocusTask Watch App
//
//  Created by feint on 2023/2/15.
//

import SwiftUI

struct MilestoneProgressView: View {
    @Binding var progress: CGFloat
    @Binding var count: Float
    @State private var radius: CGFloat = 5
    @State private var lineWidth: CGFloat = 2
    @State private var color:Color = .cyan
    
    var body: some View {
        GeometryReader { bounds in
            VStack {
                MilestoneShape(count: Int(count), radius: radius)
                    .stroke(lineWidth: lineWidth)
                    .foregroundColor(color.opacity(0.3))
                    .padding(.horizontal, lineWidth/2)
                    .overlay {
                        MilestoneShape(count: Int(count), radius: radius)
                            .stroke(lineWidth: lineWidth)
                            .foregroundColor(color)
                            .padding(.horizontal, lineWidth/2)
                            .mask(
                                HStack {
                                    Rectangle()
                                        .frame(width: (radius + lineWidth) * 2 * progress, alignment: .leading)
                                    Spacer(minLength: 0)
                                }
                            )
                    }
                    .padding(.horizontal, lineWidth/2)
            }
        }.frame(width: CGFloat(count) * (radius + lineWidth) * 2, height: radius * 2 + lineWidth)
    }
    
    struct MilestoneShape: Shape {
        let count: Int
        let radius: CGFloat
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            var maxX: CGFloat = 0
            let remainingSpace: CGFloat = rect.width - (CGFloat(count)*radius*2)
            let lineLength: CGFloat = remainingSpace / CGFloat(count - 1)
            
            for i in 1...count {
                path.addEllipse(in: CGRect(origin: CGPoint(x: maxX, y: rect.midY - radius), size: CGSize(width: radius*2, height: radius*2)))
                maxX += radius*2
                if i != count {
                    maxX += lineLength
                }
            }
            return path
        }
    }
}

struct MilestoneProgressView_Previews: PreviewProvider {
    static var previews: some View {
        MilestoneProgressView(progress: .constant(2), count: .constant(5))
    }
}

