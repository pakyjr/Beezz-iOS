//
//  HistoryRow.swift
//  Beezz
//
//  Created by Lorenzo Pizzuto on 07/03/25.
//


import SwiftUI

struct HistoryRow: View {
    let event: HiveEvent
    
    var body: some View {
        HStack {
            Image(systemName: event.icon)
                .foregroundColor(colorForType)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(event.type)
                    .font(.subheadline)
                Text(event.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(event.value, specifier: "%.1f")%")
                .font(.callout).bold()
                .foregroundColor(colorForType)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var colorForType: Color {
        switch event.type {
        case "Swarm Alert": return Color.orange
        case "Predator Detection": return .predatorRed
        default: return .gray
        }
    }
}
