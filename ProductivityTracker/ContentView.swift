import SwiftUI
import Cocoa // Import to use NSSavePanel

// Define a struct to represent each time slot
struct TimeSlot: Identifiable {
    var id = UUID()
    var startTime: String
    var endTime: String
    var task: String
}

struct ContentView: View {
    @State private var timeSlots: [TimeSlot] = []
    
    // Initial time slot data covering 24 hours
    let initialTimeData = [
        ("12:00 AM", "12:30 AM"), ("12:30 AM", "1:00 AM"), ("1:00 AM", "1:30 AM"), ("1:30 AM", "2:00 AM"),
        ("2:00 AM", "2:30 AM"), ("2:30 AM", "3:00 AM"), ("3:00 AM", "3:30 AM"), ("3:30 AM", "4:00 AM"),
        ("4:00 AM", "4:30 AM"), ("4:30 AM", "5:00 AM"), ("5:00 AM", "5:30 AM"), ("5:30 AM", "6:00 AM"),
        ("6:00 AM", "6:30 AM"), ("6:30 AM", "7:00 AM"), ("7:00 AM", "7:30 AM"), ("7:30 AM", "8:00 AM"),
        ("8:00 AM", "8:30 AM"), ("8:30 AM", "9:00 AM"), ("9:00 AM", "9:30 AM"), ("9:30 AM", "10:00 AM"),
        ("10:00 AM", "10:30 AM"), ("10:30 AM", "11:00 AM"), ("11:00 AM", "11:30 AM"), ("11:30 AM", "12:00 PM"),
        ("12:00 PM", "12:30 PM"), ("12:30 PM", "1:00 PM"), ("1:00 PM", "1:30 PM"), ("1:30 PM", "2:00 PM"),
        ("2:00 PM", "2:30 PM"), ("2:30 PM", "3:00 PM"), ("3:00 PM", "3:30 PM"), ("3:30 PM", "4:00 PM"),
        ("4:00 PM", "4:30 PM"), ("4:30 PM", "5:00 PM"), ("5:00 PM", "5:30 PM"), ("5:30 PM", "6:00 PM"),
        ("6:00 PM", "6:30 PM"), ("6:30 PM", "7:00 PM"), ("7:00 PM", "7:30 PM"), ("7:30 PM", "8:00 PM"),
        ("8:00 PM", "8:30 PM"), ("8:30 PM", "9:00 PM"), ("9:00 PM", "9:30 PM"), ("9:30 PM", "10:00 PM"),
        ("10:00 PM", "10:30 PM"), ("10:30 PM", "11:00 PM"), ("11:00 PM", "11:30 PM"), ("11:30 PM", "12:00 AM")
    ]
    
    // Date formatter to display the current date
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }

    var body: some View {
        VStack {
            // Title and Subtitle
            VStack {
                Text("Ashrith's Productivity Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text(dateFormatter.string(from: Date()))
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach($timeSlots) { $slot in
                        HStack {
                            Text("\(slot.startTime) - \(slot.endTime)")
                                .frame(width: 150, alignment: .leading)
                                .font(.headline)
                            
                            TextField("Enter task...", text: $slot.task)
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
                    
                    Button(action: exportToCSV) {
                        Text("Export to CSV")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Make the content fill the window
        .onAppear(perform: loadTasks)
    }
    
    // Save tasks to UserDefaults
    func saveTasks() {
        // Convert timeSlots to a dictionary for UserDefaults
        let taskDict = timeSlots.reduce(into: [String: String]()) { dict, slot in
            let key = "\(slot.startTime)-\(slot.endTime)"
            dict[key] = slot.task
        }
        UserDefaults.standard.set(taskDict, forKey: "dailyTasks")
    }
    
    // Load tasks from UserDefaults
    func loadTasks() {
        // Initialize timeSlots with default times if it's empty
        if timeSlots.isEmpty {
            timeSlots = initialTimeData.map { TimeSlot(startTime: $0.0, endTime: $0.1, task: "") }
        }

        // Load saved tasks from UserDefaults
        if let savedTasks = UserDefaults.standard.dictionary(forKey: "dailyTasks") as? [String: String] {
            for (key, task) in savedTasks {
                let times = key.split(separator: "-")
                if times.count == 2, let start = times.first, let end = times.last {
                    if let index = timeSlots.firstIndex(where: { $0.startTime == start && $0.endTime == end }) {
                        timeSlots[index].task = task
                    }
                }
            }
        }
    }
    
    // Export tasks to a CSV file
    func exportToCSV() {
        // Set up the save panel
        let savePanel = NSSavePanel()
        savePanel.title = "Save your CSV file"
        savePanel.allowedFileTypes = ["csv"]
        savePanel.nameFieldStringValue = "ProductivityTracker.csv"

        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                var csvText = "Start Time,End Time,Task\n"
                
                for slot in timeSlots {
                    let newLine = "\(slot.startTime),\(slot.endTime),\"\(slot.task)\"\n"
                    csvText.append(newLine)
                }
                
                do {
                    try csvText.write(to: url, atomically: true, encoding: .utf8)
                    print("CSV file saved to: \(url.path)")
                } catch {
                    print("Failed to write CSV file: \(error)")
                }
            } else {
                print("Save cancelled or failed.")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
