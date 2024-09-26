import SwiftUI

struct ContentView: View {
    // Store tasks in a dictionary with time slots as keys
    @State private var tasks: [String: String] = [:]
    
    // Define time slots
    let timeSlots = [
        "5:30 AM", "6:00 AM", "6:30 AM", "7:00 AM", "7:30 AM",
        "8:00 AM", "8:30 AM", "9:00 AM", "9:30 AM", "10:00 AM",
        "10:30 AM", "11:00 AM", "11:30 AM", "12:00 PM", "12:30 PM",
        "1:00 PM", "1:30 PM", "2:00 PM", "2:30 PM", "3:00 PM",
        "3:30 PM", "4:00 PM", "4:30 PM", "5:00 PM", "5:30 PM",
        "6:00 PM", "6:30 PM", "7:00 PM", "7:30 PM", "8:00 PM",
        "8:30 PM", "9:00 PM", "9:30 PM", "10:00 PM", "10:30 PM",
        "11:00 PM"
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(timeSlots, id: \.self) { time in
                        HStack {
                            Text(time)
                                .frame(width: 80, alignment: .leading)
                                .font(.headline)
                            
                            TextField("Enter task...", text: Binding(
                                get: { tasks[time] ?? "" },
                                set: { tasks[time] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 5)
                    }
                    
                    Button(action: saveTasks) {
                        Text("Save Tasks")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Productivity Tracker")
            .onAppear(perform: loadTasks)
        }
    }
    
    // Save tasks to UserDefaults
    func saveTasks() {
        UserDefaults.standard.set(tasks, forKey: "dailyTasks")
    }
    
    // Load tasks from UserDefaults
    func loadTasks() {
        if let savedTasks = UserDefaults.standard.dictionary(forKey: "dailyTasks") as? [String: String] {
            tasks = savedTasks
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
