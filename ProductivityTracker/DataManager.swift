//
//  DataManager.swift
//  ProductivityTracker
//
//  Created by Ashrith  Reddy on 10/5/24.
//

import Foundation

class DataManager {
    
    var autosaveTimer: Timer?
    
    // Get the iCloud directory path
    func getAutosaveFileURL() -> URL? {
        if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
            return iCloudURL.appendingPathComponent("/Users/ashrithreddy/Library/Mobile Documents/com~apple~CloudDocs/ProductivityTrackerLogs/autosave.csv")
        }
        return nil
    }

    // Generate the CSV string
    func generateCSVString() -> String {
        // Header row for the CSV
        var csvString = "Date,Activity,Duration\n"
        
        // Example data entries (replace this with your app's actual data)
        let dataEntries = [
            ["2024-10-01", "Coding", "2 hours"],
            ["2024-10-02", "Meeting", "1 hour"],
            ["2024-10-03", "Research", "3 hours"]
        ]
        
        // Loop through your data and format it as CSV
        for entry in dataEntries {
            let row = "\(entry[0]),\(entry[1]),\(entry[2])\n"
            csvString += row
        }
        
        return csvString
    }

    // Autosave data as CSV
    func autosaveData() {
        guard let fileURL = getAutosaveFileURL() else {
            print("Failed to access iCloud Drive.")
            return
        }
        
        let csvString = generateCSVString() // Convert data to CSV format

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Autosave to iCloud successful!")
        } catch {
            print("Autosave failed: \(error.localizedDescription)")
        }
    }

    // Start autosave with a timer
    func startAutosave() {
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.autosaveData()
        }
    }
}
