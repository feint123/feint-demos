//
//  VideoList.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//

import Foundation

import SwiftUI

struct VideoList {
    @State var list:[VideoItem]
    @State var page:Int = 1
    
    func reset() {
        list.removeAll()
        page = 1;
    }
}
