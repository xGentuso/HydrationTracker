//
//  HydrationTrackerApp.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//

import SwiftUI
import UserNotifications

@main
struct HydrationTrackerApp: App {
    // Create the stores as StateObjects so they're preserved across view updates
    @StateObject private var store = HydrationStore()
    @StateObject private var reminderManager = ReminderManager()
    
    // Handle notification responses
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(reminderManager)
        }
    }
}

// Handles notification responses
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // Store instance for adding water entries
    private var store: HydrationStore?
    
    func registerStore(_ store: HydrationStore) {
        self.store = store
    }
    
    // Called when a notification is tapped or an action is selected
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.actionIdentifier
        
        // Handle "Add 8oz" action
        if identifier == "DRINK_ACTION" {
            // Add water entry
            DispatchQueue.main.async {
                self.store?.addEntry(8.0)
            }
        }
        
        // Complete the action
        completionHandler()
    }
    
    // Allow notifications to show while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
