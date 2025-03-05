//  HiveStatusView.swift
//  Beezz
//
//  Created by Antonio Navarra on 05/03/25.
//

import SwiftUI
import Darwin

// MARK: - Estensione Colori
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF)/255,
            green: Double((rgb >> 8) & 0xFF)/255,
            blue: Double(rgb & 0xFF)/255
        )
    }
    
    static let swarmOrange = Color.orange
    static let predatorRed = Color(hex: "CC0000")
    static let hiveBackground = Color(hex: "FFF9E6")
    static let mediumOrange = Color(hex: "FFB347")
    static let honeyYellow = Color(hex: "FFD700")
}

// MARK: - Componenti Forma
struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let side = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        for i in 0..<6 {
            let angle = Double(i) * 60 - 30
            let point = CGPoint(
                x: center.x + side * Darwin.cos(angle.degreesToRadians()),
                y: center.y + side * Darwin.sin(angle.degreesToRadians())
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

extension Double {
    func degreesToRadians() -> Double {
        return self * .pi / 180
    }
}

// MARK: - Componenti Interfaccia
struct HoneycombGauge: View {
    let value: Double
    
    var body: some View {
        ZStack {
            HexagonShape()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .swarmOrange, location: 0),
                            .init(color: .mediumOrange, location: 0.5),
                            .init(color: .honeyYellow, location: 1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    HexagonShape()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.5), .clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: .swarmOrange.opacity(0.3), radius: 15, x: 0, y: 5)
                .frame(width: 200, height: 200)
            
            VStack(spacing: 8) {
                Text("\(value, specifier: "%.1f")%")
                    .font(.system(size: 42, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                Text("Stato Normale")
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(0.9)
            }
        }
    }
}

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

// MARK: - Vista Principale
struct HiveStatusView: View {
    let historyData = [
        HiveEvent(date: Date().addingTimeInterval(-86400), type: "Swarm Alert", value: 8.2),
        HiveEvent(date: Date().addingTimeInterval(-172800), type: "Predator Detection", value: 3.1),
        HiveEvent(date: Date().addingTimeInterval(-259200), type: "Health Check", value: 94.5)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: "hexagon.fill")
                            .foregroundColor(.swarmOrange)
                            .font(.title)
                        
                        VStack(alignment: .leading) {
                            Text("Hiven.1329")
                                .font(.title3).bold()
                                .foregroundColor(.swarmOrange)
                            
                            Text("Ultimo aggiornamento: 2 min fa")
                                .font(.caption2)
                                .foregroundColor(Color(.darkGray))
                        }
                        Spacer()
                    }
                    .padding()
                    
                    // Indicatore Centrale
                    HoneycombGauge(value: 92.5)
                        .padding()
                    
                    // Griglia Stato
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        StatusCard(title: "Possible Swarming", value: 7, color: .swarmOrange)
                        StatusCard(title: "Predators Presence", value: 2, color: .predatorRed)
                        StatusCard(title: "Weak Colony", value: 0.8, color: .gray)
                    }
                    .padding(.horizontal)
                    
                    // Bottone Storico
                    NavigationLink {
                        EventListView(events: historyData)
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Storico Ultimi 7 Giorni")
                        }
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct EventListView: View {
    let events: [HiveEvent]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(events) { event in
                    HistoryRow(event: event)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Eventi Recenti")
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Componenti Storico
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
        case "Swarm Alert": return .swarmOrange
        case "Predator Detection": return .predatorRed
        default: return .gray
        }
    }
}

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

// MARK: - Anteprima
struct HiveStatusView_Previews: PreviewProvider {
    static var previews: some View {
        HiveStatusView()
    }
}
