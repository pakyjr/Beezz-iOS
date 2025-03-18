//
//  BeehiveDetailView.swift
//  Beezz
//
//  Created on 11/03/25.
//

import SwiftUI
import Charts

struct BeehiveDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var beehive: Beehive
    @State private var isEditingName = false
    @State private var newName: String
    @State private var showDeleteAlert = false
    @State private var showDisconnectAlert = false
    @State private var showFullHistory = false
    
    // Chart interaction states
    @State private var selectedDataPoint: FrequencyRecord?
    @State private var showDataPointInfo = false
    
    // Sample frequency history data
    @State private var frequencyHistory: [FrequencyRecord] = [
        FrequencyRecord(date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), value: 215.4),
        FrequencyRecord(date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), value: 225.8),
        FrequencyRecord(date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), value: 248.2),
        FrequencyRecord(date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), value: 260.5),
        FrequencyRecord(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), value: 310.7),
        FrequencyRecord(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), value: 290.3),
        FrequencyRecord(date: Date(), value: 240.1)
    ]
    
    // Thresholds for frequency values
    private let normalThreshold: Double = 250.0
    private let dangerThreshold: Double = 350.0
    
    // Date formatter for display
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Date formatter for chart labels
    private let chartDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()
    
    init(beehive: Beehive) {
        _beehive = State(initialValue: beehive)
        _newName = State(initialValue: beehive.name)
    }
    
    var statusMessage: String {
        switch beehive.status {
        case .normal:
            return "The colony is in good condition. No problems detected."
        case .warning:
            return "Anomaly detected. It is recommended to monitor the colony."
        case .danger:
            return "Alert! Abnormal sound frequency. Possible swarming or colony in danger."
        case .technicalIssue:
            return "Technical problem. Sensor offline or data not available."
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                // Current status section
                statusSection
                
                // Chart section
                chartSection
                
                // History section
                historySection
                
                // Beekeeper Notes section
                notesSection
                
                // Actions section
                actionsSection
                
                
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color.black : Color(UIColor.systemGroupedBackground),
                    colorScheme == .dark ? Color.black.opacity(0.9) : Color(UIColor.systemGroupedBackground).opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if isEditingName {
                    TextField("Hive Name", text: $newName, onCommit: {
                        beehive.name = newName
                        isEditingName = false
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 150)
                } else {
                    HStack {
                        Text(beehive.name)
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                StatusIndicatorView(status: beehive.status)
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Hive"),
                message: Text("Are you sure you want to delete this hive? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    // Handle delete action
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showFullHistory) {
            HistoryView(records: frequencyHistory)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center) {
            Image(systemName: "hexagon.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.honeyAmber)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("ID: \(beehive.id)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Site: \(beehive.site)")
                    .font(.headline)
            }
            .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Status")
                .font(.headline)
                .foregroundColor(.honeyAmber)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: statusIcon)
                        .foregroundColor(beehive.status.color)
                    Text(statusMessage)
                        .font(.subheadline)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.gray)
                    Text("Last analysis: \(dateFormatter.string(from: Date()))")
                        .font(.subheadline)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: beehive.status == .technicalIssue ? "wifi.slash" : "wifi")
                        .foregroundColor(beehive.status == .technicalIssue ? .red : .green)
                    Text("Sensor: \(beehive.status == .technicalIssue ? "Disconnected" : "Connected")")
                        .font(.subheadline)
                }
                
                if beehive.status != .technicalIssue {
                    Divider()
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("Current frequency:")
                            .font(.subheadline)
                        
                        Text("\(beehive.soundFrequency, specifier: "%.1f")")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color.honeyAmber)
                        
                        Text("Hz")
                            .font(.subheadline)
                            .foregroundColor(Color.honeyAmber)
                            .baselineOffset(-1)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Frequency Trend")
                .font(.headline)
                .foregroundColor(.honeyAmber)
            
            VStack(alignment: .leading, spacing: 8) {
                if beehive.status != .technicalIssue {
                    ZStack(alignment: .top) {
                        // Data point popup
                        if let selectedPoint = selectedDataPoint, showDataPointInfo {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Date: \(dateFormatter.string(from: selectedPoint.date))")
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showDataPointInfo = false
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                HStack {
                                    Text("Frequency:")
                                        .font(.caption)
                                    
                                    Text("\(selectedPoint.value, specifier: "%.1f") Hz")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(frequencyColor(for: selectedPoint.value))
                                }
                                
                                HStack {
                                    Text("Status:")
                                        .font(.caption)
                                    
                                    Text(frequencyStatusText(for: selectedPoint.value))
                                        .font(.caption)
                                        .foregroundColor(frequencyColor(for: selectedPoint.value))
                                }
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.tertiarySystemBackground))
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            )
                            .transition(.opacity)
                        }

                        Chart {
                            // Plot frequency data
                            ForEach(frequencyHistory) { record in
                                LineMark(
                                    x: .value("Date", record.date),
                                    y: .value("Frequency", record.value)
                                )
                                .foregroundStyle(Color.honeyAmber)
                                .symbol {
                                    Circle()
                                        .fill(frequencyColor(for: record.value))
                                        .frame(width: 10, height: 10)
                                }
                                .symbolSize(selectedDataPoint?.id == record.id ? 120 : 60)
                            }
                            
                            if let selected = selectedDataPoint {
                                PointMark(
                                    x: .value("Date", selected.date),
                                    y: .value("Frequency", selected.value)
                                )
                                .foregroundStyle(frequencyColor(for: selected.value))
                                .symbolSize(200)
                            }
                            
                            // Add normal threshold rule
                            RuleMark(y: .value("Normal", normalThreshold))
                                .foregroundStyle(.green.opacity(0.5))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .annotation(position: .leading) {
                                    Text("Normal")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                }
                            
                            // Add warning threshold rule
                            RuleMark(y: .value("Danger", dangerThreshold))
                                .foregroundStyle(.red.opacity(0.5))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .annotation(position: .leading) {
                                    Text("Danger")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                }
                        }
                        .chartOverlay { proxy in
                            GeometryReader { geometry in
                                Rectangle()
                                    .fill(Color.clear)
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let xPosition = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                                guard xPosition >= 0, xPosition <= geometry[proxy.plotAreaFrame].width else {
                                                    return
                                                }
                                                
                                                let data = frequencyHistory
                                                let stepWidth = geometry[proxy.plotAreaFrame].width / CGFloat(data.count - 1)
                                                let index = min(Int(xPosition / stepWidth), data.count - 1)
                                                
                                                selectedDataPoint = data[index]
                                                showDataPointInfo = true
                                            }
                                    )
                            }
                        }
                        .frame(height: 250)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                if let date = value.as(Date.self) {
                                    AxisValueLabel {
                                        Text(chartDateFormatter.string(from: date))
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .padding(.top, showDataPointInfo ? 80 : 0)
                    }
                    .animation(.easeInOut(duration: 0.2), value: showDataPointInfo)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("Data not available")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Text("The sensor is disconnected or not working.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Beekeeper Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Notes")
                    .font(.headline)
                    .foregroundColor(.honeyAmber)
                
                Spacer()
                
                Button(action: {
                    // Edit notes action
                }) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if !beehive.notes.isEmpty {
                    Text(beehive.notes)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    HStack {
                        Spacer()
                        Text("No notes available")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .italic()
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
                
                HStack {
                    Spacer()
                    Text("Last updated: \(formatDate(beehive.lastNotesUpdate))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // Format date for notes update
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - History Section
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Analysis History")
                    .font(.headline)
                    .foregroundColor(.honeyAmber)
                
                Spacer()
                
                Button(action: {
                    showFullHistory = true
                }) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            VStack(spacing: 0) {
                if beehive.status != .technicalIssue {
                    ForEach(frequencyHistory.prefix(5).reversed()) { record in
                        VStack(spacing: 0) {
                            HStack {
                                Text(dateFormatter.string(from: record.date))
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(record.value, specifier: "%.1f")")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(frequencyColor(for: record.value))
                                    
                                    Text("Hz")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Image(systemName: frequencyStatusIcon(for: record.value))
                                    .foregroundColor(frequencyColor(for: record.value))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            
                            if record != frequencyHistory.prefix(5).last {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        Text("No data available")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.honeyAmber)
            
            VStack(spacing: 0) {
                Button(action: {
                    isEditingName = true
                }) {
                    HStack {
                        Image(systemName: "pencil")
                            .frame(width: 24)
                        Text("Edit Hive Name")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .foregroundColor(.primary)
                
                Divider()
                    .padding(.horizontal)
                
                Button(action: {
                    // Edit notes action
                }) {
                    HStack {
                        Image(systemName: "note.text")
                            .frame(width: 24)
                        Text("Edit Notes")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .foregroundColor(.primary)
                
                Divider()
                    .padding(.horizontal)
                
                Button(action: {
                    showDisconnectAlert = true
                }) {
                    HStack {
                        Image(systemName: "link.badge.plus")
                            .frame(width: 24)
                        Text(beehive.status == .technicalIssue ? "Connect Sensor" : "Disconnect Sensor")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .foregroundColor(.primary)
                
                Divider()
                    .padding(.horizontal)
                
                Button(action: {
                    // Export data action
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 24)
                        Text("Export Data")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .foregroundColor(.primary)
                
                Divider()
                    .padding(.horizontal)
                
                Button(action: {
                    showDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .frame(width: 24)
                        Text("Delete Hive")
                        Spacer()
                    }
                }
                .padding()
                .foregroundColor(.red)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Helper Methods
    
    private var statusIcon: String {
        switch beehive.status {
        case .normal:
            return "checkmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .danger:
            return "xmark.octagon.fill"
        case .technicalIssue:
            return "exclamationmark.circle.fill"
        }
    }
    
    private func frequencyColor(for value: Double) -> Color {
        if value >= dangerThreshold {
            return .red
        } else if value >= normalThreshold {
            return .orange
        } else {
            return .green
        }
    }
    
    private func frequencyStatusIcon(for value: Double) -> String {
        if value >= dangerThreshold {
            return "xmark.circle.fill"
        } else if value >= normalThreshold {
            return "exclamationmark.triangle.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    private func frequencyStatusText(for value: Double) -> String {
        if value >= dangerThreshold {
            return "Danger"
        } else if value >= normalThreshold {
            return "Warning"
        } else {
            return "Normal"
        }
    }
}

// MARK: - Supporting Views

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    var records: [FrequencyRecord]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(records.reversed()) { record in
                    HStack {
                        Text(dateFormatter.string(from: record.date))
                            .font(.subheadline)
                        
                        Spacer()
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(record.value, specifier: "%.1f")")
                                .font(.subheadline)
                                .bold()
                            
                            Text("Hz")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Complete History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Model Extensions

struct FrequencyRecord: Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var value: Double
    
    static func == (lhs: FrequencyRecord, rhs: FrequencyRecord) -> Bool {
        return lhs.id == rhs.id
    }
}

struct BeehiveDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BeehiveDetailView(beehive: Beehive(
                id: 3,
                name: "Hive 1",
                status: .normal,
                soundFrequency: 215.2,
                site: "Main Facility",
                notes: "This hive was established on March 1st. Queen seems healthy and productive. Honey production expected to begin next month.",
                lastNotesUpdate: Date()
            ))
        }
        .preferredColorScheme(.light)
    }
}
