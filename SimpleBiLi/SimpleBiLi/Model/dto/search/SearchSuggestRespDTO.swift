//
//  SearchSuggestRespDTO.swift
//  my-bilibili
//
//  Created by feint on 2022/12/9.
//

import Foundation

struct SearchSuggestRespDTO: Codable {
    var value: String
    var term: String
    var ref: Int
    var name: String
    var spid: Int
}
