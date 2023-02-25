//
//  SidebarView.swift
//  my-bilibili
//
//  Created by feint on 2022/12/6.
//

import SwiftUI

struct SidebarView: View {
    @Binding var id: Int?
    @EnvironmentObject var fetcher:BiliFetcher
    
    var body: some View {
        List(selection: $id){
            ForEach(fetcher.sidebars) { section in
                if section.items.count > 0 {
                    Section(section.sectionName) {
                        ForEach(section.items) { item in
                            Label(item.name, systemImage: item.icon)
                        }
                    }
                }
            }
        }.listStyle(.sidebar)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(id: .constant(1))
    }
}
