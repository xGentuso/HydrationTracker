//
//  TimePickerView.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//

import SwiftUI

struct TimePickerView: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @State private var isAM: Bool
    var title: String
    var onSave: () -> Void
    
    // Initialize with conversion from 24-hour to 12-hour format
    init(hour: Binding<Int>, minute: Binding<Int>, title: String, onSave: @escaping () -> Void) {
        self._hour = hour
        self._minute = minute
        self.title = title
        self.onSave = onSave
        
        // Convert 24-hour format to 12-hour format with AM/PM
        _isAM = State(initialValue: hour.wrappedValue < 12)
    }
    
    // Convert 24-hour to 12-hour format for display
    private var displayHour: Int {
        let h = hour % 12
        return h == 0 ? 12 : h
    }
    
    // Convert 12-hour back to 24-hour when saving
    private var hour24: Int {
        return isAM ? (displayHour == 12 ? 0 : displayHour) : (displayHour == 12 ? 12 : displayHour + 12)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .padding(.top, 5)
            
            // Time picker with larger frames and better spacing
            HStack(spacing: 15) {
                // Hour picker (12-hour format)
                VStack {
                    Text("Hour")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Picker("Hour", selection: Binding(
                        get: { self.displayHour },
                        set: { newValue in
                            // Convert 12-hour input to 24-hour format for storage
                            let newHour = isAM ?
                                (newValue == 12 ? 0 : newValue) :
                                (newValue == 12 ? 12 : newValue + 12)
                            self.hour = newHour
                        }
                    )) {
                        ForEach(1...12, id: \.self) { hour in
                            Text("\(hour)")
                                .font(.system(size: 20))
                                .tag(hour)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 50, height: 100)
                    .compositingGroup()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // Minute picker
                VStack {
                    Text("Minute")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Picker("Minute", selection: $minute) {
                        ForEach(0...55, id: \.self) { minute in
                            if minute % 5 == 0 {
                                Text("\(minute, specifier: "%02d")")
                                    .font(.system(size: 20))
                                    .tag(minute)
                            }
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 50, height: 100)
                    .compositingGroup()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // AM/PM picker
                VStack {
                    Text("AM/PM")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Picker("AM/PM", selection: $isAM) {
                        Text("AM").tag(true)
                        Text("PM").tag(false)
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 60, height: 100)
                    .compositingGroup()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .onChange(of: isAM) { newValue in
                        // Update the hour in 24-hour format when AM/PM changes
                        hour = newValue ?
                            (displayHour == 12 ? 0 : displayHour) :
                            (displayHour == 12 ? 12 : displayHour + 12)
                    }
                }
            }
            .padding(.vertical, 10)
            
            Button(action: {
                // Before saving, ensure the hour is in 24-hour format
                hour = hour24
                onSave()
            }) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 15)
            .padding(.top, 5)
        }
        .padding(.vertical, 5)
        .background(Color.black)
    }
}

