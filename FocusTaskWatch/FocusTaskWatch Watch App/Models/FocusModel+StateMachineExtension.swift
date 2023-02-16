//
//  FocusModelExtension.swift
//  focus Watch App
//
//  Created by feint on 2023/2/15.
//

import WatchKit
import UserNotifications
import Foundation

/**
 状态机相关操作
 */
extension FocusModel {
    /**
     启动任务
     */
    func startTask() {
        if currentTaskId == nil {
            chooseTask(items[0].id)
        }
        
        updateCurrentNode { node in
            var currentNode = node
            currentNode.state = .running
            currentNode.startDate = Date()
            return currentNode
        }
        
        showTimeline = true
    }
    
    /**
     恢复任务
     */
    func resumeTask() {
        updateCurrentNode { node in
            var currentNode = node
            currentNode.startDate = Date().addingTimeInterval(-currentNode.timeCost)
            currentNode.state = .running
            return currentNode
        }
        showTimeline = true
    }
    
    /**
     暂停任务
     */
    func pauseTask() {
        updateCurrentNode { node in
            var currentNode = node
            currentNode.state = .pause
            return currentNode
        }
        showTimeline = false
    }
    
    /**
     重置当前任务
     */
    func resetTask() {
        updateCurrentNode { node in
            var currentNode = TaskNode()
            currentNode.taskStage = node.taskStage
            return currentNode
        }
    }
    
    /**
     结束任务
     */
    func finishTask() {
        guard var current = currentTaskLine else {
            return
        }
        let state = current.currentNode.state
        if state == .running || state == .pause {
            let _ = current.next()
        }
        // 更新Map
        taskLinesMap[Date().today()]?.updateValue(current, forKey: current.taskId)
        showTimeline = false
        // 当前任务的今日目标已达成
        if isCompletedTodayTarget() {
            showSummary = true
        }
        
        // 播放通知
        let device = WKInterfaceDevice.current();
        device.play(.notification)
        // 发送通知消息
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }

            let content = UNMutableNotificationContent()
            content.body = current.currentNode.taskStage == .rest ? "休息结束！" : "专注结束！"
            content.title = "恭喜你"
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))
        }
        // 保存数据
        save()
    }
    
    /**
     状态机
     */
    func stateMachine() {
        // 原始状态
        if currentTaskId == nil {
            startTask()
            return
        }
        
        guard let currentNode = currentTaskLine?.currentNode else {
            startTask()
            return
        }
        
        switch currentNode.state {
        case .pause:
            resumeTask()
        case .running:
            pauseTask()
        case .idle:
            startTask()
        }
        
    }
}

extension FocusModel {
    
    /**
     添加时间线
     */
    func addTimeLine(_ taskId:UUID) {
        let today = Date().today()
                
        if taskLinesMap[today] == nil {
            taskLinesMap.updateValue([UUID : TaskLine](), forKey: today)
        }
        
        if taskLinesMap[today]?[taskId] == nil {
            taskLinesMap[today]?.updateValue(TaskLine(taskId), forKey: taskId)
        }
    }
    
    /**
     选择任务
     */
    func chooseTask(_ taskId: UUID) {
        addTimeLine(taskId)
        currentTaskId = taskId
    }
    
    
    func getTaskItemById(_ id: UUID) -> TaskItem {
        let item = items.first { item in
            item.id == id
        }

        return item ?? items[0]
    }
    /**
     任务是否开始执行
     */
    func isStartTask() -> Bool {
        guard let currentTaskNode = currentTaskLine?.currentNode else {
            return false
        }
        return currentTaskNode.state != .idle
    }
   
    /**
     更新任务节点的值
     */
    func updateCurrentNode(_ update:(_ node: TaskNode)->TaskNode) {
        guard var current = currentTaskLine else {
            return
        }
        let currentNode = update(current.currentNode)
        current.currentNode = currentNode
        taskLinesMap[Date().today()]?.updateValue(current, forKey: current.taskId)
    }
    

    func isPauseTask() ->Bool {
        guard let currentNode = currentTaskLine?.currentNode else {
            return false
        }
        return currentNode.state == TaskState.pause
    }

    /**
     当前任务是否已经完成今日任务
     */
    func isCompletedTodayTarget() -> Bool{
        if let current = currentTaskLine {
            if (current.epoch >= Int(getTaskItemById(current.taskId).daliyFocusTarget)) {
                return true
            }
        }
        return false;
    }
   
    /**
     获取不同状态下操作按钮的位置和system_icon
     */
    func operatorDesc() -> (String, String) {
        if currentTaskId == nil {
            return ("play", "开始专注")
        }
        
        guard let currentNode = currentTaskLine?.currentNode else {
            return ("play", "开始专注")
        }
        
        if isCompletedTodayTarget() {
            return ("sparkles", "目标达成")
        }
        
        switch currentNode.state {
        case .pause:
            return ("play", "恢复")
        case .running:
            return ("pause", "暂停")
        case .idle:
            return currentNode.taskStage == .rest ? ("play", "开始休息") : ("play", "开始专注")
        }
    }
    /**
     更新时间轴数据
     */
    func update(_ time: Double) {
        guard let current = currentTaskLine else {
            return
        }
        
        updateCurrentNode { node in
            var currentNode = node
            currentNode.timeCost = time
            return currentNode
        }
        
        let item = getTaskItemById(current.taskId)
        let maxValue = (current.currentNode.taskStage == .rest ? item.restIntervalSec : item.focusIntervalSec) + current.currentNode.overtime
        
        if (time >= maxValue) {
            finishTask()
        }
    }
    
   

    /**
     加时
     */
    func overtime(_ time: Double) {
        stateMachine()
        updateCurrentNode { node in
            var currentNode = node
            currentNode.overtime = time
            return currentNode
        }
    }
    
    /**
     格式化倒计时
     */
    func formatTime() -> String {
        guard let current = currentTaskLine else {
            return "25:00"
        }
        let item = getTaskItemById(current.taskId)
        let maxValue = (current.currentNode.taskStage == .rest ? item.restIntervalSec : item.focusIntervalSec) + current.currentNode.overtime
        let interval = Int(current.currentNode.timeCost)
        let leaveTime = Int(maxValue) - interval
        let intMinute = leaveTime / 60
        let intSecond = leaveTime % 60
        
        return "\(String(format:"%02d",intMinute)):\(String(format:"%02d", intSecond))"
    }
    
}
