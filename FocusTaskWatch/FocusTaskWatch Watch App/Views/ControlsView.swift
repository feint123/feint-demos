//
//  ControlsView.swift
//  focus Watch App
//
//  Created by feint on 2023/2/12.
//

import SwiftUI

struct ControlsView: View {
    
    @EnvironmentObject private var model:FocusModel
    
    var body: some View {
            Grid {
                GridRow {
                    VStack {
                        Button {
                            model.stateMachine()
                        } label: {
                            Image(systemName: model.operatorDesc().0)
                        }
                        .tint(.yellow)
                        .font(.title2)
                        Text(model.operatorDesc().1)
                    }
                    
                    
                    VStack {
                        Button {
                            model.overtime(5 * 60.0)
                        } label: {
                            Image(systemName: "plus")
                        }
                        .tint(.blue)
                        .font(.title2)
                        Text("加5分钟")
                    }
                    
                }
                .disabled(model.isCompletedTodayTarget())
                
                Spacer()
                
                GridRow {
                    VStack {
                        Button {
                            model.resetTask()
                        } label: {
                            Image(systemName: "repeat")
                        }
                        .tint(.green)
                        .font(.title2)
                        Text("重置")
                    }
                    
                    VStack {
                        Button {
                            model.finishTask()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .tint(.red)
                        .font(.title2)
                        
                        Text("结束")
                    }
                }
                .disabled(!model.isStartTask())
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("操作")
        }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView().environmentObject(FocusModel())
    }
}
