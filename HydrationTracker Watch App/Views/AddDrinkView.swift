//
//  AddDrinkView.swift
//  HydrationTracker Watch App
//
//  Created by ryan mota on 2025-03-20.
//

import SwiftUI

struct AddDrinkView: View {
    @EnvironmentObject var store: HydrationStore
    @State private var selectedAmount = 8.0
    @State private var isAnimating = false
    
    private let amounts = [4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 32.0]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Add Water")
                .font(.system(size: 22, weight: .semibold))
                .padding(.top, 10)
            
            // Custom amount picker with a fancier style
            Picker("Amount", selection: $selectedAmount) {
                ForEach(amounts, id: \.self) { amount in
                    Text("\(Int(amount)) oz")
                        .font(.system(.body, design: .rounded))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 100)
            .onChange(of: selectedAmount) { _ in
                // Light haptic feedback when changing value
                WKInterfaceDevice.current().play(.click)
            }
            
            // Visual representation with animation
            ZStack {
                // Water glass outline
                Image(systemName: "drop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.blue.opacity(isAnimating ? 0.8 : 0.6))
                    .frame(width: min(50, selectedAmount * 1.5), height: min(70, selectedAmount * 2))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            .frame(height: 80)
            .padding(.vertical, 10)
            .onAppear {
                isAnimating = true
            }
            
            // Add button with improved styling
            Button(action: {
                store.addEntry(selectedAmount)
                
                // Haptic feedback
                WKInterfaceDevice.current().play(.success)
                
                // Animation for the button press
                withAnimation(.spring()) {
                    // You could add view state changes here if desired
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Add \(Int(selectedAmount)) oz")
                        .font(.system(size: 18, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(color: Color.blue.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
            
            // Today's consumption summary with improved style
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Today's Progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue.opacity(0.7), .blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(min(store.todayProgress, 1.0)), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(Int(store.todayAmount)) oz of \(Int(store.dailyGoal)) oz")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(.horizontal, 10)
    }
}

// Preview provider
struct AddDrinkView_Previews: PreviewProvider {
    static var previews: some View {
        AddDrinkView()
            .environmentObject(HydrationStore())
    }
}
