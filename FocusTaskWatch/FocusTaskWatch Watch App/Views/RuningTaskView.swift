//
//  TimelineView.swift
//  focus Watch App
//
//  Created by feint on 2023/2/12.
//

import SwiftUI
import WatchKit
struct RuningTaskView: View {
    
    @EnvironmentObject private var model: FocusModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if (model.showTimeline) {
//                    FocusTimelineView()
                }
            }
            .toolbar(.hidden)
        }
        .onTapGesture {
            model.stateMachine()
        }
    }
}


struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        RuningTaskView().environmentObject(FocusModel())
    }
}
