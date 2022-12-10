//
//  SearchSuggest.swift
//  my-bilibili
//
//  Created by feint on 2022/12/9.
//

import Foundation

struct SearchSuggest: Identifiable {
    var id = UUID()
    var term: String = ""
    var value: String = ""
}
