//
//  SidebarSection.swift
//  my-bilibili
//
//  Created by feint on 2022/12/6.
//

import Foundation

struct SideBarSection:Identifiable{
    var id = UUID()
    var sectionName: String = "标题"
    var type: Int = 0
    var items:[SidebarItem] = []
}
