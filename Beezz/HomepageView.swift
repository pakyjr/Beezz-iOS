//
//  ContentView.swift
//  Beezz
//
//  Created by Antonio Navarra on 03/03/25.
//

import SwiftUI

struct HomepageView: View {
    @State private var beehives: [Beehive] = [
        Beehive(id: 1, name: "Arnia 1", status: .normal, soundFrequency: 220.5),
        Beehive(id: 2, name: "Arnia 2", status: .warning, soundFrequency: 350.8),
        Beehive(id: 3, name: "Arnia 3", status: .normal, soundFrequency: 215.2),
        Beehive(id: 4, name: "Arnia 4", status: .danger, soundFrequency: 410.6)
    ]
    
    @State private var notifications: [BeehiveNotification] = [
        BeehiveNotification(id: 1, message: "Possibile sciamatura rilevata nell'Arnia 2", timestamp: Date()),
        BeehiveNotification(id: 2, message: "Arnia 4: Frequenza anomala rilevata", timestamp: Date().addingTimeInterval(-1800))
    ]
    
    @State private var showAddBeehive = false
    @Environment(\.colorScheme) var colorScheme
    
    // Colori a tema apiario
    let honeycombYellow = Color(red: 0.98, green: 0.8, blue: 0.0)
    let honeyAmber = Color(red: 0.85, green: 0.6, blue: 0.0)
    let beeBlack = Color(red: 0.15, green: 0.15, blue: 0.15)
    
    // Grid layout con 2 colonne
    private var gridColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }
    
    var body: some View {
        NavigationView {
            ZStack {

                VStack(spacing: 20) {
                    // Dashboard principale
                    ScrollView {
                        VStack(alignment: .leading, spacing: 25) {
                            // Titolo della sezione con icona ape
                            HStack {
                                Image(systemName: "ant")
                                    .foregroundColor(honeyAmber)
                                Text("Le tue arnie attive")
                                    .font(.headline)
                                    .foregroundColor(honeyAmber)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // LazyVGrid per le arnie
                            LazyVGrid(columns: gridColumns, spacing: 16) {
                                // Pulsante "Aggiungi" (prima posizione)
                                Button(action: {
                                    showAddBeehive = true
                                }) {
                                    AddBeehiveCardView(honeycombYellow: honeycombYellow, honeyAmber: honeyAmber)
                                }
                                
                                // Cards delle arnie
                                ForEach(beehives) { beehive in
                                    BeehiveCardView(beehive: beehive, honeyAmber: honeyAmber)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Beezz")
            .navigationBarItems(trailing:
                Button(action: {
                    // Azione per mostrare le notifiche
                }) {
                    Image(systemName: "bell")
                        .foregroundColor(honeyAmber)
                        .overlay(
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 8, y: -8)
                                .opacity(notifications.isEmpty ? 0 : 1)
                        )
                }
            )
            .sheet(isPresented: $showAddBeehive) {
                AddBeehiveView(honeyAmber: honeyAmber)
            }
        }
    }
}

struct BeehiveCardView: View {
    let beehive: Beehive
    let honeyAmber: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            // Header della card con nome e stato
            HStack {
                Text(beehive.name)
                    .font(.headline)
                Spacer()
                StatusIndicatorView(status: beehive.status)
            }
            
            Divider()
             
            
            // Dato principale: frequenza/suono con icona esagono
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundColor(honeyAmber)
                    Text("Frequenza sonora")
                        .font(.caption)
                }
                
                Text("\(beehive.soundFrequency, specifier: "%.1f") Hz")
                    .font(.title3)
                    .bold()
                    .foregroundColor(honeyAmber)
            }
            .padding(.vertical, 5)
            
            // Mini grafico con stile a tema api
            MiniGraphView(values: generateRandomValues(), color: beehive.status.color, accentColor: honeyAmber)
                .frame(height: 40)
                .padding(.top, 5)
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            }
        )
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(honeyAmber.opacity(0.3), lineWidth: 1)
        )
    }
    
    // Genera valori casuali per il grafico di esempio
    func generateRandomValues() -> [Double] {
        var values: [Double] = []
        for _ in 0...6 {
            values.append(Double.random(in: 0.2...0.9))
        }
        return values
    }
}

