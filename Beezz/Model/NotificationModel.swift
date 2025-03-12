//
//  NotificationModel.swift
//  Beezz
//
//  Created on 11/03/25.
//

import Foundation
import SwiftUICore

struct Notification: Identifiable {
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
    }
    
    // Optional property for notification type with default value
    var type: NotificationType = .warning
    
    // Optional details that can be displayed in a detailed view
    var details: String?
    
    // Computed property to format the date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    // Factory method to create a warning notification
    static func createWarning(for hiveId: Int, message: String) -> Notification {
        Notification(
            id: UUID().hashValue,
            message: message,
            timestamp: Date(),
            hiveId: hiveId,
            type: .warning
        )
    }
    
    // Factory method to create a danger notification
    static func createDanger(for hiveId: Int, message: String) -> Notification {
        Notification(
            id: UUID().hashValue,
            message: message,
            timestamp: Date(),
            hiveId: hiveId,
            type: .danger
        )
    }
    
    // Factory method to create an info notification
    static func createInfo(for hiveId: Int, message: String) -> Notification {
        Notification(
            id: UUID().hashValue,
            message: message,
            timestamp: Date(),
            hiveId: hiveId,
            type: .info
        )
    }
    
    // Factory method to create a technical issue notification
    static func createTechnicalIssue(for hiveId: Int, message: String) -> Notification {
        Notification(
            id: UUID().hashValue,
            message: message,
            timestamp: Date(),
            hiveId: hiveId,
            type: .technicalIssue
        )
    }
}

// Extension to make the model conform to Equatable for comparison
extension Notification: Equatable {
    static func == (lhs: Notification, rhs: Notification) -> Bool {
        return lhs.id == rhs.id
    }
}
