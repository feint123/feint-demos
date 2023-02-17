//
//  FocusNotifications.swift
//  FocusTaskWatch Watch App
//
//  Created by feint on 2023/2/17.
//

import Foundation
import UserNotifications
struct FocusNotification {
    static func send(content: UNMutableNotificationContent, timeInterval: TimeInterval,  onComplete: @escaping () -> Void) {
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) else {
//                // 当没有通知权限时使用 alarm session
//                if WKApplication.shared().applicationState == .background {
//                    if let session = self.session {
//                        if session.state == .running {
//                            session.notifyUser(hapticType: .notification)
//                        }
//                    }
//                } else {
//                    if let session = self.session {
//                        session.invalidate()
//                    }
//                    WKInterfaceDevice.current().play(.notification)
//                }
                return
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            // 移除正在等待的消息
            center.removePendingNotificationRequests(withIdentifiers: [content.categoryIdentifier])
            center.removeDeliveredNotifications(withIdentifiers: [content.categoryIdentifier])
            center.add(request) { error in
                // donothing
//                if let session = self.session {
//                    session.invalidate()
//                }
                if let error = error {
                    debugPrint(error)
                }
                onComplete()
            }
            
        }
    }
    
    static func sendSuccess(message: NotifiMessage, timeInterval: TimeInterval, onComplete: @escaping () -> Void) {
        let content = UNMutableNotificationContent()
        content.subtitle = "\(message.epoch):\(message.totalEpoch)"
        content.body = "\(message.stage == .focus ?  "专注结束！" : "休息结束！")"
        content.title = "恭喜你"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = FOCUS_CATE_TASK_SUCCESS
        send(content: content, timeInterval: timeInterval, onComplete: onComplete)
    }
    
    static let FOCUS_CATE_TASK_SUCCESS = "taskSuccess"
}

struct NotifiMessage {
    var stage: TaskStage
    var epoch: Int
    var totalEpoch: Int
}
