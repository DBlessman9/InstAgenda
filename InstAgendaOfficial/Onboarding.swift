//
//  Onboarding.swift
//  InstAgendaOfficial
//
//  Created by Derald Blessman on 2/22/25.
//
import SwiftUI
import SwiftData

struct InfoGatherView: View {
    
    @State var events: [Event] = []
    @State private var showingAddEvent = false
    @StateObject var viewModel: EventViewModel
    var sharedModelContainer: ModelContainer

    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false

    init(sharedModelContainer: ModelContainer) {
        self.sharedModelContainer = sharedModelContainer
        let modelContext = sharedModelContainer.mainContext
        _viewModel = StateObject(wrappedValue: EventViewModel(context: modelContext))
    }

    var body: some View {
        NavigationStack {
            // Debugging: Always show onboarding screen
            Text("Onboarding Screen")
                .font(.title)
                .bold()
                .foregroundColor(.blue)
            
            VStack {
                Text("Tell Us About Yourself...")
                    .font(.title)
                    .bold()
                    .padding()
                    .padding(.bottom, 20)

                NavigationLink {
                    WorkWelcomeView(viewModel: viewModel)
                } label: {
                    onboardingButton(label: "Work", icon: "building.2.crop.circle", color: .workYellow)
                }

                NavigationLink {
                    SchoolWelcomeView(viewModel: viewModel, sharedModelContainer: sharedModelContainer)
                } label: {
                    onboardingButton(label: "School", icon: "graduationcap.circle", color: .schoolOrange)
                }

                NavigationLink {
                    HealthWelcomeView(viewModel: viewModel, sharedModelContainer: sharedModelContainer)
                } label: {
                    onboardingButton(label: "Health", icon: "cross.circle", color: .healthRed)
                }

                NavigationLink {
                    SleepWelcomeView(viewModel: viewModel, sharedModelContainer: sharedModelContainer)
                } label: {
                    onboardingButton(label: "Sleep", icon: "bed.double.circle", color: .sleepBlue)
                }

                NavigationLink {
                    LesWelcomeView(viewModel: viewModel, sharedModelContainer: sharedModelContainer)
                } label: {
                    onboardingButton(label: "Leisure", icon: "gamecontroller.circle", color: .lesGreen)
                }

                // NavigationLink to EventPage
                NavigationLink(destination: EventPage(viewModel: viewModel)) {
                    HStack {
                        Text("Continue")
                        Text(">")
                            .font(.largeTitle)
                    }
                    .font(.title)
                    .foregroundColor(.gradientTop)
                    .cornerRadius(8)
                }
                .padding(.leading, 190)
            }
        }
    }

    private func onboardingButton(label: String, icon: String, color: Color) -> some View {
        HStack {
            Text(label)
                .bold()
                .shadow(radius: 3)
            Image(systemName: icon)
                .shadow(radius: 3)
        }
        .font(.largeTitle)
        .buttonStyle(.bordered)
        .frame(width: 225, height: 70)
        .background(color)
        .cornerRadius(9)
        .padding(20)
        .foregroundStyle(.white)
        .shadow(radius: 3)
        .shadow(radius: 9)
    }
}




struct WorkWelcomeView: View {
    @ObservedObject var viewModel: EventViewModel
    @State var events: [Event] = []
    var body: some View {
//            VStack {
                      

    
        Spacer()
        Text("What days and times do you work?")
            .font(.largeTitle)
            .bold()
        
        AddEventView(viewModel: viewModel)
            
        
     
      
           
        }
    }



struct SchoolWelcomeView: View {
    @ObservedObject var viewModel: EventViewModel
    @State var events: [Event] = []
    var sharedModelContainer: ModelContainer

var body: some View {
    
    Spacer()
    Text("What days and times do you go to school?")
        .font(.largeTitle)
        .bold()
        AddEventView(viewModel: viewModel)
    
    Spacer()
}
}

struct HealthWelcomeView: View {
    @ObservedObject var viewModel: EventViewModel
    @State var events: [Event] = []
    var sharedModelContainer: ModelContainer

    var body: some View {
       
        
        VStack {
            
            Spacer()
           
            Text("What date is your next doctors apointment?")
                .font(.largeTitle)
                .fontWeight(.bold)
//
//               // CalendarView(interval: DateInterval(start: .distantPast, end: .distantFuture))
//
//                Text("At what time? ")
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .padding()
//                DaysPicker()
//                Spacer()
            AddEventView(viewModel: viewModel)
        }
    }
}

struct SleepWelcomeView: View {
    @ObservedObject var viewModel: EventViewModel
    @State var events: [Event] = []
    var sharedModelContainer: ModelContainer

    var body: some View {
        
        
        VStack {
            
            Spacer()
            
            Text("What time do you go to bed?")
                .font(.largeTitle)
                .bold()
            
                AddEventView(viewModel: viewModel)
            
            
            Spacer()
        }
    }
}

struct LesWelcomeView: View {
    @ObservedObject var viewModel: EventViewModel
    @State var events: [Event] = []
    var sharedModelContainer: ModelContainer

    var body: some View {
        
        
        VStack {
            
            Spacer()
            
            Text("Do you have any dedicated leisure time?")
                .font(.largeTitle)
                .bold()
            
                AddEventView(viewModel: viewModel)
            Spacer()
        }
    }
}

//#Preview {
//InfoGatherView()
//}
