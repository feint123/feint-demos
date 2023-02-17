//
//  StartPageView.swift
//  focus Watch App
//
//  Created by feint on 2023/2/13.
//

import SwiftUI

struct StartPageView: View {
    
    @EnvironmentObject private var model: FocusModel
    
    @State private var selection: FocusTab = .main
    
    var body: some View {
        TabView(selection: $selection) {
            // 控制面板
            NavigationStack {
                ControlsView()
            }.tag(FocusTab.controls)
            // 主视图
            NavigationStack {
                MainView()
            }.tag(FocusTab.main)
            // 任务列表
            NavigationStack {
                TaskView()
            }.tag(FocusTab.tasklist)
        }
        .onChange(of: model.currentTaskLine?.currentNode.state, perform: { _ in
            withAnimation {
                selection = .main
            }
        })
    }
}

struct StartPageView_Previews: PreviewProvider {
    static var previews: some View {
        StartPageView().environmentObject(FocusModel())
    }
}
