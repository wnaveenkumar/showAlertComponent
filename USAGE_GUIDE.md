# ADCB Compatibility Alert - Usage Guide

## Introduction

This guide provides detailed instructions for using the ADCBCompatibilityAlert component in your macOS or iOS application.

## Table of Contents

1. [Installation](#installation)
2. [Basic Usage](#basic-usage)
3. [Advanced Usage](#advanced-usage)
4. [API Reference](#api-reference)
5. [Examples](#examples)
6. [Troubleshooting](#troubleshooting)

## Installation

### Manual Installation

1. Download or copy the following files to your project:
   - `ADCBCompatibilityAlert.h`
   - `ADCBCompatibilityAlert.m`

2. In Xcode, add these files to your project target:
   - Right-click on your project folder
   - Select "Add Files to [Your Project Name]"
   - Choose the downloaded files
   - Ensure "Copy items if needed" is checked
   - Select your app target

3. Import the header where needed:
   ```objc
   #import "ADCBCompatibilityAlert.h"
   ```

## Basic Usage

### Showing the Default Alert

The simplest way to show the alert with the default ADCB compatibility message:

```objc
[ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:nil];
```

### Handling User Response

To know which button the user clicked:

```objc
[ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
    if (didClickReport) {
        NSLog(@"User wants to report the issue");
        // Handle report action
    } else {
        NSLog(@"User dismissed the alert");
        // Continue normal flow
    }
}];
```

## Advanced Usage

### Custom Messages

Display a custom compatibility message:

```objc
NSString *customMsg = @"This version of ADCB requires macOS 11.0 or later. "
                      @"Please update your operating system to continue.";

[ADCBCompatibilityAlert showCompatibilityAlertWithMessage:customMsg
                                               completion:^(BOOL didClickReport) {
    if (didClickReport) {
        [self sendDiagnosticReport];
    }
}];
```

### Conditional Display

Show the alert only when needed:

```objc
- (void)checkCompatibility {
    NSOperatingSystemVersion minimumVersion = {10, 15, 0};
    BOOL isCompatible = [[NSProcessInfo processInfo] 
                         isOperatingSystemAtLeastVersion:minimumVersion];
    
    if (!isCompatible) {
        [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
            if (didClickReport) {
                [self generateAndSendReport];
            } else {
                [self handleIncompatibleSystem];
            }
        }];
    }
}
```

### Integration with App Delegate

#### macOS Application

```objc
// AppDelegate.m
#import "ADCBCompatibilityAlert.h"

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Check compatibility on app launch
    if ([self shouldShowCompatibilityWarning]) {
        [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
            if (didClickReport) {
                [self collectAndSubmitDiagnostics];
            }
        }];
    }
}

- (BOOL)shouldShowCompatibilityWarning {
    // Add your compatibility check logic here
    NSOperatingSystemVersion currentVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    return (currentVersion.majorVersion < 10 || 
           (currentVersion.majorVersion == 10 && currentVersion.minorVersion < 15));
}
```

#### iOS Application

```objc
// AppDelegate.m (iOS)
#import "ADCBCompatibilityAlert.h"

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Delay alert to ensure UI is ready
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), 
                   dispatch_get_main_queue(), ^{
        if ([self needsCompatibilityCheck]) {
            [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
                if (didClickReport) {
                    [self handleDiagnosticReport];
                }
            }];
        }
    });
    
    return YES;
}
```

## API Reference

### Class Methods

#### `showCompatibilityAlertWithCompletion:`

Shows the default ADCB compatibility alert.

```objc
+ (void)showCompatibilityAlertWithCompletion:(void (^)(BOOL didClickReport))completionHandler;
```

**Parameters:**
- `completionHandler`: Optional block called when user interacts with the alert
  - Parameter: `didClickReport` - YES if "Report" clicked, NO if "OK" clicked

**Thread Safety:** Can be called from any thread; UI updates are dispatched to main queue

---

#### `showCompatibilityAlertWithMessage:completion:`

Shows a compatibility alert with custom message.

```objc
+ (void)showCompatibilityAlertWithMessage:(NSString *)message
                               completion:(void (^)(BOOL didClickReport))completionHandler;
```

**Parameters:**
- `message`: Custom message text to display in the alert
- `completionHandler`: Optional block called when user interacts with the alert

**Thread Safety:** Can be called from any thread; UI updates are dispatched to main queue

## Examples

### Example 1: Version Check with Alert

```objc
#import "ADCBCompatibilityAlert.h"

- (void)verifySystemCompatibility {
    NSOperatingSystemVersion iOS13 = {13, 0, 0};
    
    if (![[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:iOS13]) {
        NSString *msg = @"ADCB requires iOS 13.0 or later. "
                        @"Please update your device to continue using this app.";
        
        [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:msg
                                                       completion:^(BOOL didClickReport) {
            if (didClickReport) {
                [self openAppStore];
            } else {
                [self exitApplication];
            }
        }];
    }
}
```

### Example 2: Feature-Specific Warning

```objc
- (void)checkBiometricAvailability {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics 
                              error:&error]) {
        NSString *msg = @"Biometric authentication is not available on this device. "
                        @"ADCB requires Touch ID or Face ID for secure transactions.";
        
        [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:msg
                                                       completion:^(BOOL didClickReport) {
            if (didClickReport) {
                [self sendFeatureCompatibilityReport:@"biometric"];
            }
        }];
    }
}
```

### Example 3: Network Requirement Alert

```objc
- (void)checkNetworkRequirements {
    if (![self isSecureConnectionAvailable]) {
        NSString *msg = @"ADCB requires a secure internet connection (TLS 1.2 or higher). "
                        @"Your current configuration may not support secure transactions.";
        
        [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:msg
                                                       completion:^(BOOL didClickReport) {
            if (didClickReport) {
                [self collectNetworkDiagnostics];
            } else {
                [self showNetworkSettings];
            }
        }];
    }
}
```

### Example 4: Collecting Diagnostic Information

```objc
- (void)collectAndSubmitDiagnostics {
    NSMutableDictionary *diagnostics = [NSMutableDictionary dictionary];
    
    // System information
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    diagnostics[@"os_version"] = [processInfo operatingSystemVersionString];
    diagnostics[@"processor_count"] = @([processInfo processorCount]);
    diagnostics[@"physical_memory"] = @([processInfo physicalMemory]);
    
    // App information
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    diagnostics[@"app_version"] = appInfo[@"CFBundleShortVersionString"];
    diagnostics[@"app_build"] = appInfo[@"CFBundleVersion"];
    
    // Device information (iOS)
#if !TARGET_OS_OSX
    UIDevice *device = [UIDevice currentDevice];
    diagnostics[@"device_model"] = device.model;
    diagnostics[@"device_name"] = device.name;
    diagnostics[@"system_version"] = device.systemVersion;
#endif
    
    NSLog(@"Diagnostic Report: %@", diagnostics);
    
    // In a real app, send this to your analytics or crash reporting service
    // [self sendDiagnosticsToServer:diagnostics];
}
```

## Troubleshooting

### Alert Not Showing on iOS

**Problem:** Alert doesn't appear when called.

**Solution:** Ensure the alert is called after the view hierarchy is established:

```objc
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Safe to show alert here
    [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:nil];
}
```

### Multiple Alerts Appearing

**Problem:** Alert shows multiple times unexpectedly.

**Solution:** Use a flag to track if the alert has been shown:

```objc
@property (nonatomic, assign) BOOL hasShownCompatibilityAlert;

- (void)showAlertOnce {
    if (!self.hasShownCompatibilityAlert) {
        self.hasShownCompatibilityAlert = YES;
        [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:nil];
    }
}
```

### Alert Appearing Behind Other Windows (macOS)

**Problem:** Alert appears but is hidden behind the main window.

**Solution:** The alert uses `runModal` which should bring it to front. If issues persist, ensure you're calling from the main thread:

```objc
dispatch_async(dispatch_get_main_queue(), ^{
    [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:nil];
});
```

### Completion Handler Not Called

**Problem:** The completion block doesn't execute.

**Solution:** Verify that the alert is being presented. Add logging:

```objc
[ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
    NSLog(@"Completion handler called: Report=%d", didClickReport);
}];
```

## Best Practices

1. **Show Early**: Display compatibility alerts as early as possible in the app lifecycle
2. **Be Specific**: Provide clear, actionable information in custom messages
3. **Handle Reports**: If using the Report button, implement proper diagnostic collection
4. **Don't Spam**: Only show the alert when truly necessary; consider using UserDefaults to track if user has dismissed it
5. **Localization**: For production apps, localize the alert messages for different languages

## Additional Resources

- [Apple Human Interface Guidelines - Alerts](https://developer.apple.com/design/human-interface-guidelines/components/presentation/alerts)
- [NSAlert Documentation](https://developer.apple.com/documentation/appkit/nsalert)
- [UIAlertController Documentation](https://developer.apple.com/documentation/uikit/uialertcontroller)
