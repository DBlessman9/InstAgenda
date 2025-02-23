import Foundation
import SwiftData
import SwiftUI

@Model
class Event: ObservableObject {
    @Attribute(.unique) var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date?  // Make endDate optional
    var startTime: Date
    var endTime: Date
    var location: String
    var notes: String
    private var eventTypeRaw: String  // Store as String for SwiftData compatibility
    var recurrence: [String]?  // Make recurrence optional
    var travelTime: TimeInterval?  // New property to store travel time in seconds

    var eventType: EventType {
        get { EventType(rawValue: eventTypeRaw) ?? .other }
        set { eventTypeRaw = newValue.rawValue }
    }

    init(id: UUID = UUID(), name: String, startDate: Date, endDate: Date? = nil, startTime: Date, endTime: Date, location: String, notes: String, recurrence: [String]? = nil, eventType: EventType, travelTime: TimeInterval? = nil) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.notes = notes
        self.eventTypeRaw = eventType.rawValue
        self.recurrence = recurrence
        self.travelTime = travelTime
    }
}

enum EventType: String, CaseIterable {
    case work = "Work"
    case school = "School"
    case health = "Health"
    case sleep = "Sleep"  // Changed to lowercase for Swift conventions
    case leisure = "Leisure"
    case other = "Other"
}

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    private var modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
        fetchEvents() // Fetch events at initialization
    }

    func fetchEvents() {
        let fetchDescriptor = FetchDescriptor<Event>(sortBy: [SortDescriptor(\.startDate)])
        do {
            events = try modelContext.fetch(fetchDescriptor)
            print("Fetched events: \(events)")  // Add a print statement
        } catch {
            print("Error fetching events: \(error)")
        }
    }


    func addEvent(_ event: Event) {
        modelContext.insert(event)
        do {
            try modelContext.save()
            objectWillChange.send()  // Manually notify that the object is about to change
            fetchEvents() // Refresh list after saving
        } catch {
            print("Error saving event: \(error)")
        }
    }


    func deleteEvent(_ event: Event) {
        modelContext.delete(event)
        do {
            try modelContext.save()
            objectWillChange.send()
            fetchEvents() // Refresh list after deleting
        } catch {
            print("Error deleting event: \(error)")
        }
    }
}

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: EventViewModel
    
    

    @State private var name = ""
    @State private var location = ""
    @State private var notes = ""
    @State private var selectedStartDate = Date()
    @State private var selectedEndDate: Date? = nil
    @State private var selectedStartTime = Date()
    @State private var selectedEndTime: Date? = nil
    @State private var eventType: EventType = .other
    @State private var selectedDays: [String] = []
    @State private var isRecurring: Bool = false
    
    @State private var selectedTravelTime: TimeInterval? = nil
    
    @State private var showEndDatePicker = false
    @State private var showEndTimePicker = false
    
    let weekdays = Calendar.current.weekdaySymbols
    
    let travelTimeOptions: [TimeInterval] = [5 * 60, 10 * 60, 15 * 60, 20 * 60, 30 * 60, 45 * 60, 60 * 60, 120 * 60]
    let travelTimeLabels = ["5 minutes", "10 minutes", "15 minutes", "20 minutes", "30 minutes", "45 minutes", "1 hour", "2 hours"]

    var body: some View {
        NavigationView {
            Form {
                TextField("Event Name", text: $name)
                TextField("Location", text: $location)
                TextField("Notes", text: $notes)
                
                DatePicker("Start Date", selection: $selectedStartDate, in: Date()..., displayedComponents: .date)

                
                DatePicker("Start Time", selection: $selectedStartTime, displayedComponents: .hourAndMinute)

                
                Picker("Event Type", selection: $eventType) {
                    ForEach(EventType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
                
                Picker("Travel Time", selection: $selectedTravelTime) {
                                    ForEach(0..<travelTimeOptions.count, id: \.self) { index in
                                        Text(travelTimeLabels[index]).tag(travelTimeOptions[index] as TimeInterval?)
                                    }
                                }

                Toggle("Is Recurring", isOn: $isRecurring)
                if isRecurring {
                    Section(header: Text("Select Days")) {
                        ForEach(weekdays, id: \.self) { day in
                            MultipleSelectionRow(day: day, isSelected: selectedDays.contains(day)) {
                                if selectedDays.contains(day) {
                                    selectedDays.removeAll { $0 == day }
                                } else {
                                    selectedDays.append(day)
                                }
                            }
                        }
                    }
                }
                
                // Example for the End Date toggle in AddEventView
                Toggle("Add End Date", isOn: Binding(
                    get: { selectedEndDate != nil },
                    set: { newValue in
                        if newValue {
                            selectedEndDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedStartDate)
                        } else {
                            selectedEndDate = nil
                        }
                        showEndDatePicker = newValue
                    }
                ))


                Toggle("Add End Time", isOn: Binding(
                    get: { selectedEndTime != nil },
                    set: { newValue in
                        if newValue {
                            // Set a default end time when toggled on
                            selectedEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: selectedStartTime)
                        } else {
                            selectedEndTime = nil  // Set to nil when toggled off
                        }
                        showEndTimePicker = newValue
                    }
                ))

            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newEvent = Event(
                            name: name,
                            startDate: selectedStartDate,
                            endDate: selectedEndDate ?? selectedStartDate,
                            startTime: selectedStartTime,
                            endTime: selectedEndTime ?? selectedStartTime,
                            location: location,
                            notes: notes,
                            recurrence: isRecurring ? selectedDays : nil,
                            eventType: eventType,
                            travelTime: selectedTravelTime
                        )
                        viewModel.addEvent(newEvent)
                        dismiss()
                        viewModel.fetchEvents()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}






// Helper view for multiple selection of days
struct MultipleSelectionRow: View {
    var day: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(day)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                }
            }
        }
        .foregroundColor(.primary)
    }
}


