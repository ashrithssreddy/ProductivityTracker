//
//  ProductivityTrackerApp.swift
//  ProductivityTracker
//
//  Created by Ashrith  Reddy on 9/25/24.
//

import SwiftUI

@main
struct ProductivityTrackerApp: App {
    // Create an instance of DataManager
    let dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Start autosave when the app launches
                    dataManager.startAutosave()
                }
        }
    }
}
