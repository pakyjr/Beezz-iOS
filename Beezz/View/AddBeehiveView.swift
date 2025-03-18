import SwiftUI

struct AddBeehiveView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var beehiveName = ""
    @State private var selectedSite = "North Field"
    @State private var associateSensor = false
    @State private var selectedSensor = ""
    @State private var showAdvancedSettings = false
    @State private var additionalNotes = ""
    
    let sites = ["North Field", "South Field", "Facility"]
    let availableSensors = [
        (name: "Sensor A1", status: "Available", battery: 85),
        (name: "Sensor A2", status: "Available", battery: 72),
        (name: "Sensor D4", status: "Available", battery: 35),
        (name: "Sensor E2", status: "Available", battery: 12)
    ]
    
    // Function to get the battery icon based on percentage
    func batteryIcon(for percentage: Int) -> String {
        switch percentage {
            case 0...10: return "battery.0"
            case 11...25: return "battery.25"
            case 26...50: return "battery.50"
            case 51...75: return "battery.75"
            default: return "battery.100"
        }
    }
    
    // Function to get the battery color based on percentage
    func batteryColor(for percentage: Int) -> Color {
        switch percentage {
            case 0...20: return .red
            default: return .green
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // SECTION 1: Basic Information
                Section(header: Text("Basic Information")) {
                    TextField("Enter hive name", text: $beehiveName)
                        .autocapitalization(.words)
                    
                    Picker("Location", selection: $selectedSite) {
                        ForEach(sites, id: \.self) { site in
                            Text(site).tag(site)
                        }
                    }
                }
                
                // SECTION 2: Sensor Association
                Section(header: Text("CONNECTION")) {
                    // Toggle with Wi-Fi icon and yellow color
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(associateSensor ? .yellow : .yellow)
                        Toggle("Connect a Wi-Fi Sensor", isOn: $associateSensor)
                            .toggleStyle(SwitchToggleStyle(tint: .honeyAmber))
                            .foregroundColor(.honeyAmber)
                    }
                    
                    if associateSensor {
                        // Rimosso il pulsante "Scan for Sensors" con la lente d'ingrandimento
                        
                        ForEach(availableSensors, id: \.name) { sensor in
                            Button(action: {
                                selectedSensor = sensor.name
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(sensor.name)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        Text(sensor.status)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Dynamic battery indicator
                                    HStack(spacing: 2) {
                                        Image(systemName: batteryIcon(for: sensor.battery))
                                            .foregroundColor(batteryColor(for: sensor.battery))
                                        Text("\(sensor.battery)%")
                                            .font(.caption)
                                            .foregroundColor(Color.primary)
                                    }
                                    
                                    if selectedSensor == sensor.name {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.yellow)
                                            .padding(.leading, 5)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    } else {
                        Text("Hive will be created with no sensor data")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.vertical, 5)
                    }
                }
                
                // SECTION 3: Advanced Settings
                DisclosureGroup("Advanced Settings", isExpanded: $showAdvancedSettings) {
                    VStack(alignment: .leading) {
                        Text("Additional Notes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        
                        TextEditor(text: $additionalNotes)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .overlay(
                                Group {
                                    if additionalNotes.isEmpty {
                                        Text("Add details or observations about this hive...")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 8)
                                            .allowsHitTesting(false)
                                    }
                                }
                            )
                    }
                }
            }
            .navigationTitle("Add a new hive")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.yellow),
                trailing: Button("Save Hive") {
                    // Save action would go here
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(beehiveName.isEmpty)
                .foregroundColor(beehiveName.isEmpty ? Color.gray : .yellow)
            )
        }
    }
}


struct AddBeehiveView_Previews: PreviewProvider {
    static var previews: some View {
        AddBeehiveView()
            .preferredColorScheme(.dark)
    }
}
