//
//  RegionItem.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//

import Foundation

struct SidebarItem :Identifiable{
    let id:Int
    let name: String
    var icon: String = "appletv"
    var tid:Int = -1
}
