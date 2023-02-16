//
//  FocusTaskWatchApp.swift
//  FocusTaskWatch Watch App
//
//  Created by feint on 2023/2/16.
//

import SwiftUI

@main
struct FocusTaskWatch_Watch_AppApp: App {
    @StateObject var model = FocusModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(model)
        }
    }
}
