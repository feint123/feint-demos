//
//  FocusModel.swift
//  focus Watch App
//
//  Created by feint on 2023/2/12.
//

import Foundation
import WatchKit
import UserNotifications

class FocusModel: Codable , ObservableObject {
    // 任务模版列表
    @Published var items = [TaskItem("🍅学习")]
    
    @Published var currentTaskId:UUID?
    
    @Published var taskLinesMap = [String: [UUID: TaskLine]]()
    
    @Published var showTimeline = false

    @Published var showSummary = false
    
//    var session: WKExtendedRuntimeSession?
    
  
    /**
     获取当前的时间线
     */
    var currentTaskLine: TaskLine? {
        get {
            guard let currentTaskId = currentTaskId else {
                return nil
            }
           
            guard let lineMap = taskLinesMap[Date().today()] else {
                return nil
            }
            
            return lineMap[currentTaskId]
        }
    }
    
    var currentItem: TaskItem {
        get {
            getTaskItemById(currentTaskId ?? UUID())
        }
    }
    
    var taskStartDate: Date {
        get {
            currentTaskLine?.currentNode.startDate ?? Date()
        }
    }
    
    let dataFileName = "FocusTask.json"
    
    
    init() {
        // Load the data model from the 'Products' data file found in the Documents directory.
        if let codedData = try? Data(contentsOf: dataModelURL()) {
            // Decode the json file into a DataModel object.
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(FocusModel.self, from: codedData) {
                items = decoded.items
                currentTaskId = decoded.currentTaskId
                taskLinesMap = decoded.taskLinesMap
                showTimeline = decoded.showTimeline
            }
        }
    }
    
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decode(Array.self, forKey: .items)
        currentTaskId = try values.decode(Optional.self, forKey: .currentTaskId)
        taskLinesMap = try values.decode(Dictionary.self, forKey: .taskLinesMap)
        showTimeline = try values.decode(Bool.self, forKey: .showTimeline)
    }
    
}


enum TaskStage: Codable {
    case focus, rest
}


enum TaskState: Codable {
    case idle, running, pause
}

/**
 任务节点
 */
struct TaskNode: Codable {
    var taskStage:TaskStage = .focus
    var state: TaskState = .idle
    var timeCost: Double = 0.0
    var overtime: Double = 0.0
    var startDate: Date = Date()
    
    func nextStage() -> TaskStage {
        if (taskStage == .focus) {
            return .rest
        } else {
            return .focus
        }
    }
}

struct TaskLine: Codable {
    var currentNode: TaskNode
    var taskId: UUID

    //当前任务周期数（一次专注 + 一次休息记为一个周期）
    var epoch: Int = 0
    
    init(_ taskId: UUID) {
        self.currentNode = TaskNode()
        self.taskId = taskId
    }
    
    mutating func next() -> TaskNode {
        if currentNode.taskStage == .rest {
            self.epoch += 1
        }
        var node = TaskNode()
        node.taskStage = currentNode.nextStage()
        self.currentNode = node
        return self.currentNode
    }
}


extension Date {
    func today() -> String {
        let dateFormatter = DateFormatter();
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
}
