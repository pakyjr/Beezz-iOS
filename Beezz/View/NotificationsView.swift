import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    let notifications: [BeehiveNotification]
    var onSelectHive: (Int) -> Void
    
    @State private var searchText = ""
    @State private var selectedFilter: BeehiveNotification.FilterOption?
    @State private var selectedPeriod: BeehiveNotification.TimePeriod = .day
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Compact filter bar
                    compactFilterBar
                    
                    // Notifications list
                    notificationsListView
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                            .foregroundColor(.honeyAmber)
                            .font(.body.bold())
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                filterSheetView
            }
        }
    }
    
    // MARK: - Component Views
    
    private var compactFilterBar: some View {
        VStack(spacing: 0) {
            HStack {
                // Search bar
                SearchBar(text: $searchText, placeholder: "Search notifications...")
                
                // Filter button
                Button(action: {
                    showFilterSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(selectedFilter != nil || selectedPeriod != .day ? Color.honeyAmber : .primary)
                        
                        if selectedFilter != nil || selectedPeriod != .day {
                            Text(String(filteredNotifications.count))
                                .font(.caption2)
                                .padding(4)
                                .background(Color.honeyAmber)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Active filters chips
            if selectedFilter != nil || selectedPeriod != .day {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if let filter = selectedFilter {
                            filterChip(
                                label: filter.displayName,
                                icon: iconForFilter(filter),
                                action: { selectedFilter = nil }
                            )
                        }
                        
                        if selectedPeriod != .day {
                            filterChip(
                                label: selectedPeriod.displayName,
                                icon: "calendar",
                                action: { selectedPeriod = .day }
                            )
                        }
                        
                        if selectedFilter != nil || selectedPeriod != .day {
                            Button(action: {
                                selectedFilter = nil
                                selectedPeriod = .day
                            }) {
                                Text("Clear All")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    private func filterChip(label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                }
                
                Text(label)
                    .font(.footnote)
                
                Image(systemName: "xmark")
                    .font(.system(size: 10))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.honeyAmber.opacity(0.15))
            .foregroundColor(Color.honeyAmber)
            .cornerRadius(16)
        }
    }
    
    private var filterSheetView: some View {
        NavigationView {
            Form {
                Section(header: Text("Notification Type")) {
                    Button(action: {
                        selectedFilter = nil
                    }) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.primary)
                                .frame(width: 24)
                            
                            Text("All Types")
                            
                            Spacer()
                            
                            if selectedFilter == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color.honeyAmber)
                            }
                        }
                    }
                    
                    ForEach(BeehiveNotification.FilterOption.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                        }) {
                            HStack {
                                Image(systemName: iconForFilter(filter))
                                    .foregroundColor(colorForFilter(filter))
                                    .frame(width: 24)
                                
                                Text(filter.displayName)
                                
                                Spacer()
                                
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.honeyAmber)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Time Period")) {
                    ForEach(BeehiveNotification.TimePeriod.allCases, id: \.self) { period in
                        Button(action: {
                            selectedPeriod = period
                        }) {
                            HStack {
                                Text(period.displayName)
                                
                                Spacer()
                                
                                if selectedPeriod == period {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.honeyAmber)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showFilterSheet = false
                    }
                    .foregroundColor(Color.honeyAmber)
                }
            }
        }
    }
    
    private var notificationsListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if filteredNotifications.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredNotifications) { notification in
                        NotificationCell(notification: notification) {
                            onSelectHive(notification.hiveId)
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .contextMenu {
                            Button(action: {
                                // Mark as read action
                            }) {
                                Label(notification.isRead ? "Mark as Unread" : "Mark as Read", systemImage: notification.isRead ? "eye.slash" : "eye")
                            }
                            
                            Button(role: .destructive, action: {
                                // Delete action
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        
                        Divider()
                            .padding(.leading, 70)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No notifications")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text("Try changing your filters or check back later")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                selectedFilter = nil
                selectedPeriod = .day
                searchText = ""
            }) {
                Text("Reset Filters")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.honeyAmber)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    // MARK: - Helper Methods
    
    private func iconForFilter(_ filter: BeehiveNotification.FilterOption) -> String {
        switch filter {
        case .warning:
            return "exclamationmark.triangle.fill"
        case .danger:
            return "exclamationmark.octagon.fill"
        case .technicalIssue:
            return "wrench.fill"
        }
    }
    
    private func colorForFilter(_ filter: BeehiveNotification.FilterOption) -> Color {
        switch filter {
        case .warning:
            return .orange
        case .danger:
            return .red
        case .technicalIssue:
            return .gray
        }
    }
    
    // MARK: - Filtering Logic
    
    var filteredNotifications: [BeehiveNotification] {
        // Filter by time period
        let periodFiltered = notifications.filter { notification in
            switch selectedPeriod {
            case .day:
                return Date().timeIntervalSince(notification.timestamp) < 86400
            case .week:
                return Date().timeIntervalSince(notification.timestamp) < 604800
            case .month:
                return Date().timeIntervalSince(notification.timestamp) < 2592000
            case .all:
                return true
            }
        }
        
        // Filter by notification type
        let typeFiltered = periodFiltered.filter { notification in
            if let filter = selectedFilter {
                switch filter {
                case .warning:
                    return notification.type == .warning
                case .danger:
                    return notification.type == .danger
                case .technicalIssue:
                    return notification.type == .technicalIssue
                }
            } else {
                return true // No type filter applied, show all
            }
        }
        
        // Filter by search text
        if searchText.isEmpty {
            // Sort by priority and timestamp
            return typeFiltered.sorted { (a, b) -> Bool in
                if a.type.sortPriority != b.type.sortPriority {
                    return a.type.sortPriority < b.type.sortPriority
                }
                return a.timestamp > b.timestamp
            }
        } else {
            // Filter by search text and sort
            return typeFiltered.filter { notification in
                notification.message.lowercased().contains(searchText.lowercased()) ||
                "Hive \(notification.hiveId)".lowercased().contains(searchText.lowercased())
            }.sorted { (a, b) -> Bool in
                if a.type.sortPriority != b.type.sortPriority {
                    return a.type.sortPriority < b.type.sortPriority
                }
                return a.timestamp > b.timestamp
            }
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

struct NotificationCell: View {
    let notification: BeehiveNotification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Notification icon
                ZStack {
                    Circle()
                        .fill(notification.type.color.opacity(0.15))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: notification.type.icon)
                        .foregroundColor(notification.type.color)
                        .font(.system(size: 18))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    // Message
                    Text(notification.message)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    // Bottom row
                    HStack(spacing: 10) {
                        // Hive badge
                        HStack(spacing: 4) {
                            Image(systemName: "hexagon.fill")
                                .font(.system(size: 10))
                            
                            Text("\(notification.hiveId)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.honeyAmber.opacity(0.15))
                        .foregroundColor(Color.honeyAmber)
                        .cornerRadius(10)
                        
                        // Time ago
                        Text(timeAgo(date: notification.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.trailing, 4)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    // Unread indicator
                    if !notification.isRead {
                        Circle()
                            .fill(Color.honeyAmber)
                            .frame(width: 8, height: 8)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 8, height: 8)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
            .opacity(notification.isRead ? 0.8 : 1)
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Preview

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(
            notifications: BeehiveNotification.createSampleNotifications(),
            onSelectHive: { _ in }
        )
    }
}
