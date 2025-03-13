//
//  HiveEvent.swift
//  Beezz
//
//  Created by Lorenzo Pizzuto on 07/03/25.
//

import Foundation

struct HiveEvent: Identifiable {
    let id = UUID()
    let date: Date
    let type: String
    let value: Double
    var icon: String {
        switch type {
        case "Swarm Alert": return "exclamationmark.triangle"
        case "Predator Detection": return "pawprint"
        default: return "heart.fill"
        }
    }
}