struct AddBeehiveCardView: View {
    let honeycombYellow: Color
    let honeyAmber: Color
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                // Pattern esagonale per il pulsante aggiungi
                Image(systemName: "hexagon.fill")
                    .resizable()
                    .frame(width: 60, height: 55)
                    .foregroundColor(honeycombYellow)
                
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
            
            Text("Aggiungi un'arnia")
                .font(.headline)
                .foregroundColor(honeyAmber)
            
            Spacer()
        }
        .frame(height: 180)
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            }
        )
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(honeycombYellow.opacity(0.5), lineWidth: 1.5)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
        )
    }
}

struct MiniGraphView: View {
    let values: [Double]
    let color: Color
    let accentColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Area sotto il grafico con colore molto leggero
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(values.count - 1)
                    
                    let startPoint = CGPoint(x: 0, y: height * (1 - CGFloat(values[0])))
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: startPoint)
                    
                    for index in 1..<values.count {
                        let point = CGPoint(
                            x: stepX * CGFloat(index),
                            y: height * (1 - CGFloat(values[index]))
                        )
                        path.addLine(to: point)
                    }
                    
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(color.opacity(0.1))
                
                // Linea principale del grafico
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(values.count - 1)
                    
                    let startPoint = CGPoint(x: 0, y: height * (1 - CGFloat(values[0])))
                    path.move(to: startPoint)
                    
                    for index in 1..<values.count {
                        let point = CGPoint(
                            x: stepX * CGFloat(index),
                            y: height * (1 - CGFloat(values[index]))
                        )
                        path.addLine(to: point)
                    }
                }
                .stroke(color, lineWidth: 2)
                
                // Punti dati come piccoli esagoni
                ForEach(0..<values.count, id: \.self) { index in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(values.count - 1)
                    let x = stepX * CGFloat(index)
                    let y = height * (1 - CGFloat(values[index]))
                    
                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 8))
                        .foregroundColor(accentColor)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

struct StatusIndicatorView: View {
    let status: BeehiveStatus
    
    var body: some View {
        HStack {
            Image(systemName: "hexagon.fill")
                .font(.system(size: 10))
                .foregroundColor(status.color)
            Text(status.rawValue)
                .font(.caption)
                .foregroundColor(status.color)
        }
    }
}

struct AddBeehiveView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var beehiveName = ""
    let honeyAmber: Color
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dettagli Arnia")) {
                    TextField("Nome arnia", text: $beehiveName)
                    
                    Button(action: {
                        // Simulazione configurazione Wi-Fi
                    }) {
                        HStack {
                            Image(systemName: "wifi")
                            Text("Configura sensore Wi-Fi")
                        }
                        .foregroundColor(honeyAmber)
                    }
                }
            }
            .navigationTitle("Aggiungi un'arnia")
            .navigationBarItems(
                leading: Button("Annulla") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(honeyAmber),
                trailing: Button("Salva") {
                    // Azione salvataggio
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(beehiveName.isEmpty)
                .foregroundColor(beehiveName.isEmpty ? Color.gray : honeyAmber)
            )
        }
    }
}

// Modelli dati
struct Beehive: Identifiable {
    let id: Int
    let name: String
    let status: BeehiveStatus
    let soundFrequency: Double
}

enum BeehiveStatus: String {
    case normal = "Normale"
    case warning = "Attenzione"
    case danger = "Pericolo"
    
    var color: Color {
        switch self {
        case .normal: return .green
        case .warning: return Color(red: 0.98, green: 0.8, blue: 0.0)  // Giallo miele
        case .danger: return .red
        }
    }
}

struct BeehiveNotification: Identifiable {
    let id: Int
    let message: String
    let timestamp: Date
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomepageView()
            .preferredColorScheme(.light)
        
        HomepageView()
            .preferredColorScheme(.dark)
    }
}
