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
    
    @State private var searchText = ""
    @State private var selectedFilter: NotificationFilter = .all
    @State private var selectedPeriod: TimePeriod = .day
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Combined search and filter bar
                VStack(spacing: 12) {
                    // Search bar
                    SearchBar(text: $searchText, placeholder: "Search notifications...")
                        .padding(.horizontal)
                    
                    // Combined filter row
                    HStack(spacing: 8) {
                        // Category filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterButton(title: "All", isSelected: selectedFilter == .all) {
                                    selectedFilter = .all
                                }
                                
                                FilterButton(title: "Alerts", icon: "exclamationmark.triangle.fill", color: .red, isSelected: selectedFilter == .alert) {
                                    selectedFilter = .alert
                                }
                                
                                FilterButton(title: "Warnings", icon: "exclamationmark.circle.fill", color: .yellow, isSelected: selectedFilter == .warning) {
                                    selectedFilter = .warning
                                }
                                
                                FilterButton(title: "Technical", icon: "wrench.fill", color: .gray, isSelected: selectedFilter == .technicalIssue) {
                                    selectedFilter = .technicalIssue
                                }
                            }
                        }
                        
                        Divider()
                            .frame(height: 20)
                        
                        // Time filters with shorter labels
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                PeriodButton(title: "24h", isSelected: selectedPeriod == .day) {
                                    selectedPeriod = .day
                                }
                                
                                PeriodButton(title: "7d", isSelected: selectedPeriod == .week) {
                                    selectedPeriod = .week
                                }
                                
                                PeriodButton(title: "30d", isSelected: selectedPeriod == .month) {
                                    selectedPeriod = .month
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Notifications count and mark all as read
                HStack {
                    Text("\(filteredNotifications.count) Notifications")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading)
                    
                    Spacer()
                    
                    if !filteredNotifications.isEmpty {
                        Button(action: {
                            // Mark all as read action would go here
                        }) {
                            Text("Mark All as Read")
                                .font(.caption)
                                .foregroundColor(Color.honeyAmber)
                        }
                        .padding(.trailing)
                    }
                }
                .padding(.vertical, 6)
                .background(Color(.systemGroupedBackground))
                
                // Notifications list
                List {
                    if filteredNotifications.isEmpty {
                        Text("No notifications found")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.vertical, 24)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredNotifications) { notification in
                            NotificationCell(notification: notification) {
                                onSelectHive(notification.hiveId)
                                presentationMode.wrappedValue.dismiss()
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    // Delete action would go here
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    // Mark as read action would go here
                                } label: {
                                    Label("Read", systemImage: "eye")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.honeyAmber)
                }
            }
        }
    }
    
    // Filter notifications based on search, category, and time period
    var filteredNotifications: [BeehiveNotification] {
        let periodFiltered = notifications.filter { notification in
            switch selectedPeriod {
            case .day:
                return Calendar.current.isDateInToday(notification.timestamp) ||
                       Calendar.current.isDateInYesterday(notification.timestamp)
            case .week:
                let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                return notification.timestamp >= sevenDaysAgo
            case .month:
                let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
                return notification.timestamp >= thirtyDaysAgo
            }
        }
        
        let categoryFiltered = selectedFilter == .all ? periodFiltered : periodFiltered.filter { notification in
            let message = notification.message.lowercased()
            switch selectedFilter {
            case .alert:
                return message.contains("alert") || message.contains("swarming") || message.contains("danger")
            case .warning:
                return message.contains("abnormal") || message.contains("warning")
            case .technicalIssue:
                return message.contains("offline") || message.contains("disconnected") || message.contains("technical")
            default:
                return true
            }
        }
        
        if searchText.isEmpty {
            return categoryFiltered.sorted(by: { $0.timestamp > $1.timestamp })
        } else {
            return categoryFiltered.filter { notification in
                notification.message.lowercased().contains(searchText.lowercased()) ||
                "Hive \(notification.hiveId)".lowercased().contains(searchText.lowercased())
            }.sorted(by: { $0.timestamp > $1.timestamp })
        }
    }
}

// MARK: - Helper Views

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.primary)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FilterButton: View {
    let title: String
    var icon: String? = nil
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? .white : color)
                        .font(.system(size: 10))
                }
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.honeyAmber : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
        }
    }
}

struct NotificationCell: View {
    let notification: BeehiveNotification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Severity icon with simplified design
                ZStack {
                    Circle()
                        .fill(severityColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: severityIcon)
                        .foregroundColor(severityColor)
                        .font(.system(size: 16))
                }
                
                // Content area
                VStack(alignment: .leading, spacing: 6) {
                    // Top row with message and timestamp
                    HStack(alignment: .top) {
                        Text(notification.message)
                            .font(.subheadline)
                            .lineLimit(2)
                            .foregroundColor(.primary)
                        
                        Spacer(minLength: 8)
                        
                        Text(timeAgo(date: notification.timestamp))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    // Bottom row with hive ID and status
                    HStack {
                        Text("Hive \(notification.hiveId)")
                            .font(.caption)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(Color.honeyAmber.opacity(0.15))
                            .foregroundColor(Color.honeyAmber)
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        // Status badge
                        statusBadge
                    }
                }
                
                // Discrete navigation indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Simplified status badge
    private var statusBadge: some View {
        Text(statusText)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.15))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
    
    // Status text based on notification content
    private var statusText: String {
        let message = notification.message.lowercased()
        if message.contains("swarming") || message.contains("danger") {
            return "CRITICAL"
        } else if message.contains("abnormal") || message.contains("warning") {
            return "WARNING"
        } else if message.contains("offline") || message.contains("disconnected") {
            return "OFFLINE"
        } else {
            return "INFO"
        }
    }
    
    // Status color based on status text
    private var statusColor: Color {
        switch statusText {
        case "CRITICAL":
            return .red
        case "WARNING":
            return .yellow
        case "OFFLINE":
            return .gray
        default:
            return Color.honeyAmber
        }
    }
    
    // Determine icon based on notification content
    var severityIcon: String {
        let message = notification.message.lowercased()
        if message.contains("swarming") || message.contains("danger") {
            return "exclamationmark.triangle.fill"
        } else if message.contains("abnormal") || message.contains("warning") {
            return "exclamationmark.circle.fill"
        } else if message.contains("offline") || message.contains("disconnected") {
            return "wifi.slash"
        } else {
            return "bell.fill"
        }
    }
    
    var severityColor: Color {
        let message = notification.message.lowercased()
        if message.contains("swarming") || message.contains("danger") {
            return .red
        } else if message.contains("abnormal") || message.contains("warning") {
            return .yellow
        } else if message.contains("offline") || message.contains("disconnected") {
            return .gray
        } else {
            return Color.honeyAmber
        }
    }
    
    func timeAgo(date: Date) -> String {
        let minutes = Int(-date.timeIntervalSinceNow / 60)
        if minutes < 1 {
            return "Just now"
        } else if minutes < 60 {
            return "\(minutes)m ago"
        } else if minutes < 1440 {
            let hours = minutes / 60
            return "\(hours)h ago"
        } else {
            let days = minutes / 1440
            return "\(days)d ago"
        }
    }
}

// MARK: - Helper Types

enum NotificationFilter {
    case all, alert, warning, technicalIssue
}

enum TimePeriod {
    case day, week, month
}
