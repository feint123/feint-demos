//
//  VideoDetail.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//

import SwiftUI

struct VideoDetail {
    var title:String="暂无标题暂无简介暂无简介暂无简介暂无简介暂无简介暂无简介暂无简介"
    var upInfo:UpInfo=UpInfo(name: "测试", headImage: "head")
    var introduce:String="暂无简介"
    var videoLink:String=""
    var videoImg: String=""
    var bvid: String = ""
    var lastBvid: String = ""
    var tags:[Tag]=[Tag(id: 1, value: "Ipad")]
}

