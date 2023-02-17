//
//  FocusTaskWatchApp.swift
//  FocusTaskWatch Watch App
//
//  Created by feint on 2023/2/16.
//

import SwiftUI
import UserNotifications

@main
struct FocusTaskWatch_Watch_AppApp: App {
    @StateObject var model = FocusModel()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(model)
                .onAppear {
                    let action = UNNotificationAction(identifier: "continue",
                                                      title: NSLocalizedString("Continue", comment: "continue"),
                                                      options: [.foreground])
                    let category = UNNotificationCategory(identifier: FocusNotification.FOCUS_CATE_TASK_SUCCESS,
                                                          actions: [action],
                                                          intentIdentifiers: [],
                                                          options: [])
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                }
        }
        
        WKNotificationScene(controller: NotificationController.self, category: FocusNotification.FOCUS_CATE_TASK_SUCCESS)
    }
}

class NotificationController: WKUserNotificationHostingController<NotificationView> {

    var content:UNNotificationContent!
    var date:Date!

    override var body: NotificationView {
        NotificationView(content: .constant(content))
    }

    override class var isInteractive: Bool { true }

    override func didReceive(_ notification: UNNotification) {
        content = notification.request.content
        date = notification.date
    }
    
    
}
