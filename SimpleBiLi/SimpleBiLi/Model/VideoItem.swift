//
//  VideoItem.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//
import SwiftUI

struct VideoItem:Identifiable,Hashable {
    var id = UUID()
    var title:String
    var mainImage:String
    var author: String
    var face: String
    var avid:Int
    var bvid:String
    static let defaultItem = VideoItem(title: "this is a title", mainImage: "aa", author: "feint", face: "", avid: 1, bvid: "BV")
}

struct VideoDynamicCollection {
    var videoList: [VideoItem]
}
