//
//  TaskDetailView.swift
//  focus Watch App
//
//  Created by feint on 2023/2/12.
//

import SwiftUI
import CompactSlider

struct TaskDetailView: View {

    @Binding var taskItem: TaskItem
    
    var body: some View {
        Form {
            Section("任务名称") {
                TextField("Item", text: $taskItem.description, prompt: Text("请输入名称"))
            }
            Section("专注时长") {
                CompactSlider(value: $taskItem.focusInterval, in: 10...60, step: 5) {
                    Text("时长")
                    Spacer()
                    Text("\(Int(taskItem.focusInterval))分钟")
                }.listRowInsets(
                    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                )
            }.padding(0)
            
            Section("休息时长") {
                CompactSlider(value: $taskItem.restInterval, in: 5...60, step: 5) {
                    Text("时长")
                    Spacer()
                    Text("\(Int(taskItem.restInterval))分钟")
                }.listRowInsets(
                    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                )
            }.padding(0)
            
            Section("每日目标") {
                CompactSlider(value: $taskItem.daliyFocusTarget, in: 1...6, step: 1) {
                    Text("次数")
                    Spacer()
                    Text("\(Int(taskItem.daliyFocusTarget))次")
                }.listRowInsets(
                    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                )
            }.padding(0)
        }
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(taskItem: .constant(TaskItem("Test")))
    }
}
