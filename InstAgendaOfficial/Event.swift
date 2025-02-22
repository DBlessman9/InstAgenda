import Foundation
import SwiftData
import SwiftUI

@Model
class Event: ObservableObject {
    @Attribute(.unique) var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var startTime: Date
    var endTime: Date
    var location: String
    var notes: String
    private var eventTypeRaw: String  // Store as String for SwiftData compatibility
    
    var eventType: EventType {
        get { EventType(rawValue: eventTypeRaw) ?? .other }
        set { eventTypeRaw = newValue.rawValue }
    }

    init(id: UUID = UUID(), name: String, startDate: Date, endDate: Date, startTime: Date, endTime: Date, location: String, notes: String, eventType: EventType) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.notes = notes
        self.eventTypeRaw = eventType.rawValue  // Store raw value
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
    @Environment(\.modelContext) private var modelContext  // Use SwiftData context
    @ObservedObject var viewModel: EventViewModel  // Add this
    
    @State private var name = ""
    @State private var location = ""
    @State private var notes = ""
    @State private var selectedStartDate = Date()
    @State private var selectedEndDate = Date()
    @State private var selectedStartTime = Date()
    @State private var selectedEndTime = Date()
    @State private var eventType: EventType = .other  // Use enum instead of String

    var body: some View {
        NavigationView {
            Form {
                TextField("Event Name", text: $name)
                TextField("Location", text: $location)
                TextField("Notes", text: $notes)

                DatePicker("Start Date", selection: $selectedStartDate, in: Date()..., displayedComponents: .date)
                DatePicker("End Date", selection: $selectedEndDate, in: selectedEndDate..., displayedComponents: .date)
                
                DatePicker("Start Time", selection: $selectedStartTime, displayedComponents: .hourAndMinute)
                DatePicker("End Time", selection: $selectedEndTime, in: selectedStartTime..., displayedComponents: .hourAndMinute)

                Picker("Event Type", selection: $eventType) {
                    ForEach(EventType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
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
                            endDate: selectedEndDate,
                            startTime: selectedStartTime,
                            endTime: selectedEndTime,
                            location: location,
                            notes: notes,
                            eventType: eventType
                        )
                        viewModel.addEvent(newEvent)  // Use ViewModel to save & refresh
                        dismiss()
                        viewModel.fetchEvents()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct EditEventView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext  // Use SwiftData context
    @Binding var event: Event  // Use binding to modify the event

    var body: some View {
        NavigationView {
            Form {
                TextField("Event Name", text: $event.name)
                TextField("Location", text: $event.location)
                TextField("Notes", text: $event.notes)

                DatePicker("Start Date", selection: $event.startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $event.endDate, in: event.startDate..., displayedComponents: .date)
                
                DatePicker("Start Time", selection: $event.startTime, displayedComponents: .hourAndMinute)

                DatePicker("End Time", selection: $event.endTime, in: event.startTime..., displayedComponents: .hourAndMinute)
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
                        do {
                            try modelContext.save()  // Save with SwiftData
                            dismiss()
                        } catch {
                            print("Failed to save event: \(error.localizedDescription)")
                        }
                    }
                    .disabled(event.name.isEmpty) // Disable save if name is empty
                }
            }
        }
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
                Text("\(event.endDate, style: .date)")
                    .font(.body)
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
                        .padding(.top, 50),
                    alignment: .bottom
                    
                )
                
          

                
  
                ScrollView {
                    VStack {
                        Button(action: {
                            showingAddEvent.toggle()
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gradientTop)
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
                        .padding(.top, 90)
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
