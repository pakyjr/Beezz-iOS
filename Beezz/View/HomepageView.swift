//
//  HomepageView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI

struct HomepageView: View {
    @State private var beehives: [Beehive] = [
        // Existing beehives
        Beehive(id: 1, name: "Hive 3", status: .technicalIssue, soundFrequency: 0, site: "Main Facility"),
        Beehive(id: 2, name: "Hive 2", status: .danger, soundFrequency: 350.8, site: "Mountain Field"),
        Beehive(id: 3, name: "Hive 1", status: .normal, soundFrequency: 215.2, site: "Main Facility"),
        Beehive(id: 4, name: "Hive 4", status: .warning, soundFrequency: 280.4, site: "Hill Field"),
        Beehive(id: 5, name: "Hive 5", status: .normal, soundFrequency: 200.3, site: "Laboratory"),
        Beehive(id: 6, name: "Hive 6", status: .normal, soundFrequency: 180.6, site: "Laboratory"),
        Beehive(id: 7, name: "Hive 7", status: .normal, soundFrequency: 245.0, site: "Mountain Field"),
        Beehive(id: 8, name: "Hive 8", status: .technicalIssue, soundFrequency: 0, site: "Hill Field"),
        Beehive(id: 9, name: "Hive 9", status: .danger, soundFrequency: 420.0, site: "Laboratory"),
        Beehive(id: 10, name: "Hive 10", status: .normal, soundFrequency: 198.7, site: "Main Facility"),
        Beehive(id: 11, name: "Hive 11", status: .normal, soundFrequency: 230.5, site: "Mountain Field"),
        Beehive(id: 12, name: "Hive 12", status: .warning, soundFrequency: 290.8, site: "Hill Field"),
        Beehive(id: 13, name: "Hive 13", status: .technicalIssue, soundFrequency: 0, site: "Main Facility"),
        Beehive(id: 14, name: "Hive 14", status: .normal, soundFrequency: 195.3, site: "Laboratory"),
        Beehive(id: 15, name: "Hive 15", status: .danger, soundFrequency: 380.2, site: "Mountain Field"),
        Beehive(id: 16, name: "Hive 16", status: .normal, soundFrequency: 225.9, site: "Hill Field"),
        Beehive(id: 17, name: "Hive 17", status: .normal, soundFrequency: 240.1, site: "Main Facility"),
        Beehive(id: 18, name: "Hive 18", status: .technicalIssue, soundFrequency: 0, site: "Laboratory"),
        Beehive(id: 19, name: "Hive 19", status: .warning, soundFrequency: 275.4, site: "Mountain Field"),
        Beehive(id: 20, name: "Hive 20", status: .danger, soundFrequency: 410.5, site: "Main Facility")
    ].sorted { $0.status.sortPriority < $1.status.sortPriority }
    
   
    @State private var notifications: [BeehiveNotification] = []
    /*
     BeehiveNotification(id: 1, message: "Hive 2: Possible swarming detected", timestamp: Date(), hiveId: 2),
        BeehiveNotification(id: 2, message: "Hive 4: Abnormal frequency detected", timestamp: Date().addingTimeInterval(-1800),hiveId: 4)
    */
    
    @State private var showAddBeehive = false
    @State private var showNotifications = false
    @State private var selectedSite: String = "Main Facility"
    @State private var showSiteSelector = false
    @State private var showSettings = false
    @State private var showSoundAnalysis = false
    @State private var selectedHive: Beehive?
    @State private var showHiveDetail = false
    @Environment(\.colorScheme) var colorScheme
    
    
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
                            // LazyVGrid for hives
                            LazyVGrid(columns: gridColumns, spacing: 16) {
                                // "Add" button (Apple Home style)
                                Button(action: {
                                    showAddBeehive = true
                                }) {
                                    AddBeehiveCardView()
                                }
                                // Hive cards
                                ForEach(filteredBeehives) { beehive in
                                    BeehiveCardView(beehive: beehive)
                                        .onTapGesture {
                                            selectedHive = beehive
                                            showHiveDetail = true
                                        }
                                }
                            }
                        }
                        .padding(.horizontal,4)
                        .padding(.vertical)
                    }
                    .padding(.top)
                }
                
                // Simple Bee-themed Sound Analysis Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showSoundAnalysis = true
                        }) {
                            ZStack {
                                // Simple yellow background
                                Circle()
                                    .foregroundColor(colorScheme == .dark ? .yellow : .honeyAmber.opacity(0.8))
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                
                                // Sound wave icon in the center
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
