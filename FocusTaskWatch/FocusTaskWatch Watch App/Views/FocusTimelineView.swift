//
//  FocusTimelineView.swift
//  focus Watch App
//
//  Created by feint on 2023/2/14.
//

import SwiftUI

struct FocusTimelineView: View {
    
    @EnvironmentObject private var model: FocusModel
    
    @Binding var showText: Bool
    @Binding var gaugeWidth: Double
    
    var body: some View {
        if (model.isStartTask()) {
            TimelineView(FocusTimelineSchedule(from: model.taskStartDate,
                                               isPaused: model.isPauseTask())) { timeline in
                let interval = timeline.date.timeIntervalSince(model.taskStartDate)
                let taskLine = model.currentTaskLine!
                let item = model.getTaskItemById(model.currentTaskId!)
                let maxValue = (taskLine.currentNode.taskStage == .rest ? item.restIntervalSec : item.focusIntervalSec) + taskLine.currentNode.overtime
                FocusTimerView(current: .constant(interval > maxValue ? maxValue : interval), maxValue: .constant(maxValue), showText: $showText, gaugeWidth: $gaugeWidth)
                    .padding(-5)
            }
        } else {
            FocusTimerView(current: .constant(0), maxValue: .constant(0), showText: $showText, gaugeWidth: $gaugeWidth)
                .padding(-5)
        }
    }
}

struct FocusTimelineSchedule: TimelineSchedule {
    var startDate: Date
    var isPaused: Bool

    init(from startDate: Date, isPaused: Bool) {
        self.startDate = startDate
        self.isPaused = isPaused
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        var baseSchedule = PeriodicTimelineSchedule(from: self.startDate,
                                                    by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
            .entries(from: startDate, mode: mode)
        return AnyIterator<Date> {
            guard !isPaused else { return nil }
            return baseSchedule.next()
        }
    }
}


struct FocusTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        FocusTimelineView(showText: .constant(true), gaugeWidth: .constant(15.0)).environmentObject(FocusModel())
    }
}
