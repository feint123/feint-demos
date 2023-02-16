//
//  FocusTimerView.swift
//  focus Watch App
//
//  Created by feint on 2023/2/12.
//

import SwiftUI
import Charts

struct FocusTimerView: View {
    @Binding var current: Double
    @Binding var maxValue: Double    
    @Binding var showText: Bool
    @Binding var gaugeWidth: Double
    
    @State private var minValue: Double = 0.0
    
    @EnvironmentObject private var model:FocusModel
    
 
    
    var body: some View {
        VStack {
                Gauge(value: current, in: minValue...maxValue) {
                    if (showText) {
                        VStack {
                            Text(model.formatTime())
                                .font(.title)
                                .bold()
                                .monospacedDigit()
                            Text(model.currentTaskLine?.currentNode.taskStage == .rest ? "休息中" : model.getTaskItemById(model.currentTaskId ?? UUID()).description)
                                .lineLimit(1)
                                .frame(maxWidth: 60)
                        }
                    }
                }
                .gaugeStyle(FocusGaugeStyle(size: $gaugeWidth))
                .tint(.green)

        }.onChange(of: current) { newValue in
            model.update(newValue)
        }
    }
}

struct FocusTimerView_Previews: PreviewProvider {
    static var previews: some View {
        FocusTimerView(current: .constant(0.0), maxValue: .constant(25.0 * 60), showText: .constant(true), gaugeWidth: .constant(15.0))
            .environmentObject(FocusModel())
    }
}
