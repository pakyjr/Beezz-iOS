//
//  BeehiveModel.swift
//  Beezz
//
//  Created by Antonio Navarra on 06/03/25.
//

import Foundation
import SwiftUI

// Data Models
struct Beehive: Identifiable, Hashable {
    let id: Int
    var name: String
    let status: BeehiveStatus
    let soundFrequency: Double
    let site: String
    let notes: String
    let lastNotesUpdate: Date?
    
    static func == (lhs: Beehive, rhs: Beehive) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Init with default values for notes
    init(id: Int, name: String, status: BeehiveStatus, soundFrequency: Double, site: String, notes: String = "", lastNotesUpdate: Date? = nil) {
        self.id = id
        self.name = name
        self.status = status
        self.soundFrequency = soundFrequency
        self.site = site
        self.notes = notes
        self.lastNotesUpdate = lastNotesUpdate
    }
}

enum BeehiveStatus: String {
    case normal = "Normal"
    case warning = "Warning"
    case technicalIssue = "Offline"
    case danger = "Danger"
    
    var color: Color {
        switch self {
        case .normal: return .green
        case .technicalIssue: return .gray
        case .warning: return .yellow
        case .danger: return .red
        }
    }
    
    var sortPriority: Int {
        switch self {
        case .danger: return 0
        case .warning: return 1
        case .technicalIssue: return 2
        case .normal: return 3
        }
    }
}
