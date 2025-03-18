//
//  NotificationModel.swift
//  Beezz
//
//  Created on 11/03/25.
//

import Foundation
import SwiftUI

struct BeehiveNotification: Identifiable {
    let id: Int
    let message: String
    let timestamp: Date
    let hiveId: Int
    var isRead: Bool = false
    
    // Notification types enum
    enum NotificationType {
        case warning
        case danger
        case info
        case technicalIssue
        
        var icon: String {
            switch self {
            case .warning:
                return "exclamationmark.triangle.fill"
            case .danger:
                return "exclamationmark.octagon.fill"
            case .info:
                return "info.circle.fill"
            case .technicalIssue:
                return "wrench.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .warning:
                return .orange
            case .danger:
                return .red
            case .info:
                return .blue
            case .technicalIssue:
                return .gray
            }
        }
        
        var sortPriority: Int {
            switch self {
            case .danger:
                return 0
            case .warning:
                return 1
            case .technicalIssue:
                return 2
            case .info:
                return 3
            }
        }
    }
    
    // Property for notification type with default value
    var type: NotificationType = .warning
    
    // Optional details that can be displayed in a detailed view
    var details: String?
    
    // Optional action that can be taken from the notification
    var actionText: String?
    var actionHandler: (() -> Void)?
    
    // Computed property to format the date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    // Computed property to determine if the notification is recent (less than 24 hours old)
    var isRecent: Bool {
        return Date().timeIntervalSince(timestamp) < 86400
    }
    
    // Factory method to create a warning notification
    static func createWarning(for hiveId: Int, message: String, details: String? = nil) -> BeehiveNotification {
        BeehiveNotification(
            id: UUID().hashValue,
            message: message,
            timestamp: Date(),
            hiveId: hiveId,
            isRead: false,
            type: .warning,
            details: details
        )
    }
    
    // Factory method to create a danger notification
    static func createDanger(for hiveId: Int, message: String, details: String? = nil) -> BeehiveNotification {
        BeehiveNotification(
            id: UUID().hashValue,
            message: message,
            timestamp: Date(),
            hiveId: hiveId,
            isRead: false,
            type: .danger,
            details: details
        )
    }
    
    // Factory method to create an info notification
    static func createInfo(for hiveId: Int, message: String, details: String? = nil) -> BeehiveNotification {
        BeehiveNotification(
            id: UUID().hashValue,
            message: message,
            timestamp: Date(),
            hiveId: hiveId,
            isRead: false,
            type: .info,
            details: details
        )
    }
    
    // Factory method to create a technical issue notification
    static func createTechnicalIssue(for hiveId: Int, message: String, details: String? = nil) -> BeehiveNotification {
        BeehiveNotification(
            id: UUID().hashValue,
            message: message,
            timestamp: Date(),
            hiveId: hiveId,
            isRead: false,
            type: .technicalIssue,
            details: details
        )
    }
    
    // Helper method to create sample notifications for testing
    static func createSampleNotifications() -> [BeehiveNotification] {
        [
            BeehiveNotification.createDanger(
                for: 2,
                message: "Swarming Alert! High activity detected",
                details: "Frequency readings indicate potential swarming behavior. Immediate attention required."
            ),
            BeehiveNotification.createWarning(
                for: 4,
                message: "Abnormal frequency detected",
                details: "Sound frequency outside normal range detected. Check colony status."
            ),
            BeehiveNotification.createTechnicalIssue(
                for: 3,
                message: "Sensor disconnected",
                details: "No data received from sensors since 09:00. Check connectivity."
            ),
            BeehiveNotification.createInfo(
                for: 1,
                message: "Hive inspection reminder",
                details: "Scheduled inspection due today. Last inspection was 2 weeks ago."
            ),
        ]
    }
    
    // Helper method to mark notification as read
    mutating func markAsRead() {
        isRead = true
    }
}

// Extension to make the model conform to Equatable for comparison
extension BeehiveNotification: Equatable {
    static func == (lhs: BeehiveNotification, rhs: BeehiveNotification) -> Bool {
        return lhs.id == rhs.id
    }
}

// Extension for the notification filter options
extension BeehiveNotification {
    enum FilterOption {
        case all
        case unread
        case warning
        case danger
        case technicalIssue
        
        var displayName: String {
            switch self {
            case .all: return "All"
            case .unread: return "Unread"
            case .warning: return "Warnings"
            case .danger: return "Alerts"
            case .technicalIssue: return "Technical Issues"
            }
        }
    }
    
    enum TimePeriod {
        case day
        case week
        case month
        case all
        
        var displayName: String {
            switch self {
            case .day: return "24 Hours"
            case .week: return "7 Days"
            case .month: return "30 Days"
            case .all: return "All Time"
            }
        }
    }
}
