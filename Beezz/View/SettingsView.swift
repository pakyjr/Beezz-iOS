//
//  SettingsView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var sites: [String] = ["Main Facility", "Mountain Field", "Hill Field", "Laboratory"]
    @State private var newSiteName: String = ""
    @State private var siteToEdit: String? = nil
    @State private var editedSiteName: String = ""
    @State private var showAddSiteDialog = false
    @State private var showEditSiteDialog = false
    @State private var showDeleteAlert = false
    @State private var technicalIssueAlertsEnabled = false
    @State private var siteToDelete: String? = nil
    @State private var frequencyCriticalEnabled = true
    @State private var frequencyAlertsEnabled = true
    
    private let sections = ["Site Management", "Notifications & Alerts", "Support & Info"]
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Site Management
                Section(header: Text("Sites")) {
                    ForEach(sites, id: \.self) { site in
                        HStack {
                            Text(site)
                            Spacer()
                            
                            // Edit button
                            Button(action: {
                                siteToEdit = site
                                editedSiteName = site
                                showEditSiteDialog = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            // Delete button
                            Button(action: {
                                siteToDelete = site
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    
                    // Add new site button
                    Button(action: {
                        newSiteName = ""
                        showAddSiteDialog = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Add New Site")
                        }
                    }
                }
                
                // MARK: - Notifications & Alerts
                Section(header: Text("Notifications & Alerts")) {
                    Toggle("Critical Frequency Alerts", isOn: $frequencyCriticalEnabled)
                    Toggle("Abnormal Frequency Alerts", isOn: $frequencyAlertsEnabled)
                    Toggle("Technical Issue Alerts", isOn: $technicalIssueAlertsEnabled)
                    
                    NavigationLink(destination: NotificationDetailView()) {
                        Text("Advanced Settings")
                    }
                }
                
                // MARK: - Support & Info
                Section(header: Text("Support & Info")) {
                    NavigationLink(destination: HelpGuideView()) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.blue)
                            Text("User Guide")
                        }
                    }
                    
                    NavigationLink(destination: ContactSupportView()) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("Contact Support")
                        }
                    }
                    
                    NavigationLink(destination: AboutAppView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("About App")
                        }
                    }
                }
                
                // MARK: - App Version
                Section {
                    HStack {
                        Spacer()
                        Text("Beezz v1.0.0")
                            .foregroundColor(.gray)
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            // Add Site Dialog
            .alert("Add New Site", isPresented: $showAddSiteDialog) {
                TextField("Site Name", text: $newSiteName)
                Button("Cancel", role: .cancel) {}
                Button("Add") {
                    if !newSiteName.isEmpty && !sites.contains(newSiteName) {
                        sites.append(newSiteName)
                    }
                }
            }
            // Edit Site Dialog
            .alert("Edit Site", isPresented: $showEditSiteDialog) {
                TextField("Site Name", text: $editedSiteName)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    if let index = sites.firstIndex(of: siteToEdit ?? ""),
                       !editedSiteName.isEmpty && !sites.contains(editedSiteName) {
                        sites[index] = editedSiteName
                    }
                }
            }
            // Delete Site Confirmation
            .alert("Delete Site", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let site = siteToDelete, let index = sites.firstIndex(of: site) {
                        sites.remove(at: index)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this site? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Helper Views

struct NotificationDetailView: View {
    @State private var criticalAlertLevel = 350.0
    @State private var warningAlertLevel = 300.0
    @State private var silentHours = false
    @State private var silentStartTime = Date()
    // Default silent period: 8 hours from current time
    @State private var silentEndTime = Date().addingTimeInterval(8*3600)
    
    var body: some View {
        List {
            Section(header: Text("Alert Thresholds")) {
                VStack(alignment: .leading) {
                    Text("Critical Threshold (Hz): \(Int(criticalAlertLevel))")
                    Slider(value: $criticalAlertLevel, in: 250...450, step: 10)
                        .tint(.red)
                }
                
                VStack(alignment: .leading) {
                    Text("Warning Threshold (Hz): \(Int(warningAlertLevel))")
                    Slider(value: $warningAlertLevel, in: 200...400, step: 10)
                        .tint(.yellow)
                }
            }
            
            Section(header: Text("Silent Hours")) {
                Toggle("Enable Silent Hours", isOn: $silentHours)
                
                if silentHours {
                    DatePicker("Start", selection: $silentStartTime, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $silentEndTime, displayedComponents: .hourAndMinute)
                }
            }
        }
        .navigationTitle("Advanced Settings")
    }
}

struct HelpGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hive Monitoring Section
                GroupBox(label: Label("Hive Monitoring", systemImage: "house.fill")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Beezz allows real-time monitoring of your hives' status.")
                            .font(.body)
                        Text("• Green indicates normal operation")
                        Text("• Yellow requires verification")
                        Text("• Red indicates swarming or emergency")
                        Text("• Gray means sensor malfunction")
                    }
                    .padding(.vertical, 5)
                }
                
                // Frequency Interpretation Section
                GroupBox(label: Label("Frequency Analysis", systemImage: "waveform")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bee sounds indicate different activities:")
                            .font(.body)
                        Text("• 180-250 Hz: Normal activity")
                        Text("• 250-350 Hz: Stress/disease")
                        Text("• >350 Hz: Possible swarming")
                        Text("• 0 Hz: Sensor failure")
                    }
                    .padding(.vertical, 5)
                }
                
                // Notifications Section
                GroupBox(label: Label("Notification Management", systemImage: "bell.fill")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Customize alerts according to your needs:")
                            .font(.body)
                        Text("• Set custom thresholds")
                        Text("• Choose alert types")
                        Text("• Configure silent hours")
                        Text("• Toggle daily summary")
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding()
        }
        .navigationTitle("User Guide")
    }
}

struct ContactSupportView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var showingSentConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("Your Details")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            Section(header: Text("Message")) {
                ZStack(alignment: .topLeading) {
                    if message.isEmpty {
                        Text("Describe your issue or question...")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    TextEditor(text: $message)
                        .frame(minHeight: 150)
                }
            }
            
            Section {
                Button(action: {
                    // TODO: Implement send logic
                    showingSentConfirmation = true
                }) {
                    Text("Send Message")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(name.isEmpty || email.isEmpty || message.isEmpty)
            }
        }
        .navigationTitle("Contact Support")
        .alert("Message Sent", isPresented: $showingSentConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Thank you for contacting us. We'll respond within 24 hours.")
        }
    }
}

struct AboutAppView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.diamond")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
                .padding()
            
            Text("Beezz")
                .font(.largeTitle)
                .bold()
            
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Beezz is a hive monitoring solution for professional and hobby beekeepers to track colony health through acoustic analysis.")
                    
                    Text("The app uses sound frequency detection to identify swarming, diseases, and technical issues.")
                }
                .padding(5)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text("© 2025 Beezz. All rights reserved.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .navigationTitle("About App")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview Provider
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

