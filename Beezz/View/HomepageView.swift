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
        BeehiveNotification(id: 1, message: "Hive 2: Possible swarming detected", timestamp: Date()),
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomepageView()
            .preferredColorScheme(.light)
    }
}
