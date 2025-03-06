//
//  TestView.swift
//  Beezz
//
//  Created by Antonio Navarra on 05/03/25.
//

import SwiftUI

struct TestView: View {
    let beehive: Beehive
    
    var body: some View {
        List {
            Section(header: Text("Stato")) {
                HStack {
                    StatusIndicatorView(status: beehive.status)
                    Text(beehive.status.rawValue)
                }
            }
            
            Section(header: Text("Metriche")) {
                HStack {
                    Text("Frequenza")
                    Spacer()
                    Text("\(beehive.soundFrequency, specifier: "%.1f") Hz")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Ultimo aggiornamento")
                    Spacer()
                    Text(Date(), style: .time)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Posizione")) {
                Text(beehive.site)
            }
        }
        .navigationTitle(beehive.name)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView(beehive: Beehive(
            id: 1,
            name: "Arnia Test",
            status: .danger,
            soundFrequency: 350.8,
            site: "Laboratorio"
        ))
    }
}
