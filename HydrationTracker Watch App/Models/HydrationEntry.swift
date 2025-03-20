//
//  HydrationEntry.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//

import Foundation

// Simple struct representing a single hydration entry
struct HydrationEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var amount: Double  // in ounces
    
    // Initialize with current date by default
    init(id: UUID = UUID(), date: Date = Date(), amount: Double) {
        self.id = id
        self.date = date
        self.amount = amount
    }
    
    // For formatting the time of entry
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
