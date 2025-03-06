//
//  AddBeehiveView.swift
//  Beezz
//
//  Created by Antonio Navarra on 06/03/25.
//


//
//  AddBeehiveView.swift
//  Beezz
//
//  Created on 06/03/25.
//

import SwiftUI

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

struct AddBeehiveView_Previews: PreviewProvider {
    static var previews: some View {
        AddBeehiveView(honeyAmber: Color.orange)
    }
}
