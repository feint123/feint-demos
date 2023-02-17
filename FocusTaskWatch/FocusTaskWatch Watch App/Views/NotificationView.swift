//
//  NotificationView.swift
//  FocusTaskWatch Watch App
//
//  Created by feint on 2023/2/16.
//

import SwiftUI
import UserNotifications
struct NotificationView: View {
    @Binding var content: UNNotificationContent
    @State private var epoch: Int = 0
    @State private var totoalEpoch: Int = 0
    var body: some View {
        VStack(alignment: .leading) {
            Text(content.title)
                .font(.title2)
                .bold()
                .foregroundStyle(LinearGradient(colors: [.green, .green.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
            
            Label(content.body, systemImage: "leaf")
            
            HStack {
                Text("进度")
                MilestoneProgressView(progress: .constant(CGFloat(epoch)), count: .constant(Float(totoalEpoch)))
            }
        
        }.onAppear {
            let arr = content.subtitle.split(separator: ":")
            epoch = Int(arr[0]) ?? 0
            totoalEpoch = Int(arr[1]) ?? 4
        }
        
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(content: .constant(UNNotificationContent()))
    }
}
