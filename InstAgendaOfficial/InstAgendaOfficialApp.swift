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
    var sharedModelContainer: ModelContainer
    var viewModel: EventViewModel

    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false

    init() {
        let schema = Schema([Event.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let modelContext = sharedModelContainer.mainContext
            self.viewModel = EventViewModel(context: modelContext)
            
            // Debugging: Force `hasLaunchedBefore` to false so it always shows onboarding
            hasLaunchedBefore = false

            print("Has launched before: \(hasLaunchedBefore)") // Debugging line
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            // Wrap CustomTabView inside NavigationStack
            NavigationStack {
                CustomTabView(viewModel: viewModel)
                    .modelContainer(sharedModelContainer) // Attach SwiftData
                    .environment(\.modelContext, sharedModelContainer.mainContext) // Pass model context
            }
        }
    }
}

struct CustomTabView: View {
    @State private var selectedTab = 0
    var viewModel: EventViewModel

    let gradientColors: [Color] = [
        .gradientTop,
        .gradientMid,
        .gradientMid2,
        .gradientBottom
    ]

    var body: some View {
        VStack {
            // Content of each tab
            if selectedTab == 0 {
                EventPage(viewModel: viewModel)
            } else if selectedTab == 1 {
                CalendarPageView()
            } else {
                SettingsView()
            }

            // Custom Tab Bar
            HStack {
                // Event Tab
                Button(action: {
                    selectedTab = 0
                }) {
                    TabBarItem(icon: "house.fill", label: "Home", isSelected: selectedTab == 0)
                }

                Spacer()

                // Calendar Tab
                Button(action: {
                    selectedTab = 1
                }) {
                    TabBarItem(icon: "calendar", label: "Calendar", isSelected: selectedTab == 1)
                }

                Spacer()

                // Settings Tab
                Button(action: {
                    selectedTab = 2
                }) {
                    TabBarItem(icon: "gearshape.fill", label: "Settings", isSelected: selectedTab == 2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white) // Background color for the tab bar
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let gradientColors: [Color] = [
        .gradientTop,
        .gradientMid,
        .gradientMid2,
        .gradientBottom
    ]

    var body: some View {
        VStack {
            if isSelected {
                // Apply Gradient to the icon itself
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing))
            } else {
                // Gray color for unselected items
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
            }

            if isSelected {
                // Apply Gradient to the text (label) when selected
                Text(label)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing))
            } else {
                // Gray color for unselected items
                Text(label)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct InstAgendaOfficialApp_Previews: PreviewProvider {
    static var previews: some View {
        let schema = Schema([Event.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true) // Use in-memory storage
        
        do {
            let sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let modelContext = sharedModelContainer.mainContext
            let viewModel = EventViewModel(context: modelContext)

            return CustomTabView(viewModel: viewModel)
                .modelContainer(sharedModelContainer) // Attach SwiftData
                .environment(\.modelContext, modelContext) // Pass model context
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
