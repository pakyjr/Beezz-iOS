//
//  ContentView.swift
//  Beezz
//
//  Created by Antonio Navarra on 03/03/25.
//

import SwiftUI

struct HomepageView: View {
    @State private var beehives: [Beehive] = [
        // Existing beehives
        Beehive(id: 1, name: "Hive 3", status: .technicalIssue, soundFrequency: 0, site: "Main Facility"),
        Beehive(id: 2, name: "Hive 2", status: .danger, soundFrequency: 350.8, site: "Mountain Field"),
        Beehive(id: 3, name: "Hive 1", status: .normal, soundFrequency: 215.2, site: "Main Facility"),
        Beehive(id: 4, name: "Hive 4", status: .normal, soundFrequency: 150.4, site: "Hill Field"),
        Beehive(id: 5, name: "Hive 5", status: .normal, soundFrequency: 200.3, site: "Laboratory"),
        Beehive(id: 6, name: "Hive 6", status: .normal, soundFrequency: 180.6, site: "Laboratory"),
        Beehive(id: 7, name: "Hive 7", status: .normal, soundFrequency: 245.0, site: "Mountain Field"),
        Beehive(id: 8, name: "Hive 8", status: .technicalIssue, soundFrequency: 0, site: "Hill Field"),
        Beehive(id: 9, name: "Hive 9", status: .danger, soundFrequency: 420.0, site: "Laboratory"),
        Beehive(id: 10, name: "Hive 10", status: .normal, soundFrequency: 198.7, site: "Main Facility"),
        Beehive(id: 11, name: "Hive 11", status: .normal, soundFrequency: 230.5, site: "Mountain Field"),
        Beehive(id: 12, name: "Hive 12", status: .normal, soundFrequency: 210.8, site: "Hill Field"),
        Beehive(id: 13, name: "Hive 13", status: .technicalIssue, soundFrequency: 0, site: "Main Facility"),
        Beehive(id: 14, name: "Hive 14", status: .normal, soundFrequency: 195.3, site: "Laboratory"),
        Beehive(id: 15, name: "Hive 15", status: .danger, soundFrequency: 380.2, site: "Mountain Field"),
        Beehive(id: 16, name: "Hive 16", status: .normal, soundFrequency: 225.9, site: "Hill Field"),
        Beehive(id: 17, name: "Hive 17", status: .normal, soundFrequency: 240.1, site: "Main Facility"),
        Beehive(id: 18, name: "Hive 18", status: .technicalIssue, soundFrequency: 0, site: "Laboratory"),
        Beehive(id: 19, name: "Hive 19", status: .normal, soundFrequency: 205.4, site: "Mountain Field"),
        Beehive(id: 20, name: "Hive 20", status: .danger, soundFrequency: 410.5, site: "Main Facility")
    ].sorted { $0.status.sortPriority < $1.status.sortPriority }
    
    @State private var notifications: [BeehiveNotification] = [
        BeehiveNotification(id: 1, message: "Hive 2:Possible swarming detected", timestamp: Date()),
        BeehiveNotification(id: 2, message: "Hive 4: Abnormal frequency detected", timestamp: Date().addingTimeInterval(-1800))
    ]
    
    @State private var showAddBeehive = false
    @State private var showNotifications = false
    @State private var selectedSite: String = "Main Facility"
    @State private var showSiteSelector = false
    @Environment(\.colorScheme) var colorScheme
    
    // Apiary-themed colors
    let honeycombYellow = Color(red: 0.98, green: 0.8, blue: 0.0)
    let honeyAmber = Color(red: 0.85, green: 0.6, blue: 0.0)
    let beeBlack = Color(red: 0.15, green: 0.15, blue: 0.15)
    
    // Available sites
    @State private var sites = ["Main Facility", "Mountain Field", "Hill Field", "Laboratory"]

