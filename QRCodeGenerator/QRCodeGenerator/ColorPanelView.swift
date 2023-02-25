//
//  ColorPanelView.swift
//  EasyEdit
//
//  Created by feint on 2023/2/22.
//

import SwiftUI

struct ColorPanelView: View {
    
    var colors: [ColorItem] = [ColorItem(color: .blue), ColorItem(color: .brown), ColorItem(color: .cyan), ColorItem(color: .green), ColorItem(color: .indigo), ColorItem(color: .mint), ColorItem(color: .orange), ColorItem(color: .pink), ColorItem(color: .purple),ColorItem(color: .red), ColorItem(color: .teal), ColorItem(color: .yellow), ColorItem(color: .black), ColorItem(color: .gray)]
    
    @Binding var selectColor: Color
        
    var columns:[GridItem] {
        [ GridItem(.adaptive(minimum: 40), spacing: 4, alignment: .top)]
    }
    
    
    var body: some View {
        
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(colors.withoutDuplicates()) { color in
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 40, height: 40)
                    .foregroundColor(color.color)
                    .onTapGesture {
//                        withAnimation {
                            selectColor = color.color
//                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: selectColor == color.color ? 3: 0)
                            .foregroundColor(.primary)
                    }
            }
        }
        
    }
}

struct ColorItem: Identifiable, Equatable {
    var id = UUID()
    var color: Color
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.color == rhs.color
    }
}

struct ColorPanelView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPanelView(selectColor: .constant(.red))
    }
}
