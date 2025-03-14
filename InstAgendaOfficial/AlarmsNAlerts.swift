import SwiftUI

// Alarm data model
class AppAlarm: Identifiable {
    var id: UUID
    var time: Date
    var description: String?

    init(id: UUID = UUID(), time: Date, description: String? = nil) {
        self.id = id
        self.time = time
        self.description = description
    }
}

// AlarmViewModel to handle alarm data and actions
class AlarmViewModel: ObservableObject {
    @Published var alarms: [AppAlarm] = [] // Alarm data
    
    func addAlarm(_ appAlarm: AppAlarm) {
        alarms.append(appAlarm)
    }
}

struct AlarmView: View {
    @StateObject private var viewModel = AlarmViewModel() // ViewModel for alarms
    @State private var showingAddAlarm = false // Track sheet presentation
    @State private var newAlarmTime: Date = Date() // Default to current time
    @State private var newAlarmDescription: String = "" // Description input

    var body: some View {
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
                    .frame(width: 1000, height: 1)
                    .foregroundColor(.black)
                    .padding(.top, 52),
                alignment: .bottom
            )

            Spacer()

            NavigationStack {
                VStack {
                    Button(action: {
                        showingAddAlarm.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gradientMid)
                                .padding(.bottom)
                                .padding(.leading)
                        }
                        Text("Add Alarm")
                            .foregroundStyle(Color.gradientTop)
                            .font(.title)
                            .padding(5)
                            .padding(.bottom, 10)
                    }
                    .padding(.leading, -201)
                    .padding(.top, 60)
                    .padding(.bottom, 10)
                    .sheet(isPresented: $showingAddAlarm) {
                        AddAlarmView(viewModel: viewModel,
                                      newAlarmTime: $newAlarmTime,
                                      newAlarmDescription: $newAlarmDescription)
                    }

                    List(viewModel.alarms, id: \.id) { alarm in
                        VStack(alignment: .leading) {
                            Text("Time: \(alarm.time, style: .time)")
                                .font(.headline)
                            if let description = alarm.description {
                                Text("Description: \(description)")
                                    .font(.subheadline)
                            } else {
                                Text("No Description")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct AddAlarmView: View {
    @ObservedObject var viewModel: AlarmViewModel
    @Binding var newAlarmTime: Date
    @Binding var newAlarmDescription: String

    var body: some View {
        VStack {
            DatePicker("Select Time", selection: $newAlarmTime, displayedComponents: .hourAndMinute)
                .padding()

            TextField("Enter Description (optional)", text: $newAlarmDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Add Alarm") {
                let newAlarm = AppAlarm(time: newAlarmTime, description: newAlarmDescription)
                viewModel.addAlarm(newAlarm)
                newAlarmDescription = "" // Clear input after adding
            }
            .padding()
            .foregroundColor(.blue)
        }
        .padding()
    }
}

struct AlarmView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmView()
    }
}
