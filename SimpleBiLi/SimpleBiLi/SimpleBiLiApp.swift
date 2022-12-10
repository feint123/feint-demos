//
//  SimpleBiLiApp.swift
//  SimpleBiLi
//
//  Created by feint on 2022/12/10.
//

import SwiftUI

@main
struct SimpleBiLiApp: App {
    @StateObject var fetcher = BiliFetcher()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(fetcher)
        }
    }
}
