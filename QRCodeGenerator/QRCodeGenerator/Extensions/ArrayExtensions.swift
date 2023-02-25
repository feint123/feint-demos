//
//  ArrayExtensions.swift
//  EasyEdit
//
//  Created by feint on 2023/2/22.
//

import Foundation

extension Array where Element: Equatable {
    
    func withoutDuplicates() -> [Element] {
        // Thanks to https://github.com/sairamkotha for improving the method
        return reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }
    
}
