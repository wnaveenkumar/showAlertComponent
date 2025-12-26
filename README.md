# showAlertComponent - ADCB macOS Compatibility Alert

A reusable Objective-C component for displaying macOS compatibility alerts, specifically designed for the ADCB application.

## 🎯 Overview

This component provides a cross-platform (macOS and iOS) alert dialog that informs users about application compatibility issues with macOS. The alert follows Apple's standard patterns for system compatibility warnings.

## 📋 Features

- ✅ Cross-platform support (macOS and iOS)
- ✅ Standard macOS alert styling with warning icon
- ✅ "Report" button to send diagnostics to Apple
- ✅ "OK" button to dismiss the alert
- ✅ Customizable message text
- ✅ Completion handler for button actions
- ✅ Thread-safe (automatically dispatches to main queue)

## 🚀 Quick Start

### Basic Usage

```objc
#import "ADCBCompatibilityAlert.h"

// Show default compatibility alert
[ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
    if (didClickReport) {
        // User clicked "Report" - handle sending diagnostics
        NSLog(@"Sending diagnostic report to Apple...");
    } else {
        // User clicked "OK" - alert dismissed
        NSLog(@"Alert dismissed");
    }
}];
```

### Custom Message

```objc
NSString *customMessage = @"Your custom compatibility message here.";

[ADCBCompatibilityAlert showCompatibilityAlertWithMessage:customMessage
                                               completion:^(BOOL didClickReport) {
    // Handle user action
}];
```

## 📁 Files Included

- **ADCBCompatibilityAlert.h** - Header file with interface
- **ADCBCompatibilityAlert.m** - Implementation with macOS and iOS support
- **SampleViewController.h** - Example view controller header
- **SampleViewController.m** - Example implementation showing usage

## 🔧 Integration

### 1. Add Files to Your Project

Copy these files to your Xcode project:
- `ADCBCompatibilityAlert.h`
- `ADCBCompatibilityAlert.m`
- `SampleViewController.h` (optional - for reference)
- `SampleViewController.m` (optional - for reference)

### 2. Import the Header

```objc
#import "ADCBCompatibilityAlert.h"
```

### 3. Show the Alert

Call the alert method when you need to notify users about compatibility issues:

```objc
[ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
    // Handle user response
}];
```

## 🎨 Alert Appearance

### macOS
- Uses `NSAlert` with warning style
- Caution icon (⚠️)
- Modal presentation
- "Report" button (primary/default)
- "OK" button (secondary)

### iOS
- Uses `UIAlertController` with alert style
- "Report" button (default style)
- "OK" button (cancel style)
- Automatically finds and presents from the top-most view controller

## 📝 Default Message

The default alert message reads:

> Check with the developer to make sure ADCB works with this version of macOS. You may need to reinstall the application. Be sure to install any available updates for the application and macOS.
>
> Click Report to see more detailed information and send a report to Apple.

## 🔍 Implementation Details

### Thread Safety
- All UI operations are automatically dispatched to the main queue
- Safe to call from any thread

### iOS View Controller Detection
- Automatically finds the top-most view controller
- Handles navigation controllers and tab bar controllers
- Falls back gracefully if no view controller is available

### Completion Handler
- Returns `YES` when "Report" is clicked
- Returns `NO` when "OK" is clicked
- Optional - can be `nil` if you don't need to handle responses

## 💡 Use Cases

1. **App Launch Compatibility Check**
   ```objc
   - (void)applicationDidFinishLaunching:(NSNotification *)notification {
       if ([self needsCompatibilityWarning]) {
           [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:nil];
       }
   }
   ```

2. **Feature-Specific Warnings**
   ```objc
   - (void)checkFeatureCompatibility {
       NSString *message = @"This feature may not work correctly with your macOS version.";
       [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:message completion:nil];
   }
   ```

3. **Update Reminder**
   ```objc
   - (void)remindUserToUpdate {
       [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
           if (didClickReport) {
               [self openUpdatePage];
           }
       }];
   }
   ```

## 🧪 Testing

See `SampleViewController.m` for a complete working example that demonstrates:
- How to trigger the alert
- How to handle the completion callback
- How to implement the "Report" action
- Diagnostic information collection

## 📄 License

This component is provided as-is for use in the ADCB application and related projects.

## 🤝 Contributing

Feel free to submit issues or pull requests to improve this component.