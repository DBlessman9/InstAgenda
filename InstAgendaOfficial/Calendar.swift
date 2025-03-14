//
//  ContentView.swift
//  InstAgendaOfficial
//
//  Created by Derald Blessman on 2/21/25.
//
import SwiftUI
import SwiftData

struct CalendarView: View {
    @StateObject var viewModel: EventViewModel
    let calendar = Calendar.current
    let eventTypes: [EventType: Color] = [
        .health: .red,
        .work: .yellow,
        .sleep: .blue,
        .school: .orange,
        .leisure: .green,
        .other: .gray
    ]
    
    @State private var showingAddEvent = false
    @State private var currentDate = Date()

    var formattedYear: String {
        let year = calendar.component(.year, from: currentDate)
        let yearFormatter = NumberFormatter()
        yearFormatter.numberStyle = .decimal
        yearFormatter.groupingSeparator = ""
        return yearFormatter.string(from: NSNumber(value: year)) ?? "\(year)"
    }
    
    
    func eventsForDay(_ day: Date) -> [Event] {
        let calendar = Calendar.current
        
        return viewModel.events.filter { event in
            if let recurrence = event.recurrence {
               
                let dayOfWeek = calendar.component(.weekday, from: day)
                
                let isAfterStartDate = calendar.compare(day, to: event.startDate, toGranularity: .day) != .orderedAscending

                // Check if the recurrence matches the weekday (by checking if the recurrence is in the weekdaySymbols array)
                return calendar.weekdaySymbols.contains(recurrence) && isAfterStartDate
            } else {
                return calendar.isDate(event.startDate, inSameDayAs: day)
            }
        }
    }

    
    func generateCalendar() -> [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let emptyDays = Array(repeating: Date.distantPast, count: firstWeekday - 1)
        
        let days = range.map { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
        }
        
        return emptyDays + days
    }
    
    func changeMonth(by offset: Int) {
        currentDate = calendar.date(byAdding: .month, value: offset, to: currentDate) ?? currentDate
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                Button(action: {
                    showingAddEvent.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gradientMid)
                            .padding(.bottom)
                            .padding(.leading)
                    }
                    Text("Add Event")
                        .foregroundStyle(Color.gradientMid)
                        .font(.title)
                        .padding(5)
                        .padding(.bottom, 10)
                    Spacer()
                }
                .padding(.top, 10)
                .sheet(isPresented: $showingAddEvent) {
                    
                    AddEventView(viewModel: viewModel)
                    
                }
                
                HStack {
                    Button(action: {
                        changeMonth(by: -1)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .padding()
                    }

                    Text("\(calendar.monthSymbols[calendar.component(.month, from: currentDate) - 1]) \(formattedYear)")
                        .font(.title)
                        .bold()
                        .padding()

                    Button(action: {
                        changeMonth(by: 1)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title)
                            .padding()
                    }
                }
                
                ScrollView(.vertical) {
                    VStack {
                        HStack {
                            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                                Text(day)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(50), spacing: 0), count: 7)) {
                            ForEach(generateCalendar(), id: \.self) { date in
                                VStack {
                                    if date != Date.distantPast {
                                        let day = calendar.component(.day, from: date)
                                        
                                        NavigationLink(destination: DayEventsView(viewModel: viewModel, date: date, events: eventsForDay(date))) {
                                            Text("\(day)")
                                                .font(.headline)
                                                .frame(width: 40, height: 40, alignment: .center)
                                                .background(Color.white)
                                                .cornerRadius(15)
                                                .padding(4)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Spacer(minLength: 4)
                                        
                                        HStack(spacing: 4) {
                                            ForEach(Array(Set(eventsForDay(date).map { $0.eventType })), id: \.self) { eventType in
                                                Circle()
                                                    .fill(eventTypes[eventType] ?? .gray)
                                                    .frame(width: 6, height: 6)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                }
                                .frame(height: 80)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchEvents()
        }
    }
}

struct DayEventsView: View {
    @ObservedObject var viewModel: EventViewModel
    var date: Date
    var events: [Event]
    @State private var showingAddEvent = false
    let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            VStack {
                let day = calendar.component(.day, from: date)
                let month = calendar.component(.month, from: date)
                let year = calendar.component(.year, from: date)
                let formattedYear = String(format: "%d", year)
                
                Text("Events for \(month)/\(day)/\(formattedYear)")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    showingAddEvent.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gradientMid)
                            .padding(.bottom)
                            .padding(.leading)
                    }
                    Text("Add Event")
                        .foregroundStyle(Color.gradientMid)
                        .font(.title)
                        .padding(5)
                        .padding(.bottom, 10)
                    Spacer()
                }
                .padding(.top, 10)
                .sheet(isPresented: $showingAddEvent) {
                    AddEventView(viewModel: viewModel)
                }
                
                List(events) { event in
                    VStack(alignment: .leading) {
                        // NavigationLink for each event to navigate to EventDetailView
                        NavigationLink(destination: EventDetailView(viewModel: viewModel, event: event)) {
                            Text(event.name)
                                .font(.headline)
                            Text(event.location)
                                .font(.subheadline)
                        }
                        .padding()
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding()
        }
    }
}



// Ensure the EventViewModel is defined to accept context or data.
class CalendarViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    // Initialize the view model with context, or mock data for the preview.
    init(context: ModelContext) {
        // Add your event fetching logic here (from database or mock data)
    }
    
    // Fetch events for a given month, day, etc.
    func eventsForDate(_ date: Date) -> [Event] {
        // Return events for the specific date
        return []
    }
}

struct CalendarPageView: View {
    @Environment(\.modelContext) private var modelContext // Use your model context here
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Image("AppCornerLogo")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Image("InstaWordGrad")
                            .padding(.top, 22)
                        
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .padding(.leading, -180)
                    .overlay(
                        Rectangle()
                            .frame(width:1000 ,height: 1)
                            .foregroundColor(.black)
                            .padding(.top, 52),
                        alignment: .bottom
                        
                    )
                }
                
                // Calendar View
                Spacer() // Add space to push calendar to the bottom
                
                // Pass the environment's model context to EventViewModel
                CalendarView(viewModel: EventViewModel(context: modelContext))
                    .padding(.top, 50)
                    .containerRelativeFrame(.horizontal, alignment: .center)
               
                
            }
        
           
            // Adding padding around the content
        }
    }
}

#Preview {
    CalendarPageView()
}
