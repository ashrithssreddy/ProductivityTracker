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
    
    // Date formatter to format the date for file name
    private var fileDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        return formatter
    }
    
    // Date formatter to include the date in the CSV and as the key for UserDefaults
    private var csvDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
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
                                .onChange(of: slot.task) { _ in
                                    saveTasks()
                                }
                        }
                        .padding(.vertical, 5)
                    }
                    
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
        let dateString = csvDateFormatter.string(from: Date())
        let taskDict = timeSlots.reduce(into: [String: String]()) { dict, slot in
            let key = "\(slot.startTime)-\(slot.endTime)"
            dict[key] = slot.task
        }
        UserDefaults.standard.set(taskDict, forKey: "tasks_\(dateString)")
    }
    
    // Load tasks from UserDefaults
    func loadTasks() {
        let dateString = csvDateFormatter.string(from: Date())
        
        // Initialize timeSlots with default times if it's empty
        if let savedTasks = UserDefaults.standard.dictionary(forKey: "tasks_\(dateString)") as? [String: String] {
            // Load saved tasks for the current date
            timeSlots = initialTimeData.map { (startTime, endTime) in
                let key = "\(startTime)-\(endTime)"
                let task = savedTasks[key] ?? ""
                return TimeSlot(startTime: startTime, endTime: endTime, task: task)
            }
        } else {
            // Initialize with default times for a new day
            timeSlots = initialTimeData.map { TimeSlot(startTime: $0.0, endTime: $0.1, task: "") }
        }
    }
    
    // Export tasks to a predefined or user-selected location
    func exportToCSV() {
        // Get the current date string in yyyy_mm_dd format for the filename
        let dateStringForFile = fileDateFormatter.string(from: Date())
        let fileName = "ProductivityTracker_\(dateStringForFile).csv"
        
        // Check if a save path is already stored in UserDefaults
        if let savedPath = UserDefaults.standard.string(forKey: "csvSavePath") {
            // Use the saved path to export the CSV
            let fileURL = URL(fileURLWithPath: savedPath).appendingPathComponent(fileName)
            writeCSV(to: fileURL)
        } else {
            // If no path is saved, ask the user to select a directory
            let openPanel = NSOpenPanel()
            openPanel.title = "Select a folder to save CSV files"
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            
            openPanel.begin { result in
                if result == .OK, let url = openPanel.url {
                    // Save the selected path to UserDefaults
                    UserDefaults.standard.set(url.path, forKey: "csvSavePath")
                    let fileURL = url.appendingPathComponent(fileName)
                    writeCSV(to: fileURL)
                }
            }
        }
    }
    
    // Write the CSV data to a specified file URL
    func writeCSV(to fileURL: URL) {
        let dateStringForCSV = csvDateFormatter.string(from: Date())
        
        var csvText = "Date,\"Time Slot\",Task\n"
        
        for slot in timeSlots {
            let timeSlot = "\"\(slot.startTime) to \(slot.endTime)\""
            let newLine = "\(dateStringForCSV),\(timeSlot),\"\(slot.task)\"\n"
            csvText.append(newLine)
        }
        
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV file saved to: \(fileURL.path)")
        } catch {
            print("Failed to write CSV file: \(error)")
        }
    }
