//
//  FocusSuccessView.swift
//  focus Watch App
//
//  Created by feint on 2023/2/12.
//

import SwiftUI
import UserNotifications
import WatchKit

struct FocusSuccessView: View {

    @EnvironmentObject private var model: FocusModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)

                Text("目标达成")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(LinearGradient(colors: [.green, .green.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
            }
            Text("当前任务: \(model.getTaskItemById(model.currentTaskId ?? UUID()).description)")
                .lineLimit(1)
                .padding()
            Spacer()
            
//            Button {
//
//            } label: {
//                Label("继续专注", systemImage: "book")
//            }.tint(.yellow)
            
            Button {
                model.showSummary = false
            } label: {
                Text("返回")
            }
        }
        .navigationBarHidden(true)
    }
}

struct FocusSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        FocusSuccessView()
            .environmentObject(FocusModel())
    }
}
