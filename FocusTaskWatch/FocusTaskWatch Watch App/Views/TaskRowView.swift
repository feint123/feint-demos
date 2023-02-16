//
//  TaskRowView.swift
//  FocusTask Watch App
//
//  Created by feint on 2023/2/15.
//

import SwiftUI

struct TaskRowView: View {
    @State private var showTaskDetail = false;
    
    @Binding var item:TaskItem
    
    var body: some View {
        Button {
            showTaskDetail = true
        } label: {
            HStack {
                Text(item.description).lineLimit(1)
                Spacer()
                Text("\(Int(item.focusInterval))分钟")
            }
            
        } // 首个元素受到保护，禁止删除
        .sheet(isPresented: $showTaskDetail) {
            TaskDetailView(taskItem: $item)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(NSLocalizedString("Done", comment: "a Done button")) {
                            showTaskDetail = false
                        }
                    }
                }
        }
    }
}

struct TaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        TaskRowView(item: .constant(TaskItem("")))
    }
}
