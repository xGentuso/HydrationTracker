//
//  ReminderManager.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//

import Foundation
import UserNotifications
import SwiftUI

class ReminderManager: ObservableObject {
    @Published var isRemindersEnabled = false
    @Published var reminderInterval: TimeInterval = 2 * 60 * 60 // Default: 2 hours
    @Published var reminderStartTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var reminderEndTime: Date = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    
    private let userDefaults = UserDefaults.standard
    private let reminderEnabledKey = "hydrationRemindersEnabled"
    private let reminderIntervalKey = "hydrationReminderInterval"
    private let reminderStartTimeKey = "hydrationReminderStartTime"
    private let reminderEndTimeKey = "hydrationReminderEndTime"
    
    init() {
        loadSettings()
    }
    
    // MARK: - Public Methods
    
    func toggleReminders(_ enabled: Bool) {
        isRemindersEnabled = enabled
        
        if enabled {
            requestNotificationPermission { granted in
                if granted {
                    self.scheduleReminders()
                } else {
                    // Handle permission denial
                    self.isRemindersEnabled = false
                }
                self.saveSettings()
            }
        } else {
            cancelAllReminders()
            saveSettings()
        }
    }
    
    func updateReminderInterval(_ interval: TimeInterval) {
        reminderInterval = interval
        
        if isRemindersEnabled {
            rescheduleReminders()
        }
        
        saveSettings()
    }
    
    func updateReminderStartTime(_ date: Date) {
        // Extract just the time component
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        reminderStartTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? reminderStartTime
        
        if isRemindersEnabled {
            rescheduleReminders()
        }
        
        saveSettings()
    }
    
    func updateReminderEndTime(_ date: Date) {
        // Extract just the time component
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        reminderEndTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? reminderEndTime
        
        if isRemindersEnabled {
            rescheduleReminders()
        }
        
        saveSettings()
    }
    
    // MARK: - Private Methods
    
    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
            
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleReminders() {
        cancelAllReminders()
        
        let center = UNUserNotificationCenter.current()
        
        // Calculate how many reminders to schedule based on start and end time
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: reminderStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: reminderEndTime)
        
        guard let start = calendar.date(bySettingHour: startComponents.hour ?? 8, minute: startComponents.minute ?? 0, second: 0, of: Date()),
              let end = calendar.date(bySettingHour: endComponents.hour ?? 22, minute: endComponents.minute ?? 0, second: 0, of: Date()) else {
            return
        }
        
        // If end time is before start time, assume it's for the next day
        var adjustedEnd = end
        if end < start {
            adjustedEnd = calendar.date(byAdding: .day, value: 1, to: end) ?? end
        }
        
        // Calculate time between start and end
        let totalSeconds = adjustedEnd.timeIntervalSince(start)
        
        // Calculate how many intervals fit in this time window
        let intervals = Int(totalSeconds / reminderInterval)
        
        // Schedule notifications for today and tomorrow
        for day in 0...1 {
            for i in 0..<intervals {
                let intervalOffset = TimeInterval(i) * reminderInterval
                
                // Create date components for the notification
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: day, to: Date()) ?? Date())
                
                // Add time from start time plus interval offset
                let notificationTime = calendar.date(byAdding: .second, value: Int(intervalOffset), to: start) ?? start
                let timeComponents = calendar.dateComponents([.hour, .minute], from: notificationTime)
                
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute
                dateComponents.second = 0
                
                // Create trigger and content
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let content = UNMutableNotificationContent()
                content.title = "Hydration Reminder"
                content.body = "Time to drink some water! Stay hydrated throughout the day."
                content.sound = .default
                content.categoryIdentifier = "HYDRATION_REMINDER"
                
                // Create request with unique identifier
                let requestID = "hydration-reminder-\(day)-\(i)"
                let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
                
                // Add notification request
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // Register categories for actions
        let drinkAction = UNNotificationAction(
            identifier: "DRINK_ACTION",
            title: "Add 8oz",
            options: .foreground
        )
        
        let skipAction = UNNotificationAction(
            identifier: "SKIP_ACTION",
            title: "Skip",
            options: .destructive
        )
        
        let category = UNNotificationCategory(
            identifier: "HYDRATION_REMINDER",
            actions: [drinkAction, skipAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([category])
    }
    
    private func rescheduleReminders() {
        cancelAllReminders()
        scheduleReminders()
    }
    
    private func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Persistence
    
    private func saveSettings() {
        userDefaults.set(isRemindersEnabled, forKey: reminderEnabledKey)
        userDefaults.set(reminderInterval, forKey: reminderIntervalKey)
        userDefaults.set(reminderStartTime.timeIntervalSince1970, forKey: reminderStartTimeKey)
        userDefaults.set(reminderEndTime.timeIntervalSince1970, forKey: reminderEndTimeKey)
    }
    
    private func loadSettings() {
        isRemindersEnabled = userDefaults.bool(forKey: reminderEnabledKey)
        
        if let interval = userDefaults.object(forKey: reminderIntervalKey) as? TimeInterval {
            reminderInterval = interval
        }
        
        if let startTimeInterval = userDefaults.object(forKey: reminderStartTimeKey) as? TimeInterval {
            reminderStartTime = Date(timeIntervalSince1970: startTimeInterval)
        }
        
        if let endTimeInterval = userDefaults.object(forKey: reminderEndTimeKey) as? TimeInterval {
            reminderEndTime = Date(timeIntervalSince1970: endTimeInterval)
        }
        
        // If reminders were enabled when app was last closed, reschedule them
        if isRemindersEnabled {
            requestNotificationPermission { granted in
                if granted {
                    self.scheduleReminders()
                } else {
                    self.isRemindersEnabled = false
                    self.saveSettings()
                }
            }
        }
    }
}
