//
//  TaskView.swift
//  focus Watch App
//
//  Created by feint on 2023/2/12.
//

import SwiftUI

struct TaskView: View {
    
    @EnvironmentObject private var model: FocusModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($model.items) { $item in
                    TaskRowView(item: $item)
                        .deleteDisabled(item.id == model.items[0].id)
                }
                .onDelete { indexSet in
                    if let first = indexSet.first {
                        model.items.remove(at: first)
                    }
                }
                
            }
            .tabViewStyle(.carousel)
            .toolbar(content: {
                VStack {
                    TextFieldLink() {
                        Label("新建任务", systemImage: "plus.circle.fill")
                    } onSubmit: {
                        model.items.append(TaskItem($0))
                    }
                    
                    Spacer().frame(height: 5.0)
                    
                }
            })
            .navigationTitle("任务列表")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: model.items) { newValue in
                
                model.save()
            }
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            TaskView().environmentObject(FocusModel())
        }
    }
}

