//
//  ToolsGroup.swift
//  EasyEdit
//
//  Created by feint on 2023/2/23.
//

import SwiftUI

struct ToolsGroupView<Content>: View where Content:View {
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(spacing: 8) {
            content()
        }
        .padding()
        .group()
    }
}

struct ToolsGroupView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ToolsGroupView {
                Text("Hello World")
                Text("Hello World")
                Text("Hello World")
            }
        }
    }
}
