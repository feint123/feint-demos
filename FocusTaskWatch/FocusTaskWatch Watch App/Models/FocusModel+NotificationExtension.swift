//
//  FocusModel+NotificationExtension.swift
//  FocusTaskWatch Watch App
//
//  Created by feint on 2023/2/17.
//

import Foundation
import WatchKit

extension FocusModel {
    /**
     重置发送成功的通知消息
     */
    func restSuccessNotification() {
        if let currentTaskLine = self.currentTaskLine {
            let currentItem = self.currentItem
            FocusNotification.sendSuccess(message: NotifiMessage(stage: currentTaskLine.currentNode.taskStage,
                                                                 epoch: currentTaskLine.epoch,
                                                                 totalEpoch: Int(currentItem.daliyFocusTarget)),
                                          timeInterval: currentTaskLine.currentNode.taskStage == .focus ?
                                          currentItem.focusIntervalSec - currentTaskLine.currentNode.timeCost + currentTaskLine.currentNode.overtime:
                                            currentItem.restIntervalSec - currentTaskLine.currentNode.timeCost + currentTaskLine.currentNode.overtime) {
                // doNothing
                
            }

        }
    }
}
