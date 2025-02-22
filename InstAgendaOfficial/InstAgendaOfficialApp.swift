//
//  InstAgendaOfficialApp.swift
//  InstAgendaOfficial
//
//  Created by Derald Blessman on 2/21/25.
//

import SwiftUI
import SwiftData

@main
struct InstAgendaOfficialApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Event.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // Extract ModelContext from the shared ModelContainer
    var viewModel: EventViewModel

    init() {
        // Get the model context from the model container
        let modelContext = sharedModelContainer.mainContext
        self.viewModel = EventViewModel(context: modelContext)
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                // Event Page
                EventPage(viewModel: viewModel)
                    .tabItem {
                        Label("Events", systemImage: "calendar")
                    }
                
                // Calendar Page
                CalendarPageView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar.circle")
                    }
                
                // Settings Page
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .accentColor(.blue) // Change the tab bar color if needed
            .modelContainer(sharedModelContainer)
        }
    }
}
