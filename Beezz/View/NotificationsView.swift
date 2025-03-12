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
    var onSelectHive: (Int) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recent").font(.caption).foregroundColor(Color.honeyAmber)) {
                    if notifications.isEmpty {
                        Text("No recent notifications")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(notifications) { notification in
                            Button(action: {
                                // Naviga all'arnia specifica quando cliccata
                                onSelectHive(notification.hiveId)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.honeyAmber.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "hexagon.fill")
                                            .foregroundColor(Color.honeyAmber)
                                            .font(.system(size: 18))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(notification.message)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        
                                        HStack {
                                            Text("Arnia \(notification.hiveId)")
                                                .font(.caption)
                                                .foregroundColor(Color.honeyAmber)
                                            
                                            Spacer()
                                            
                                            Text(timeAgo(date: notification.timestamp))
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Notifiche")
            .navigationBarItems(
                trailing: Button("Chiudi") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color.honeyAmber)
            )
        }
    }
    
    func timeAgo(date: Date) -> String {
        let minutes = Int(-date.timeIntervalSinceNow / 60)
        if minutes < 1 {
            return "Adesso"
        } else if minutes < 60 {
            return "\(minutes) min fa"
        } else if minutes < 1440 { 
            let hours = minutes / 60
            return "\(hours) ore fa"
        } else {
            let days = minutes / 1440
            return "\(days) giorni fa"
        }
    }
}
