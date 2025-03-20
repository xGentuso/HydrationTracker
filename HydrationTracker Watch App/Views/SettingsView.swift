//
//  SettingsView.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: HydrationStore
    @State private var goalAmount: Double
    @State private var showConfirmation = false
    @State private var showSavedCheckmark = false
    
    // Initialize state from the environment object
    init() {
        _goalAmount = State(initialValue: 64.0)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Settings")
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.top, 10)
                
                // Daily goal section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Goal")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("How much water do you want to drink each day?")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                    
                    // Goal picker with improved styling
                    Picker("Daily Goal", selection: $goalAmount) {
                        ForEach([32.0, 48.0, 64.0, 80.0, 96.0, 128.0], id: \.self) { amount in
                            Text("\(Int(amount)) oz")
                                .font(.system(.body, design: .rounded))
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.05))
                    )
                }
                .padding(.horizontal, 15)
                
                // Save button with checkmark animation
                Button(action: {
                    store.updateDailyGoal(goalAmount)
                    
                    // Haptic feedback
                    WKInterfaceDevice.current().play(.success)
                    
                    // Show checkmark animation
                    withAnimation {
                        showSavedCheckmark = true
                    }
                    
                    // Hide checkmark after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showSavedCheckmark = false
                        }
                    }
                }) {
                    HStack {
                        Text("Save Goal")
                            .font(.system(size: 16, weight: .medium))
                            .opacity(showSavedCheckmark ? 0 : 1)
                        
                        if showSavedCheckmark {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                            .shadow(color: Color.blue.opacity(0.3), radius: 2, x: 0, y: 1)
                    )
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 15)
                .padding(.top, 10)
                
                Divider()
                    .padding(.vertical, 10)
                
                // Data management section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Data Management")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 15)
                    
                    // Statistics card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Today's Entries")
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text("\(store.todayEntries.count)")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 3) {
                                Text("Daily Average")
                                    .font(.system(size: 14, weight: .medium))
                                
                                // This would ideally be calculated from historical data
                                Text("\(Int(store.todayAmount)) oz")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                    }
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .padding(.horizontal, 15)
                    
                    // Clear today's data button
                    Button(action: {
                        // Show confirmation first
                        showConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                            
                            Text("Clear Today's Data")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.6), lineWidth: 1)
                                .background(Color.red.opacity(0.05))
                                .cornerRadius(12)
                        )
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 5)
                    .alert(isPresented: $showConfirmation) {
                        Alert(
                            title: Text("Clear Today's Data"),
                            message: Text("Are you sure you want to delete all of today's hydration entries?"),
                            primaryButton: .destructive(Text("Delete")) {
                                // Remove today's entries
                                for entry in store.todayEntries {
                                    store.removeEntry(entry)
                                }
                                
                                // Haptic feedback
                                WKInterfaceDevice.current().play(.success)
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            // Update the local state when the view appears
            goalAmount = store.dailyGoal
        }
    }
}

// Preview provider
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(HydrationStore())
    }
}
