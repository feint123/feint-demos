//
//  MainView.swift
//  focus Watch App
//
//  Created by feint on 2023/2/12.
//

import SwiftUI

struct MainView: View {

    @EnvironmentObject private var model: FocusModel
    @State private var showTaskList: Bool = false
    @State private var showTimeline: Bool = false
    @State private var timeline: Double = 5.0
    var body: some View {
        VStack {
            HStack {
                if(!showTimeline) {
                    VStack(alignment:.leading) {
                        
                        Text(model.getTaskItemById(model.currentTaskId ?? UUID()).description)
                            .font(.footnote)
                            .lineLimit(1)
                        Text(model.formatTime())
                            .monospacedDigit()
                            .font(.title3)
                    }
                    Spacer()
                }
                
                FocusTimelineView(showText: $showTimeline, gaugeWidth: $timeline)
                    .frame(width: showTimeline ? nil : 45, height: showTimeline ? nil : 45)
                    .onTapGesture {
                        model.stateMachine()
                    }

            }
            .padding(showTimeline ? [.top] : [.top, .leading, .trailing])
            .padding(EdgeInsets(top: 0, leading: 0, bottom: -4, trailing: 0))
                                
            if(!showTimeline) {
                MilestoneProgressView(progress: .constant(CGFloat(model.currentTaskLine?.epoch ?? 0)),
                                      count: .constant(Float(model.getTaskItemById(model.currentTaskId ?? UUID()).daliyFocusTarget)))
                .padding([.bottom])
            
                
                Button {
                    model.stateMachine()
                } label: {
                    Label(model.operatorDesc().1, systemImage: model.operatorDesc().0)
                }
                .listStyle(.elliptical)
                .foregroundStyle(model.isCompletedTodayTarget() ? LinearGradient(colors: [.green, .green.opacity(0.5)], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .buttonStyle(.bordered).tint(.blue)
                .disabled(model.isCompletedTodayTarget())
                
                Button {
                    showTaskList = true
                } label: {
                    Label(model.getTaskItemById(model.currentTaskId ?? UUID()).description, systemImage: "tag")
                }
                .disabled(model.isStartTask())
                .listStyle(.elliptical)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .buttonStyle(.bordered).tint(.yellow)
            }
            
        }
        .onChange(of: model.showTimeline, perform: { newValue in
            withAnimation {
                showTimeline = newValue
                timeline = showTimeline ? 15.0 : 5.0
            }
        })
        .navigationTitle("feintk")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(showTimeline ? .hidden : .visible)
        .sheet(isPresented: $showTaskList) {
            List {
                ForEach($model.items) { $item in
                    Button {
                        // 选择任务
                        model.chooseTask(item.id)
                        showTaskList = false
                    } label: {
                        HStack {
                            Text(item.description)
                            Spacer()
                            Text("\(Int(item.focusInterval))分钟")
                        }
                    }
                }
            }
            
        }
       
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(FocusModel())
    }
}
