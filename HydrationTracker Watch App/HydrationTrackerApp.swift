//
//  HydrationTrackerApp.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//

import SwiftUI

@main
struct HydrationTrackerApp: App {
    // Create the store as a StateObject so it's preserved across view updates
    @StateObject private var store = HydrationStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
