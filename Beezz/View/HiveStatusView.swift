//
//  HiveStatusView.swift
//  Beezz
//
//  Created by Lorenzo Pizzuto on 07/03/25.
//


import SwiftUI

struct HiveStatusView: View {
    let beehive: Beehive
    
    // Funzione per generare eventi storici basati sull'arnia selezionata
    private func generateHistoryForHive() -> [HiveEvent] {
        // Se l'arnia è in pericolo, aggiungiamo eventi recenti relativi allo stato
        if beehive.status == .danger {
            return [
                HiveEvent(date: Date().addingTimeInterval(-3600), type: "Swarm Alert", value: beehive.soundFrequency / 50),
                HiveEvent(date: Date().addingTimeInterval(-86400), type: "Predator Detection", value: 6.2),
                HiveEvent(date: Date().addingTimeInterval(-172800), type: "Health Check", value: 72.5)
            ]
        } else if beehive.status == .technicalIssue {
            return [
                HiveEvent(date: Date().addingTimeInterval(-1800), type: "Connection Lost", value: 0),
                HiveEvent(date: Date().addingTimeInterval(-86400), type: "Battery Low", value: 15.3),
                HiveEvent(date: Date().addingTimeInterval(-172800), type: "Health Check", value: 88.2)
            ]
        } else {
            return [
                HiveEvent(date: Date().addingTimeInterval(-86400), type: "Health Check", value: 94.5),
                HiveEvent(date: Date().addingTimeInterval(-172800), type: "Maintenance", value: 2.1),
                HiveEvent(date: Date().addingTimeInterval(-259200), type: "Temperature Check", value: 35.2)
            ]
        }
    }
    
    // Calcolo dello stato di salute basato sullo stato e sulla frequenza
    private var healthScore: Double {
        switch beehive.status {
        case .normal:
            return min(95.0, 80.0 + (beehive.soundFrequency / 10))
        case .danger:
            return max(30.0, 60.0 - (beehive.soundFrequency / 10))
        case .technicalIssue:
            return 50.0 // Valore intermedio per problemi tecnici
        }
    }
    
    private var swarmingRisk: Double {
        if beehive.status == .danger {
            return beehive.soundFrequency / 50
        } else if beehive.status == .normal && beehive.soundFrequency > 220 {
            return beehive.soundFrequency / 100
        } else {
            return 0.8
        }
    }
    
    private var predatorRisk: Double {
        if beehive.status == .danger {
            return 6.2
        } else if beehive.status == .technicalIssue {
            return 0
        } else {
            return 1.4
        }
    }
    
    private var weakColonyRisk: Double {
        if beehive.status == .technicalIssue {
            return 0
        } else if beehive.status == .danger {
            return 5.8
        } else {
            return 0.8
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "hexagon.fill")
                        .foregroundColor(Color.orange)
                        .font(.title)
                    
                    VStack(alignment: .leading) {
                        Text(beehive.name)
                            .font(.title3).bold()
                            .foregroundColor(Color.orange)
                        
                        Text("Ultimo aggiornamento: 2 min fa")
                            .font(.caption2)
                            .foregroundColor(Color(.darkGray))
                    }
                    Spacer()
                }
                .padding()
                
                // Indicatore Centrale
                HoneycombGauge(value: healthScore)
                    .padding()
                
                // Griglia Stato
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    StatusCard(title: "Possible Swarming", value: swarmingRisk, color: Color.orange)
                    StatusCard(title: "Predators Presence", value: predatorRisk, color: Color.red)
                    StatusCard(title: "Weak Colony", value: weakColonyRisk, color: .gray)
                }
                .padding(.horizontal)
                
                // Info sul sito
                HStack {
                    Label {
                        Text("Site: \(beehive.site)")
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    if beehive.status != .technicalIssue {
                        Label {
                            Text("\(String(format: "%.1f", beehive.soundFrequency)) Hz")
                                .font(.subheadline)
                        } icon: {
                            Image(systemName: "waveform")
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Bottone Storico
                NavigationLink {
                    EventListView(events: generateHistoryForHive())
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
        .navigationTitle("Dettagli Arnia")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension HiveStatusView {
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
}

extension Double {
    func degreesToRadians() -> Double {
        return self * .pi / 180
    }
}

#Preview {
    HiveStatusView(beehive: Beehive(id: 2, name: "Hive 2", status: .danger, soundFrequency: 350.8, site: "Mountain Field"))
}





