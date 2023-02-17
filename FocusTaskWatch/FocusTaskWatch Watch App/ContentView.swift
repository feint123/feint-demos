//
//  ContentView.swift
//  FocusTask Watch App
//
//  Created by feint on 2023/2/12.
//

import SwiftUI
import UserNotifications


struct ContentView: View {

    @EnvironmentObject private var model: FocusModel
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showTimeLine = false
    
    var body: some View {
        
        StartPageView()
        .sheet(isPresented: $model.showSummary, content: {
            FocusSuccessView()
        })
        .onAppear {
//             请求通知权限
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print(error)
                }
            }
        }
        .onChange(of: scenePhase) { newValue in
            // dosomething
        }
    }
}

enum FocusTab {
    case controls, main, timeline, tasklist, nowPlaying, success
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(FocusModel())
    }
}
