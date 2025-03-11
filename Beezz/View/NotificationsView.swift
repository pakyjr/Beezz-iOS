//
//  NotificationsView.swift
//  Beezz
//
//  Created by Antonio Navarra on 06/03/25.
//


//
//  NotificationsView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    let notifications: [BeehiveNotification]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recent")) {
                    ForEach(notifications) { notification in
                        HStack {
                            Image(systemName: "hexagon.fill")
                                .foregroundColor(Color.honeyAmber)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(notification.message)
                                    .font(.subheadline)
                                
                                Text(timeAgo(date: notification.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Notifications")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                    .foregroundColor(Color.honeyAmber)
            )
        }
    }
    
    func timeAgo(date: Date) -> String {
        let minutes = Int(-date.timeIntervalSinceNow / 60)
        if minutes < 60 {
            return "\(minutes) min ago"
        } else {
            let hours = minutes / 60
            return "\(hours) hours ago"
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleNotifications = [
            BeehiveNotification(id: 1, message: "Hive 1 detected unusual activity", timestamp: Date().addingTimeInterval(-600)),
            BeehiveNotification(id: 2, message: "Hive 2 temperature rising", timestamp: Date().addingTimeInterval(-3600))
        ]
        
        NotificationsView(notifications: sampleNotifications)
    }
}
