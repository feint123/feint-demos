//
//  UrlUtils.swift
//  my-bilibili
//
//  Created by feint on 2022/12/9.
//

import Foundation

struct UrlUtils {
    static func toSafeUrl(url: String) -> String {
        return url.contains("http") ? url.replacingOccurrences(of: "http://", with: "https://") : "https:\(url)"
    }
 
}