import SwiftUI

struct EditEventView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var event: Event

    @State private var name = ""
    @State private var location = ""
    @State private var notes = ""
    @State private var selectedStartDate: Date
    @State private var selectedEndDate: Date?
    @State private var selectedStartTime: Date
    @State private var selectedEndTime: Date?
    @State private var eventType: EventType
    @State private var selectedDays: [String] = []
    @State private var isRecurring: Bool = false
    @State private var travelTime: TimeInterval?  // New state variable for travel time

    let weekdays = Calendar.current.weekdaySymbols
    let travelTimeOptions: [TimeInterval] = [300, 600, 900, 1200, 1800, 2700, 3600] // 5, 10, 15, 20, 30, 45, 60 minutes in seconds

    init(event: Binding<Event>) {
        self._event = event
        _name = State(initialValue: event.wrappedValue.name)
        _location = State(initialValue: event.wrappedValue.location)
        _notes = State(initialValue: event.wrappedValue.notes)
        _selectedStartDate = State(initialValue: event.wrappedValue.startDate)
        _selectedEndDate = State(initialValue: event.wrappedValue.endDate)
        _selectedStartTime = State(initialValue: event.wrappedValue.startTime)
        _selectedEndTime = State(initialValue: event.wrappedValue.endTime)
        _eventType = State(initialValue: event.wrappedValue.eventType)
        _selectedDays = State(initialValue: event.wrappedValue.recurrence ?? [])
        _isRecurring = State(initialValue: event.wrappedValue.recurrence != nil)
        _travelTime = State(initialValue: event.wrappedValue.travelTime) // Initialize with event's travelTime
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Event Name", text: $name)
                TextField("Location", text: $location)
                TextField("Notes", text: $notes)

                DatePicker("Start Date", selection: $selectedStartDate, displayedComponents: .date)
                DatePicker("Start Time", selection: $selectedStartTime, displayedComponents: .hourAndMinute)

                Picker("Event Type", selection: $eventType) {
                    ForEach(EventType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
                
                // Travel Time Picker
                Picker("Travel Time", selection: $travelTime) {
                    ForEach(travelTimeOptions, id: \.self) { time in
                        Text(timeFormatted(time)).tag(time as TimeInterval?)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Toggle("Is Recurring", isOn: $isRecurring)
                if isRecurring {
                    Section(header: Text("Select Days")) {
                        ForEach(weekdays, id: \.self) { day in
                            MultipleSelectionRow(day: day, isSelected: selectedDays.contains(day)) {
                                if selectedDays.contains(day) {
                                    selectedDays.removeAll { $0 == day }
                                } else {
                                    selectedDays.append(day)
                                }
                            }
                        }
                    }
                }

               
                
                Toggle("Add End Date", isOn: Binding(
                    get: { selectedEndDate != nil },
                    set: { newValue in
                        if newValue {
                            selectedEndDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedStartDate)
                        } else {
                            selectedEndDate = nil
                        }
                    }
                ))

                Toggle("Add End Time", isOn: Binding(
                    get: { selectedEndTime != nil },
                    set: { newValue in
                        if newValue {
                            selectedEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: selectedStartTime)
                        } else {
                            selectedEndTime = nil
                        }
                    }
                ))

            }
            .navigationTitle("Edit Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save the modified event
                        event.name = name
                        event.location = location
                        event.notes = notes
                        event.startDate = selectedStartDate
                        event.endDate = selectedEndDate
                        event.startTime = selectedStartTime
                        event.endTime = selectedEndTime ?? selectedStartTime
                        event.eventType = eventType
                        event.recurrence = isRecurring ? selectedDays : nil
                        event.travelTime = travelTime  // Save the selected travel time

                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            print("Failed to save event: \(error.localizedDescription)")
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    // Helper function to format time in minutes and seconds
    private func timeFormatted(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


struct EventDetailView: View {
    @ObservedObject var viewModel: EventViewModel
    let event: Event
    @Environment(\.presentationMode) var presentationMode
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            Spacer()
            Text(event.name)
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            HStack {
                Text("Location:")
                    .font(.headline)
                Text("\(event.location)")
                    .font(.body)
            }
            
            HStack {
                Text("Start Date:")
                    .font(.headline)
                Text("\(event.startDate, style: .date)")
                    .font(.body)
            }
            
            HStack {
                Text("End Date:")
                    .font(.headline)
                
                if let endDate = event.endDate {
                    Text("\(endDate, style: .date)")
                        .font(.body)
                } else {
                    Text("No end date")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }

            
            HStack {
                Text("Start Time:")
                    .font(.headline)
                Text("\(event.startTime, style: .time)")
                    .font(.body)
            }
            
            HStack {
                Text("End Time:")
                    .font(.headline)
                Text("\(event.endTime, style: .time)")
                    .font(.body)
            }
            
            Text("Notes:")
                .padding(.top, 20)
                .font(.headline)
            
            Text("\(event.notes)")
                .font(.body)
            
            // Add a check for recurrence here
            if let recurrence = event.recurrence {
                Text("Recurs every \(recurrence)")
                    .font(.body)
                    .padding(.top, 10)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Event Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing.toggle()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: deleteEvent) {
                    Text("Delete")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            // Pass a binding to the event when editing
            if let index = viewModel.events.firstIndex(where: { $0.id == event.id }) {
                EditEventView(event: $viewModel.events[index])
            }
        }
    }
    
    private func deleteEvent() {
        if let index = viewModel.events.firstIndex(where: { $0.id == event.id }) {
            viewModel.deleteEvent(event)  // Call the delete function in the view model
        }
        presentationMode.wrappedValue.dismiss()
    }
}


struct EventPage: View {
    @StateObject var viewModel: EventViewModel  // Use @ObservedObject since it's passed in
    
    @State private var showingAddEvent = false
    
    let now = Date()
    let calendar = Calendar.current
    
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
                    .padding(.top, -20)
                    .padding(.bottom, 10)
                    .padding(.leading, -180)
                    .overlay(
                        Rectangle()
                            .frame(width:1000 ,height: 1)
                            .foregroundColor(.black)
                            .padding(.top, 50),
                        alignment: .bottom
                        
                    )
                }
                
          
Spacer()
                
  
                ScrollView {
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
                                .foregroundStyle(Color.gradientTop)
                                .font(.title)
                                .padding(5)
                                .padding(.bottom, 10)
                            Spacer()
                        }
                        .padding(.top, 80)
                        .padding(.bottom, 10)
                        .sheet(isPresented: $showingAddEvent) {
                            
                            AddEventView(viewModel: viewModel)
                            
                        }
                        
                        // Upcoming Events
                        VStack {
                            Text("What's Next?")
                                .font(.largeTitle)
                                .bold()
                                .padding(.leading, -150)
                            
                            let upcomingEvents = viewModel.events.filter { event in
                                let eventEndDateTime = calendar.date(
                                    bySettingHour: calendar.component(.hour, from: event.endTime),
                                    minute: calendar.component(.minute, from: event.endTime),
                                    second: 0,
                                    of: event.startDate
                                ) ?? event.endTime
                                
                                return calendar.isDate(event.startDate, inSameDayAs: now) && eventEndDateTime > now
                            }
                            
                            if upcomingEvents.isEmpty {
                                Text("Nothing To Do 🥱")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                    .bold()
                                    .padding()
                                    .border(.black, width: 1)
                                    .cornerRadius(3)
                                    .padding(.top, 60)
                                    .padding(.bottom, 70)
                            } else {
                                List(upcomingEvents, id: \.id) { event in
                                    NavigationLink(destination: EventDetailView(viewModel: viewModel, event: event)) {
                                        VStack(alignment: .leading) {
                                            Text(event.name)
                                                .font(.headline)
                                            Text(event.location)
                                                .font(.subheadline)
                                            Text(event.notes)
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .frame(width: 400, height: 200)
                            }
                        }
                        
                        // Earlier Today
                        VStack {
                            Text("Earlier Today")
                                .font(.largeTitle)
                                .bold()
                                .padding(.leading, -150)
                            
                            let earlierTodayEvents = viewModel.events.filter { event in
                                let eventEndDateTime = calendar.date(
                                    bySettingHour: calendar.component(.hour, from: event.endTime),
                                    minute: calendar.component(.minute, from: event.endTime),
                                    second: 0,
                                    of: event.startDate
                                ) ?? event.endTime
                                
                                return calendar.isDate(event.startDate, inSameDayAs: now) && eventEndDateTime < now
                            }
                            
                            if earlierTodayEvents.isEmpty {
                                Text("Nothing So Far! 😴")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                    .bold()
                                    .padding()
                                    .border(.black, width: 1)
                                    .cornerRadius(3)
                                    .padding(.top, 60)
                                    .padding(.bottom, 70)
                            } else {
                                List(earlierTodayEvents) { event in
                                    NavigationLink(destination: EventDetailView(viewModel: viewModel, event: event)) {
                                        VStack(alignment: .leading) {
                                            Text(event.name)
                                                .font(.headline)
                                            Text(event.location)
                                                .font(.subheadline)
                                            Text(event.notes)
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .frame(width: 400, height: 200)
                            }
                        }
                        
                        // Later This Week
                        VStack {
                            Text("Later This Week")
                                .font(.largeTitle)
                                .bold()
                                .padding(.leading, -100)
                            
                            let laterThisWeekEvents = viewModel.events.filter { event in
                                let eventStartDateTime = calendar.date(
                                    bySettingHour: calendar.component(.hour, from: event.startTime),
                                    minute: calendar.component(.minute, from: event.startTime),
                                    second: 0,
                                    of: event.startDate
                                ) ?? event.startTime
                                
                                return !calendar.isDate(event.startDate, inSameDayAs: now) && eventStartDateTime <= calendar.date(byAdding: .day, value: 6, to: now)!
                            }
                            
                            if laterThisWeekEvents.isEmpty {
                                Text("Nothing To Do 🥱")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                    .bold()
                                    .padding()
                                    .border(.black, width: 1)
                                    .cornerRadius(3)
                                    .padding(60)
                                    .padding(.bottom, 40)
                            } else {
                                List(laterThisWeekEvents) { event in
                                    NavigationLink(destination: EventDetailView(viewModel: viewModel, event: event)) {
                                        VStack(alignment: .leading) {
                                            Text(event.name)
                                                .font(.headline)
                                            Text(event.location)
                                                .font(.subheadline)
                                            Text(event.notes)
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .frame(width: 400, height: 200)
                            }
                        }
                    }
                    .padding(.top, -20)
                }
                
                
            }
        }
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(true)
    }
}

struct EventPage_Preview: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: Event.self)
        let viewModel = EventViewModel(context: container.mainContext)

        return EventPage(viewModel: viewModel)
    }
}
