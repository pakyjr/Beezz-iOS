//
//  BeehiveCardView.swift
//  Beezz
//
//  Created by Antonio Navarra on 06/03/25.
//


//
//  BeehiveCardView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI

struct BeehiveCardView: View {
    var beehive: Beehive
    let honeyAmber: Color
    
    var body: some View {
        NavigationLink(destination: TestView(beehive: beehive)) {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "hexagon.fill")
                        .foregroundColor(honeyAmber)
                        .font(.system(size: 14))
                        .frame(width: 20)
                    
                    Text(beehive.name)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .truncationMode(.tail)
                        .frame(minWidth: 60, maxWidth: .infinity, alignment: .leading)
                    
                    StatusIndicatorView(status: beehive.status)
                        .fixedSize()
                }
                .frame(height: 24)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Sound Frequency")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(beehive.soundFrequency, specifier: "%.1f")")
                            .font(.title2)
                            .bold()
                            .foregroundColor(honeyAmber)
                            .layoutPriority(1)
                        
                        Text("Hz")
                            .font(.subheadline)
                            .foregroundColor(honeyAmber)
                            .baselineOffset(-4)
                    }
                }
                
                Spacer()
                
                MiniGraphView(values: generateRandomValues(), color: beehive.status.color, accentColor: honeyAmber)
                    .frame(height: 40)
                    .padding(.top, 5)
            }
            .padding()
            .frame(height: 180)
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
            beehive: Beehive(id: 1, name: "Test Hive", status: .normal, soundFrequency: 250.0, site: "Main Facility"),
            honeyAmber: Color.orange
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}


