//
//  HomepageView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI

struct HomepageView: View {
    @State private var beehives: [Beehive] = [
        Beehive(id: 1, name: "Hive 3", status: .technicalIssue, soundFrequency: 0, site: "Main Facility"),
        Beehive(id: 2, name: "Hive 2", status: .danger, soundFrequency: 350.8, site: "Mountain Field"),
        Beehive(id: 3, name: "Hive 1", status: .normal, soundFrequency: 215.2, site: "Main Facility"),
        Beehive(id: 4, name: "Hive 4", status: .warning, soundFrequency: 280.4, site: "Hill Field"),
        Beehive(id: 5, name: "Hive 5", status: .normal, soundFrequency: 200.3, site: "Hill Field"),
        Beehive(id: 6, name: "Hive 6", status: .normal, soundFrequency: 180.6, site: "Hill Field"),
        Beehive(id: 7, name: "Hive 7", status: .normal, soundFrequency: 245.0, site: "Mountain Field"),
        Beehive(id: 8, name: "Hive 8", status: .technicalIssue, soundFrequency: 0, site: "Hill Field"),
        Beehive(id: 9, name: "Hive 9", status: .danger, soundFrequency: 420.0, site: "Mountain Field"),
        Beehive(id: 10, name: "Hive 10", status: .normal, soundFrequency: 198.7, site: "Main Facility"),
        Beehive(id: 11, name: "Hive 11", status: .normal, soundFrequency: 230.5, site: "Mountain Field"),
        Beehive(id: 12, name: "Hive 12", status: .warning, soundFrequency: 290.8, site: "Hill Field"),
        Beehive(id: 13, name: "Hive 13", status: .technicalIssue, soundFrequency: 0, site: "Main Facility"),
        Beehive(id: 14, name: "Hive 14", status: .normal, soundFrequency: 195.3, site: "Main Facility"),
        Beehive(id: 15, name: "Hive 15", status: .danger, soundFrequency: 380.2, site: "Mountain Field"),
        Beehive(id: 16, name: "Hive 16", status: .normal, soundFrequency: 225.9, site: "Hill Field"),
        Beehive(id: 17, name: "Hive 17", status: .normal, soundFrequency: 240.1, site: "Hill Field"),
        Beehive(id: 18, name: "Hive 18", status: .technicalIssue, soundFrequency: 0, site: "Main Facility"),
        Beehive(id: 19, name: "Hive 19", status: .warning, soundFrequency: 275.4, site: "Main Facility"),
        Beehive(id: 20, name: "Hive 20", status: .danger, soundFrequency: 410.5, site: "Main Facility")
    ].sorted { $0.status.sortPriority < $1.status.sortPriority }
    
    @State private var notifications: [BeehiveNotification] = [
        BeehiveNotification(
            id: 1,
            message: "Possible swarming detected",
            timestamp: Date(),
            hiveId: 2,
            isRead: false,
            type: .danger,
            details: "High frequency readings (420.5 Hz) indicate potential swarming behavior. Immediate inspection recommended."
        ),
        BeehiveNotification(
            id: 2,
            message: "Abnormal frequency detected",
            timestamp: Date().addingTimeInterval(-1800),
            hiveId: 4,
            isRead: false,
            type: .warning,
            details: "Sound frequency (280.4 Hz) outside normal range detected. Colony may be under stress."
        ),
        BeehiveNotification(
            id: 3,
            message: "Sensor disconnected",
            timestamp: Date().addingTimeInterval(-3600 * 5),
            hiveId: 8,
            isRead: true,
            type: .technicalIssue,
            details: "No data received from sensors since 09:00. Check connectivity and power supply."
        ),
        BeehiveNotification(
            id: 4,
            message: "Temperature spike detected",
            timestamp: Date().addingTimeInterval(-3600 * 12),
            hiveId: 12,
            isRead: false,
            type: .warning,
            details: "Temperature reached 38.2°C, which is 5°C above normal range. Check ventilation."
        ),
        BeehiveNotification(
            id: 6,
            message: "Queen activity reduced",
            timestamp: Date().addingTimeInterval(-3600 * 48),
            hiveId: 9,
            isRead: false,
            type: .warning,
            details: "Queen bee activity has decreased by 30%. Possible signs of queen health issues."
        ),
        BeehiveNotification(
            id: 7,
            message: "Critical temperature alarm",
            timestamp: Date().addingTimeInterval(-3600 * 72),
            hiveId: 15,
            isRead: false,
            type: .danger,
            details: "Temperature has reached critical levels (41°C). Immediate cooling measures required."
        ),
        BeehiveNotification(
            id: 9,
            message: "Battery low",
            timestamp: Date().addingTimeInterval(-3600 * 120),
            hiveId: 13,
            isRead: false,
            type: .technicalIssue,
            details: "Sensor battery level at 15%. Please replace batteries within the next 48 hours."
        ),
        BeehiveNotification(
            id: 10,
            message: "Pest detection alert",
            timestamp: Date().addingTimeInterval(-3600 * 144),
            hiveId: 7,
            isRead: false,
            type: .danger,
            details: "Acoustic signatures matching Varroa mite infestation detected. Immediate treatment recommended."
        )
    ]
        
    @State private var showAddBeehive = false
    @State private var showNotifications = false
    @State private var selectedSite: String = "Main Facility"
    @State private var showSiteSelector = false
    @State private var showSettings = false
    @State private var showSoundAnalysis = false
    @State private var selectedHive: Beehive?
    @State private var showHiveDetail = false
    @Environment(\.colorScheme) var colorScheme
    
    @State private var sites = ["Main Facility", "Mountain Field", "Hill Field", "Laboratory"]

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
                    
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            if filteredBeehives.isEmpty {
                                Button(action: {
                                    showAddBeehive = true
                                }) {
                                    AddBeehiveCardView()
                                }
                            } else {
                                ForEach(filteredBeehives) { beehive in
                                    BeehiveCardView(beehive: beehive)
                                        .onTapGesture {
                                            selectedHive = beehive
                                            showHiveDetail = true
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                        
                    }
                    .padding(.top)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showSoundAnalysis = true
                        }) {
                            ZStack {
                                Circle()
                                    .foregroundColor(colorScheme == .dark ? .yellow : .honeyAmber.opacity(0.8))
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "microphone.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.black.opacity(0.8))
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
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
                                .padding(.top)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                                .padding(.top)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 2)
                        .background(Color.clear)
                    },
                    trailing: HStack {
                        Button(action: {
                            showAddBeehive = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foregroundColor(.honeyAmber)
                                .padding(.top)
                                .padding(.trailing, 8)
                        }
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .foregroundColor(.honeyAmber)
                                .padding(.top)
                                .padding(.trailing, 4)
                        }
                    }
                )
                .sheet(isPresented: $showAddBeehive) {
                    AddBeehiveView()
                }
                .sheet(isPresented: $showNotifications) {
                    NotificationsView(
                        notifications: notifications,
                        onSelectHive: { hiveId in
                            showNotifications = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                selectedHive = beehives.first(where: { $0.id == hiveId })
                                showHiveDetail = true
                            }
                        }
                    )
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $showSoundAnalysis) {
                    SoundAnalysisView()
                }
                .sheet(isPresented: $showHiveDetail) {
                    if let hive = selectedHive {
                        BeehiveDetailView(beehive: hive)
                    }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomepageView()
            .preferredColorScheme(.light)
    }
}
