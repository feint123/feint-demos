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
    
    var body: some View {
        VStack(alignment: .center) {
            Text(content.title)
                .font(.title)
                .bold()
                .foregroundStyle(LinearGradient(colors: [.green, .green.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
            
            Text(content.body)
        }
        
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(content: .constant(UNNotificationContent()))
    }
}
