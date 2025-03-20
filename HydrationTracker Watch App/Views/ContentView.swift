//
//  ContentView.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: HydrationStore
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main progress view
            ProgressView()
                .tag(0)
                .environmentObject(store)
            
            // Quick add view
            AddDrinkView()
                .tag(1)
                .environmentObject(store)
            
            // Reminders view
            RemindersView()
                .tag(2)
                .environmentObject(reminderManager)
            
            // Settings view
            SettingsView()
                .tag(3)
                .environmentObject(store)
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            // Register the store with the notification delegate
            NotificationDelegate.shared.registerStore(store)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HydrationStore())
            .environmentObject(ReminderManager())
    }
}
