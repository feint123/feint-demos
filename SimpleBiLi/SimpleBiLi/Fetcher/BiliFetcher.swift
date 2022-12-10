//
//  BiliFetcher.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//

import SwiftUI
import CoreMedia
class BiliFetcher: ObservableObject {
    @Published var sidebars:[SideBarSection] = [SideBarSection(sectionName: "视频", type: 0,
                                                    items: [SidebarItem(id:0, name:"热门视频", icon: "trophy"),
//                                                            SidebarItem(id:1, name: "推荐", icon: "hand.thumbsup"),
                                                            SidebarItem(id:2, name: "视频排行榜", icon: "chart.bar")
                                                              ]),
                                                SideBarSection(sectionName: "分区", type: 1,
                                                               items: [SidebarItem(id:10, name:"动画", icon: "tv", tid: 1),
                                                                       SidebarItem(id:11, name: "科技", icon: "tv", tid: 188),
                                                                       SidebarItem(id:12, name: "知识", icon: "tv", tid: 36),
                                                                       SidebarItem(id:13, name: "游戏", icon: "tv", tid: 4),
                                                              ])]
    @Published var videoDetail:VideoDetail=VideoDetail()
    @Published var videoList:[VideoItem] = []
    @Published var recVideoList:[VideoItem] = []
    @Published var searchReusltList:[VideoItem] = []
    @Published var regionPage = 1
    @Published var suggests:[SearchSuggest] = []
    @Published var currentKeyword:String = ""
    @Published var currentTid = -1
    @Published var playerHistory: Dictionary<String, CMTime> = Dictionary()
    @Published var playerUrlMap: Dictionary<String, String> = Dictionary()
    
    
    // 视频详情地址
    let VIDEO_DETAIL_URL="https://api.bilibili.com/x/web-interface/view?aid="
    // 视频流地址
    let VIDEO_PLAY_URL="https://api.bilibili.com/x/player/playurl?qn=32&fnval=1&"
    let THIRD_PLAY_URL="https://api.injahow.cn/bparse/?p=1&format=mp4&otype=url&av="
    // 分区视频列表地址
    let VIDEO_DYNAMIC_URL="https://api.bilibili.com/x/web-interface/dynamic/region?"
    // 热门视频列表地址
    let VIDEO_HOT_URL="https://api.bilibili.com/x/web-interface/popular?"
    // 相关视频推荐
    let VIDEO_REC_URL = "https://api.bilibili.com/x/web-interface/archive/related?aid="
    // 视频排行
    let VIDEO_RANK_URL = "https://api.bilibili.com/x/web-interface/ranking/v2"
    // 搜索推荐
    let SEARCH_SUGGEST_URL = "https://s.search.bilibili.com/main/suggest?term="
    // 搜索结果
    let SEARCH_URL = "https://api.bilibili.com/x/web-interface/search/type?search_type=video&"
}
