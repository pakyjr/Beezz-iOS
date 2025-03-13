//
//  BeehiveCardView.swift
//  Beezz
//
//  Created by Antonio Navarra on 06/03/25.
//


import SwiftUI

struct BeehiveCardView: View {
    var beehive: Beehive
    
    var body: some View {
        NavigationLink(destination: BeehiveDetailView(beehive: beehive)) {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 8) {
                    ZStack {
                        // Esagono di sfondo per lo stato
                        Image(systemName: "hexagon.fill")
                            .foregroundColor(beehive.status.color.opacity(0.2))
                            .font(.system(size: 18))
                        
                        // Bordo dell'esagono colorato in base allo stato
                        Image(systemName: "hexagon")
                            .foregroundColor(beehive.status.color)
                            .font(.system(size: 18))
                        
                        // Piccolo indicatore all'interno dell'esagono
                        Circle()
                            .fill(beehive.status.color)
                            .frame(width: 6, height: 6)
                    }
                    .frame(width: 24, height: 24)
                    
                    Text(beehive.name)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .truncationMode(.tail)
                        .frame(minWidth: 60, maxWidth: .infinity, alignment: .leading)

                }
                .frame(height: 24)
                
                Divider()
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Sound Frequency")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Aggiungiamo la descrizione dello stato
                        Text(beehive.status.rawValue)
                            .font(.caption)
                            .foregroundColor(beehive.status.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(beehive.status.color.opacity(0.1))
                            )
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(beehive.soundFrequency, specifier: "%.1f")")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.honeyAmber)
                            .layoutPriority(1)
                        
                        Text("Hz")
                            .font(.subheadline)
                            .foregroundColor(Color.honeyAmber)
                            .baselineOffset(-4)
                    }
                }
                
                Spacer()
                
                MiniGraphView(values: generateRandomValues(), color: beehive.status.color, accentColor: Color.honeyAmber)
                    .frame(height: 40)
                    .padding(.top, 5)
                
                // Aggiungiamo informazioni aggiuntive
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("Updated today")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.top, 5)
            }
            .padding()
            .frame(height: 200) // Aumentato leggermente per ospitare le nuove informazioni
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func generateRandomValues() -> [Double] {
        var values: [Double] = []
        for _ in 0...6 {
            values.append(Double.random(in: 0.2...0.9))
        }
        return values
    }
}

struct BeehiveCardView_Previews: PreviewProvider {
    static var previews: some View {
        BeehiveCardView(
            beehive: Beehive(id: 1, name: "Test Hive", status: .normal, soundFrequency: 250.0, site: "Main Facility"))
        .previewLayout(.sizeThatFits)
        .padding()
        .preferredColorScheme(.light)
        
        BeehiveCardView(
            beehive: Beehive(id: 2, name: "Alert Hive", status: .warning, soundFrequency: 325.5, site: "North Field"))
        .previewLayout(.sizeThatFits)
        .padding()
        .preferredColorScheme(.dark)
    }
}
