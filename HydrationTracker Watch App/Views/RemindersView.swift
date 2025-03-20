//
//  RemindersView.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//

import SwiftUI

struct RemindersView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var selectedInterval = 1
    @State private var selectedStartHour = 8
    @State private var selectedStartMinute = 0
    @State private var selectedEndHour = 22
    @State private var selectedEndMinute = 0
    @State private var timePickerExpanded = false
    
    // Create a time formatter for displaying times
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Header
                Text("Hydration Reminders")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 10)
                
                // Enable/disable toggle
                Toggle(isOn: Binding(
                    get: { reminderManager.isRemindersEnabled },
                    set: { reminderManager.toggleReminders($0) }
                )) {
                    Text("Enable Reminders")
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 15)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                
                if reminderManager.isRemindersEnabled {
                    // Reminder interval section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Remind me every:")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 15)
                        
                        // Interval picker with proper sizing
                        Picker("", selection: $selectedInterval) {
                            ForEach(1...6, id: \.self) { hour in
                                Text("\(hour) hour\(hour > 1 ? "s" : "")")
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 90)
                        .padding(.horizontal, 15)
                        .background(Color.black)
                        .onChange(of: selectedInterval) { newValue in
                            // Convert hours to seconds
                            let intervalInSeconds = TimeInterval(newValue * 60 * 60)
                            reminderManager.updateReminderInterval(intervalInSeconds)
                        }
                    }
                    .padding(.top, 5)
                    
                    // Reminder time range
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active hours:")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 15)
                        
                        // Start and End time display
                        HStack(spacing: 15) {
                            // Start time button
                            VStack(alignment: .center, spacing: 5) {
                                Text("Start")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    // Initialize with current values
                                    let calendar = Calendar.current
                                    selectedStartHour = calendar.component(.hour, from: reminderManager.reminderStartTime)
                                    selectedStartMinute = calendar.component(.minute, from: reminderManager.reminderStartTime)
                                    withAnimation {
                                        timePickerExpanded = true
                                    }
                                }) {
                                    Text(timeFormatter.string(from: reminderManager.reminderStartTime))
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.blue)
                                        .frame(minWidth: 90, minHeight: 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.gray.opacity(0.2))
                                        )
                                }
                            }
                            
                            // End time button
                            VStack(alignment: .center, spacing: 5) {
                                Text("End")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    // Initialize with current values
                                    let calendar = Calendar.current
                                    selectedEndHour = calendar.component(.hour, from: reminderManager.reminderEndTime)
                                    selectedEndMinute = calendar.component(.minute, from: reminderManager.reminderEndTime)
                                    withAnimation {
                                        timePickerExpanded = false
                                    }
                                }) {
                                    Text(timeFormatter.string(from: reminderManager.reminderEndTime))
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.blue)
                                        .frame(minWidth: 90, minHeight: 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.gray.opacity(0.2))
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        
                        // Time picker content
                        if timePickerExpanded {
                            // Start Time picker
                            TimePickerView(
                                hour: $selectedStartHour,
                                minute: $selectedStartMinute,
                                title: "Set Start Time",
                                onSave: {
                                    let calendar = Calendar.current
                                    if let newDate = calendar.date(bySettingHour: selectedStartHour, minute: selectedStartMinute, second: 0, of: Date()) {
                                        reminderManager.updateReminderStartTime(newDate)
                                    }
                                    withAnimation {
                                        timePickerExpanded = false
                                    }
                                }
                            )
                            .padding(.horizontal, 10)
                        } else {
                            // End Time picker
                            TimePickerView(
                                hour: $selectedEndHour,
                                minute: $selectedEndMinute,
                                title: "Set End Time",
                                onSave: {
                                    let calendar = Calendar.current
                                    if let newDate = calendar.date(bySettingHour: selectedEndHour, minute: selectedEndMinute, second: 0, of: Date()) {
                                        reminderManager.updateReminderEndTime(newDate)
                                    }
                                    withAnimation {
                                        timePickerExpanded = true
                                    }
                                }
                            )
                            .padding(.horizontal, 10)
                        }
                    }
                    
                    // Information card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tips")
                            .font(.system(size: 14, weight: .medium))
                        
                        Text("• Tap times to adjust with pickers")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("• Set active hours for when you're awake")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                }
                
                Spacer(minLength: 10)
            }
            .padding(.bottom, 15)
        }
        .onAppear {
            // Set the selected interval from the manager when view appears
            selectedInterval = Int(reminderManager.reminderInterval / 3600)
            
            // Initialize picker values
            let calendar = Calendar.current
            selectedStartHour = calendar.component(.hour, from: reminderManager.reminderStartTime)
            selectedStartMinute = calendar.component(.minute, from: reminderManager.reminderStartTime)
            selectedEndHour = calendar.component(.hour, from: reminderManager.reminderEndTime)
            selectedEndMinute = calendar.component(.minute, from: reminderManager.reminderEndTime)
        }
    }
}

struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersView()
            .environmentObject(ReminderManager())
    }
}