    // Grid layout with 2 columns
    private var gridColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }
    
    var filteredBeehives: [Beehive] {
        if selectedSite == "All Hives" {
            return beehives.sorted { $0.status.sortPriority < $1.status.sortPriority }
        } else {
            return beehives
                .filter { $0.site == selectedSite }
                .sorted { $0.status.sortPriority < $1.status.sortPriority }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with light gradient similar to Apple Home
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color.black : Color(UIColor.systemGroupedBackground),
                        colorScheme == .dark ? Color.black.opacity(0.9) : Color(UIColor.systemGroupedBackground).opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // System status indicator (Apple Home style)
                    if !notifications.isEmpty {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("\(notifications.count) notifications to review")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)
                        )
                        .padding(.horizontal)
                        .padding(.top)
                        .onTapGesture {
                            showNotifications = true
                        }
                    }
                    
                    // Main dashboard
                    ScrollView {
                        VStack(alignment: .leading, spacing: 25) {
                            Spacer()
                            
                            // LazyVGrid for hives
                            LazyVGrid(columns: gridColumns, spacing: 16) {
                                // "Add" button (Apple Home style)
                                Button(action: {
                                    showAddBeehive = true
                                }) {
                                    AddBeehiveCardView(honeycombYellow: honeycombYellow, honeyAmber: honeyAmber)
                                }
                                
                                // Hive cards
                                ForEach(filteredBeehives) { beehive in
                                    BeehiveCardView(beehive: beehive, honeyAmber: honeyAmber)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button(action: {
                        showSiteSelector = true
                    }) {
                        HStack(spacing: 4) {
                            Text(selectedSite)
                                .font(.title.bold())
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 2)
                        .background(Color.clear)
                    },
                    trailing: HStack {
                        Button(action: {
                            // Action to show settings
                        }) {
                            Image(systemName: "gearshape")
                                .foregroundColor(honeyAmber)
                        }
                    }
                )
                .sheet(isPresented: $showAddBeehive) {
                    AddBeehiveView(honeyAmber: honeyAmber)
                }
                .sheet(isPresented: $showNotifications) {
                    NotificationsView(notifications: notifications, honeyAmber: honeyAmber)
                }
                .actionSheet(isPresented: $showSiteSelector) {
                    ActionSheet(
                        title: Text("Select Site"),
                        buttons: sites.map { site in
                            .default(Text(site)) {
                                selectedSite = site
                            }
                        } + [.cancel(Text("Cancel"))]
                    )
                }
            }
        }
    }
}

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
                    Text("Frequenza sonora")
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

struct StatusIndicatorView: View {
    let status: BeehiveStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            
            Text(status.rawValue)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.gray)
                .minimumScaleFactor(0.8)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct AddBeehiveCardView: View {
    let honeycombYellow: Color
    let honeyAmber: Color
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(UIColor.tertiarySystemBackground))
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(honeyAmber)
            }
            
            Text("Add")
                .font(.headline)
                .foregroundColor(honeyAmber)
            
            Text("a Hive")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .frame(minWidth:0, maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                )
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
                // Graph background area
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
                
                // Main graph line
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
                
                // Data points as small hexagons
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

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    let notifications: [BeehiveNotification]
    let honeyAmber: Color
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recent")) {
                    ForEach(notifications) { notification in
                        HStack {
                            Image(systemName: "hexagon.fill")
                                .foregroundColor(honeyAmber)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(notification.message)
                                    .font(.subheadline)
                                
                                Text(timeAgo(date: notification.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Notifications")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(honeyAmber)
            )
        }
    }
    
    func timeAgo(date: Date) -> String {
        let minutes = Int(-date.timeIntervalSinceNow / 60)
        if minutes < 60 {
            return "\(minutes) min ago"
        } else {
            let hours = minutes / 60
            return "\(hours) hours ago"
        }
    }
}

struct AddBeehiveView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var beehiveName = ""
    @State private var selectedRoom = "North Field"
    let honeyAmber: Color
    let rooms = ["North Field", "South Field", "Facility"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hive Details")) {
                    TextField("Hive Name", text: $beehiveName)
                    
                    Picker("Location", selection: $selectedRoom) {
                        ForEach(rooms, id: \.self) { room in
                            Text(room).tag(room)
                        }
                    }
                }
                
                Section(header: Text("Connection")) {
                    Button(action: {
                        // Wi-Fi configuration simulation
                    }) {
                        HStack {
                            Image(systemName: "wifi")
                            Text("Configure Wi-Fi Sensor")
                        }
                        .foregroundColor(honeyAmber)
                    }
                }
                
                Section(header: Text("Advanced Settings")) {
                    HStack {
                        Toggle("Emergency Notifications", isOn: .constant(true))
                    }
                }
            }
            .navigationTitle("Add Hive")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(honeyAmber),
                trailing: Button("Add") {
                    // Save action
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(beehiveName.isEmpty)
                .foregroundColor(beehiveName.isEmpty ? Color.gray : honeyAmber)
            )
        }
    }
}

// Data Models
struct Beehive: Identifiable, Hashable {
    let id: Int
    let name: String
    let status: BeehiveStatus
    let soundFrequency: Double
    let site: String
    
    static func == (lhs: Beehive, rhs: Beehive) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum BeehiveStatus: String {
    case normal = "Normal"
    case technicalIssue = "Offline"
    case danger = "Danger"
    
    var color: Color {
        switch self {
        case .normal: return .green
        case .technicalIssue: return .gray
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
    }
}

extension BeehiveStatus {
    var sortPriority: Int {
        switch self {
        case .danger: return 0
        case .technicalIssue: return 1
        case .normal: return 2
        }
    }
}
