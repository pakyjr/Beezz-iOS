//
//  StatusCard.swift
//  Beezz
//
//  Created by Lorenzo Pizzuto on 07/03/25.
//


import SwiftUI

struct StatusCard: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(color)
                .padding(8)
                .background(Circle().fill(color.opacity(0.2)))
            
            VStack(alignment: .leading) {
                Text("\(value, specifier: "%.1f")%")
                    .font(.headline).bold()
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var iconName: String {
        switch title {
        case "Possible Swarming": return "exclamationmark.triangle"
        case "Predators Presence": return "pawprint"
        default: return "heart.slash"
        }
    }
}
