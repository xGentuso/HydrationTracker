# HydrationTracker for Apple Watch

A simple yet powerful watchOS application to help you stay hydrated throughout the day by tracking your water intake.

## Overview

HydrationTracker is a native watchOS application built with SwiftUI that makes tracking your daily water intake quick and convenient directly from your wrist. With an intuitive interface and thoughtful design, HydrationTracker makes staying hydrated a seamless part of your daily routine.

## Features

- **Simple Water Tracking**: Quickly log water consumption with just a few taps
- **Visual Progress Tracking**: See your daily hydration status at a glance with dynamic progress circles
- **Customizable Goals**: Set and adjust your personal daily hydration goals
- **Quick-Add Buttons**: Preset water amounts for faster tracking
- **Daily Summaries**: View your progress and remaining water needed to reach your goal
- **Local Data Storage**: All your hydration data is stored locally on your device

## App Screens

The app is organized into three main tabs:

1. **Progress View**: Visualizes your daily water intake with a beautiful circular progress indicator, showing percentage complete and amount consumed. Features quick-add buttons for common drink sizes.

2. **Add Drink View**: Allows precise selection of water amounts with a spinning wheel picker and animated visual feedback.

3. **Settings View**: Customize your daily water goal and manage app data.

## How to Use

### Track Water Intake

1. Open the app on your Apple Watch
2. Use any of these methods to log water:
   - Tap one of the quick-add buttons on the Progress screen (4oz, 8oz, 12oz, 16oz)
   - Swipe to the Add Drink tab, select your amount, and tap "Add"

### Set Your Hydration Goal

1. Swipe to the Settings tab
2. Use the picker to select your desired daily water goal
3. Tap "Save Goal" to update your goal

### View Your Progress

- The main screen shows your current progress as a percentage and the total amount consumed
- See remaining ounces needed to reach your goal
- View all of today's entries in the Settings screen

### Manage Your Data

- In the Settings tab, you can view your daily statistics
- Use the "Clear Today's Data" option to reset your daily tracking if needed

## Installation

### Requirements
- Apple Watch running watchOS 11.2 or later
- Xcode 16.2 or later (for development)

### Installation Steps

1. Clone this repository
2. Open the project in Xcode
3. Select your Apple Watch as the deployment target
4. Build and run the application

## Technical Details

HydrationTracker is built with:
- SwiftUI for the user interface
- Swift for the business logic
- UserDefaults for local data persistence

The app follows the MVVM architecture pattern:
- **Models**: `HydrationEntry` and `HydrationStore`
- **Views**: `ProgressView`, `AddDrinkView`, and `SettingsView`
- **ViewModel**: Integrated in the `HydrationStore` class

## Future Enhancements

- Hydration reminders and notifications
- Weekly and monthly statistics
- Health app integration
- Custom drink presets
- Detailed hydration history

## Support

If you encounter any issues or have suggestions for improvements, please open an issue in this repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
