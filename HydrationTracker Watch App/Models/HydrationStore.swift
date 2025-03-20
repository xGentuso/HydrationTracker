//
//  HydrationStore.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//

import Foundation
import SwiftUI

class HydrationStore: ObservableObject {
    // Published properties that will trigger UI updates
    @Published var entries: [HydrationEntry] = []
    @Published var dailyGoal: Double = 64.0  // Default to 64 oz (about 8 cups)
    
    // Computed property for today's entries
    var todayEntries: [HydrationEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.date) }
    }
    
    // Current progress towards daily goal
    var todayProgress: Double {
        let total = todayEntries.reduce(0) { $0 + $1.amount }
        return min(total / dailyGoal, 1.0)
    }
    
    // Amount consumed today
    var todayAmount: Double {
        return todayEntries.reduce(0) { $0 + $1.amount }
    }
    
    // Amount remaining for the goal
    var remainingAmount: Double {
        return max(dailyGoal - todayAmount, 0)
    }
    
    // Common drink sizes in ounces
    let commonSizes = [8.0, 12.0, 16.0]
    
    // Initialize and load data
    init() {
        loadEntries()
        loadSettings()
    }
    
    // Add a new entry
    func addEntry(_ amount: Double) {
        let entry = HydrationEntry(amount: amount)
        entries.append(entry)
        saveEntries()
    }
    
    // Remove an entry
    func removeEntry(_ entry: HydrationEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries.remove(at: index)
            saveEntries()
        }
    }
    
    // Update the daily goal
    func updateDailyGoal(_ goal: Double) {
        dailyGoal = goal
        saveSettings()
    }
    
    // Reset all hydration data
        func resetAllData() {
            // Clear all entries
            entries = []
            
            // Reset to default daily goal (64 oz)
            dailyGoal = 64.0
            
            // Save the changes to persistent storage
            saveEntries()
            saveSettings()
            
            // Provide haptic feedback
            WKInterfaceDevice.current().play(.notification)
        }
    
    // MARK: - Simple Persistence using UserDefaults
    
    // Save entries to UserDefaults
    private func saveEntries() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: "hydrationEntries")
        } catch {
            print("Failed to save entries: \(error.localizedDescription)")
        }
    }
    
    // Load entries from UserDefaults
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "hydrationEntries") {
            do {
                entries = try JSONDecoder().decode([HydrationEntry].self, from: data)
            } catch {
                print("Failed to load entries: \(error.localizedDescription)")
                entries = []
            }
        }
    }
    
    // Save settings to UserDefaults
    private func saveSettings() {
        UserDefaults.standard.set(dailyGoal, forKey: "dailyHydrationGoal")
    }
    
    // Load settings from UserDefaults
    private func loadSettings() {
        if let goal = UserDefaults.standard.object(forKey: "dailyHydrationGoal") as? Double {
            dailyGoal = goal
        }
    }
}
