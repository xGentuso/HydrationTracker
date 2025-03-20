//
//  ProgressView.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//
import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var store: HydrationStore
    @State private var animatedProgress: Double = 0
    @State private var showResetTodayConfirmation = false
    
    // Computed color based on progress
    var progressColor: Color {
        let progress = store.todayProgress
        if progress < 0.3 {
            return Color(red: 0.9, green: 0.4, blue: 0.3) // Red-ish for low hydration
        } else if progress < 0.7 {
            return Color(red: 0.0, green: 0.6, blue: 0.9) // Blue for moderate hydration
        } else {
            return Color(red: 0.2, green: 0.8, blue: 0.5) // Teal for good hydration
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Main progress section
                VStack(spacing: 10) {
                    Text("Hydration")
                        .font(.system(size: 24, weight: .semibold))
                        .padding(.top, 10)
                    
                    ZStack {
                        // Background circle with shadow for depth
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 18)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        // Progress circle with gradient
                        Circle()
                            .trim(from: 0, to: CGFloat(animatedProgress))
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [progressColor.opacity(0.7), progressColor]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 18, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: animatedProgress)
                        
                        // Light reflection on the progress circle (subtle effect)
                        Circle()
                            .trim(from: 0, to: CGFloat(animatedProgress * 0.15))
                            .stroke(Color.white.opacity(0.6), lineWidth: 5)
                            .blur(radius: 3)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: animatedProgress)
                        
                        // Water drop icon
                        Image(systemName: "drop.fill")
                            .font(.system(size: 24))
                            .foregroundColor(progressColor.opacity(0.2))
                            .offset(y: -20)
                        
                        // Center content with progress percentage and amount
                        VStack(spacing: 8) {
                            Text("\(Int(store.todayProgress * 100))%")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(progressColor)
                                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                            
                            Text("\(Int(store.todayAmount)) oz")
                                .font(.system(size: 24, design: .rounded))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                    }
                    .frame(width: 160, height: 160)
                    .padding(.vertical, 20)
                    
                    // Goal info with improved typography
                    VStack(spacing: 6) {
                        Text("Goal: \(Int(store.dailyGoal)) oz")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(store.remainingAmount)) oz remaining")
                            .font(.system(size: 18))
                            .foregroundColor(store.remainingAmount > 0 ? .secondary : progressColor)
                            .padding(.bottom, 10)
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Quick add section with card-style buttons
                VStack(spacing: 15) {
                    Text("Add Water")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        quickAddButton(amount: 4, icon: "1.circle.fill")
                        quickAddButton(amount: 8, icon: "2.circle.fill")
                        quickAddButton(amount: 12, icon: "3.circle.fill")
                        quickAddButton(amount: 16, icon: "4.circle.fill")
                    }
                }
                .padding(.bottom, 10)
                
                // Reset today button
                Button(action: {
                    showResetTodayConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 14))
                        Text("Reset Today")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                    )
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                .alert(isPresented: $showResetTodayConfirmation) {
                    Alert(
                        title: Text("Reset Today's Progress"),
                        message: Text("Are you sure you want to clear all of today's hydration entries?"),
                        primaryButton: .destructive(Text("Reset")) {
                            // Remove today's entries
                            for entry in store.todayEntries {
                                store.removeEntry(entry)
                            }
                            
                            // Reset animated progress to zero
                            withAnimation {
                                animatedProgress = 0
                            }
                            
                            // Haptic feedback
                            WKInterfaceDevice.current().play(.success)
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .onAppear {
            // Start with zero and animate to actual progress when view appears
            animatedProgress = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    animatedProgress = store.todayProgress
                }
            }
        }
        .onChange(of: store.todayProgress) { _, newValue in
            withAnimation {
                animatedProgress = newValue
            }
        }
    }
    
    // Extracted function for consistent button styling
    private func quickAddButton(amount: Double, icon: String) -> some View {
        Button(action: {
            withAnimation {
                store.addEntry(amount)
                
                // Haptic feedback
                WKInterfaceDevice.current().play(.click)
            }
        }) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text("+ \(Int(amount)) oz")
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(.blue)
        }
    }
}

// Preview
struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environmentObject(HydrationStore())
    }
}
