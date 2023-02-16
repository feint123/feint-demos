//
//  TaskItem.swift
//  focus Watch App
//
//  Created by feint on 2023/2/12.
//

import Foundation

struct TaskItem: Identifiable, Hashable, Codable {
    var id = UUID()
    // 任务描述
    var description: String = ""
    // 专注时长
    var focusInterval: Double = 0.2
    // 休息时长
    var restInterval: Double = 0.2
    //  每日目标专注次数
    var daliyFocusTarget: Double = 4.0
    
    init(_ description:String) {
        self.description = description
    }
    
    var focusIntervalSec: Double {
        get {
            focusInterval * 60.0
        }
    }
    
    var restIntervalSec: Double {
        get {
            restInterval * 60.0
        }
    }
    
}
