//
//  Settings.swift
//  InstAgendaOfficial
//
//  Created by Derald Blessman on 2/22/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var isNotificationsEnabled: Bool = true
    @State private var selectedTheme: String = "Light"
    @State private var reminderTime: Double = 8.0

    var body: some View {
        NavigationStack {
            Form {
                // Section for general settings
                Section(header: Text("General Settings")) {
                    Toggle("Enable Notifications", isOn: $isNotificationsEnabled)
                    
                    Picker("Theme", selection: $selectedTheme) {
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Slider(value: $reminderTime, in: 0...24, step: 1) {
                        Text("Reminder Time")
                    }
                    Text("Set reminder time: \(Int(reminderTime)) AM")
                }

                // Section for privacy settings
                Section(header: Text("Privacy Settings")) {
                    Toggle("Allow Location Access", isOn: $isNotificationsEnabled)
                    Toggle("Share Data with Third Parties", isOn: $isNotificationsEnabled)
                }

                // Section for app-specific settings
                Section(header: Text("App Settings")) {
                    Button(action: {
                        // Handle reset or logout action
                    }) {
                        Text("Reset App Settings")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
