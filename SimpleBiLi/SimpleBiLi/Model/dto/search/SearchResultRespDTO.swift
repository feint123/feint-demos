//
//  SearchResultRespDTO.swift
//  my-bilibili
//
//  Created by feint on 2022/12/9.
//

import Foundation

struct SearchResultRespDTO: Codable {
    let code:Int
    let message:String
    let ttl:Int
    let data: SearchDataDTO
    
    struct SearchDataDTO: Codable {
        var result: [SearchResultDTO]
        var page: Int
        var pagesize:Int
        var numResults: Int
        var numPages: Int
    }
    
    struct SearchResultDTO: Codable {
        var result_type: String
        var data:[SearchResultDataDTO]
    }
    
    struct SearchResultDataDTO: Codable {
//        "tips",
//        "esports",
//        "bili_user",
//        "user",
//        "activity",
//        "web_game",
//        "card",
//        "media_bangumi",
//        "media_ft",
//        "star",
//        "video"
        var type: String
        var mid: Int
        var id: Int
        var typeid: String
        var aid: Int
        var title: String
        var bvid: String
        var description: String
        var pic: String
        var play: Int
        var favorites: Int
        var video_review: Int
        var tag: String
        // 用户头像
        var upic: String
        
    }
}


