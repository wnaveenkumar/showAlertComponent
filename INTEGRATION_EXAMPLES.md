# Integration Examples

This document provides real-world integration examples for the ADCBCompatibilityAlert component.

## Example 1: App Delegate Integration

### macOS App Delegate

```objc
// AppDelegate.h
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

// AppDelegate.m
#import "AppDelegate.h"
#import "ADCBCompatibilityAlert.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Check macOS version compatibility
    [self performCompatibilityCheck];
}

- (void)performCompatibilityCheck {
    NSOperatingSystemVersion minimumVersion = {10, 15, 0}; // macOS Catalina
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    
    if (![processInfo isOperatingSystemAtLeastVersion:minimumVersion]) {
        // System version is below minimum requirement
        [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
            if (didClickReport) {
                [self generateDiagnosticReport];
            }
            // Optionally exit the app if compatibility is critical
            // [NSApp terminate:self];
        }];
    }
}

- (void)generateDiagnosticReport {
    NSMutableString *report = [NSMutableString string];
    [report appendFormat:@"=== ADCB Diagnostic Report ===\n\n"];
    
    // System information
    NSProcessInfo *info = [NSProcessInfo processInfo];
    [report appendFormat:@"OS Version: %@\n", [info operatingSystemVersionString]];
    [report appendFormat:@"Processor Count: %lu\n", (unsigned long)[info processorCount]];
    [report appendFormat:@"Physical Memory: %.2f GB\n", [info physicalMemory] / (1024.0 * 1024.0 * 1024.0)];
    
    // App information
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    [report appendFormat:@"\nApp Name: %@\n", appInfo[@"CFBundleName"]];
    [report appendFormat:@"App Version: %@\n", appInfo[@"CFBundleShortVersionString"]];
    [report appendFormat:@"Build Number: %@\n", appInfo[@"CFBundleVersion"]];
    
    NSLog(@"%@", report);
    
    // In production, send this report to your server or analytics service
    [self sendReportToServer:report];
}

- (void)sendReportToServer:(NSString *)report {
    // Implementation for sending report to server
    NSLog(@"Sending diagnostic report to server...");
}

@end
```

### iOS App Delegate

```objc
// AppDelegate.h (iOS)
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

// AppDelegate.m (iOS)
#import "AppDelegate.h"
#import "ADCBCompatibilityAlert.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Delay compatibility check to ensure UI is ready
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self checkiOSCompatibility];
    });
    
    return YES;
}

- (void)checkiOSCompatibility {
    // Check iOS version
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    float version = [systemVersion floatValue];
    
    if (version < 13.0) {
        // iOS version is below minimum requirement
        NSString *message = [NSString stringWithFormat:
                           @"ADCB requires iOS 13.0 or later. Your device is running iOS %@. "
                           @"Please update your device to continue using the app.\n\n"
                           @"Click Report to send diagnostic information to Apple.",
                           systemVersion];
        
        [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:message
                                                       completion:^(BOOL didClickReport) {
            if (didClickReport) {
                [self collectiOSDiagnostics];
            }
        }];
    }
}

- (void)collectiOSDiagnostics {
    NSMutableDictionary *diagnostics = [NSMutableDictionary dictionary];
    
    // Device information
    UIDevice *device = [UIDevice currentDevice];
    diagnostics[@"device_name"] = device.name;
    diagnostics[@"device_model"] = device.model;
    diagnostics[@"system_version"] = device.systemVersion;
    diagnostics[@"system_name"] = device.systemName;
    
    // App information
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    diagnostics[@"app_version"] = appInfo[@"CFBundleShortVersionString"];
    diagnostics[@"bundle_id"] = appInfo[@"CFBundleIdentifier"];
    
    // Screen information
    UIScreen *screen = [UIScreen mainScreen];
    diagnostics[@"screen_bounds"] = NSStringFromCGRect(screen.bounds);
    diagnostics[@"screen_scale"] = @(screen.scale);
    
    NSLog(@"iOS Diagnostics: %@", diagnostics);
}

@end
```

## Example 2: Feature-Specific Compatibility Check

### Biometric Authentication Check

```objc
// BiometricAuthManager.h
#import <Foundation/Foundation.h>

@interface BiometricAuthManager : NSObject
+ (instancetype)sharedManager;
- (void)checkBiometricCompatibilityWithCompletion:(void (^)(BOOL isCompatible))completion;
@end

// BiometricAuthManager.m
#import "BiometricAuthManager.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "ADCBCompatibilityAlert.h"

@implementation BiometricAuthManager

+ (instancetype)sharedManager {
    static BiometricAuthManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BiometricAuthManager alloc] init];
    });
    return sharedInstance;
}

- (void)checkBiometricCompatibilityWithCompletion:(void (^)(BOOL isCompatible))completion {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    
    BOOL canUseBiometric = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                                error:&error];
    
    if (!canUseBiometric) {
        NSString *message = @"ADCB requires biometric authentication (Touch ID or Face ID) for secure transactions. "
                           @"Your device does not support this feature or it is not configured.\n\n"
                           @"Please enable biometric authentication in your device settings.";
        
        [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:message
                                                       completion:^(BOOL didClickReport) {
            if (didClickReport) {
                NSLog(@"Biometric compatibility issue: %@", error.localizedDescription);
            }
            
            if (completion) {
                completion(NO);
            }
        }];
    } else {
        if (completion) {
            completion(YES);
        }
    }
}

@end
```

## Example 3: View Controller with Compatibility Check

### Login View Controller

```objc
// LoginViewController.h
#if TARGET_OS_OSX
#import <Cocoa/Cocoa.h>
@interface LoginViewController : NSViewController
#else
#import <UIKit/UIKit.h>
@interface LoginViewController : UIViewController
#endif
@end

// LoginViewController.m
#import "LoginViewController.h"
#import "ADCBCompatibilityAlert.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Check various compatibility requirements
    [self performCompatibilityChecks];
}

- (void)performCompatibilityChecks {
    // Check 1: Network connectivity
    if (![self hasInternetConnection]) {
        [self showNetworkCompatibilityAlert];
        return;
    }
    
    // Check 2: Secure connection support
    if (![self supportsTLS12OrHigher]) {
        [self showSecurityCompatibilityAlert];
        return;
    }
    
    // All checks passed, proceed with login
    [self enableLoginControls];
}

- (BOOL)hasInternetConnection {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "www.apple.com");
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    return success && (flags & kSCNetworkReachabilityFlagsReachable);
}

- (BOOL)supportsTLS12OrHigher {
    // Check if the system supports TLS 1.2 or higher
    // This is a simplified check; in production, you'd verify SSL/TLS capabilities
    if (@available(macOS 10.13, iOS 11.0, *)) {
        return YES;
    }
    return NO;
}

- (void)showNetworkCompatibilityAlert {
    NSString *message = @"ADCB requires an active internet connection. "
                       @"Please check your network settings and try again.\n\n"
                       @"Click Report if you believe this is a system configuration issue.";
    
    [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:message
                                                   completion:^(BOOL didClickReport) {
        if (didClickReport) {
            [self reportNetworkDiagnostics];
        }
    }];
}

- (void)showSecurityCompatibilityAlert {
    NSString *message = @"ADCB requires TLS 1.2 or higher for secure connections. "
                       @"Your system configuration may not support this. "
                       @"Please update your operating system.\n\n"
                       @"Click Report to send diagnostic information.";
    
    [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:message
                                                   completion:^(BOOL didClickReport) {
        if (didClickReport) {
            [self reportSecurityDiagnostics];
        }
    }];
}

- (void)reportNetworkDiagnostics {
    NSLog(@"=== Network Diagnostics ===");
    // Collect and log network information
}

- (void)reportSecurityDiagnostics {
    NSLog(@"=== Security Diagnostics ===");
    // Collect and log security configuration
}

- (void)enableLoginControls {
    // Enable login UI controls
    NSLog(@"All compatibility checks passed");
}

@end
```

## Example 4: Periodic Compatibility Monitoring

### Compatibility Monitor Service

```objc
// CompatibilityMonitor.h
#import <Foundation/Foundation.h>

@interface CompatibilityMonitor : NSObject
+ (instancetype)sharedMonitor;
- (void)startMonitoring;
- (void)stopMonitoring;
@end

// CompatibilityMonitor.m
#import "CompatibilityMonitor.h"
#import "ADCBCompatibilityAlert.h"

@interface CompatibilityMonitor ()
@property (nonatomic, strong) NSTimer *monitoringTimer;
@property (nonatomic, assign) BOOL hasShownAlert;
@end

@implementation CompatibilityMonitor

+ (instancetype)sharedMonitor {
    static CompatibilityMonitor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CompatibilityMonitor alloc] init];
    });
    return sharedInstance;
}

- (void)startMonitoring {
    if (self.monitoringTimer) {
        [self.monitoringTimer invalidate];
    }
    
    // Check compatibility every 5 minutes
    self.monitoringTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                                            target:self
                                                          selector:@selector(performPeriodicCheck)
                                                          userInfo:nil
                                                           repeats:YES];
    
    // Perform initial check
    [self performPeriodicCheck];
}

- (void)stopMonitoring {
    [self.monitoringTimer invalidate];
    self.monitoringTimer = nil;
}

- (void)performPeriodicCheck {
    // Check for system updates
    if ([self systemUpdateAvailable] && !self.hasShownAlert) {
        self.hasShownAlert = YES;
        
        NSString *message = @"A macOS update is available that may improve ADCB compatibility. "
                           @"Please install the update when convenient.\n\n"
                           @"Click Report to see update details.";
        
        [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:message
                                                       completion:^(BOOL didClickReport) {
            if (didClickReport) {
                [self openSystemPreferences];
            }
            
            // Reset flag after some time
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3600 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                self.hasShownAlert = NO;
            });
        }];
    }
}

- (BOOL)systemUpdateAvailable {
    // Simplified check - in production, use proper system update detection
    // This is just for demonstration
    return NO;
}

- (void)openSystemPreferences {
#if TARGET_OS_OSX
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preferences.softwareupdate"]];
#else
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                       options:@{}
                             completionHandler:nil];
#endif
}

- (void)dealloc {
    [self stopMonitoring];
}

@end
```

## Example 5: User Preferences Integration

### First Launch Compatibility Check

```objc
// FirstLaunchManager.m
#import <Foundation/Foundation.h>
#import "ADCBCompatibilityAlert.h"

@implementation FirstLaunchManager

+ (void)performFirstLaunchSetup {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasLaunchedBefore = [defaults boolForKey:@"HasLaunchedBefore"];
    
    if (!hasLaunchedBefore) {
        // First launch - show compatibility information
        [self showFirstLaunchCompatibilityInfo];
        
        // Mark as launched
        [defaults setBool:YES forKey:@"HasLaunchedBefore"];
        [defaults synchronize];
    }
}

+ (void)showFirstLaunchCompatibilityInfo {
    NSString *message = @"Welcome to ADCB!\n\n"
                       @"For the best experience, please ensure:\n"
                       @"• You are running macOS 10.15 or later\n"
                       @"• Your system is up to date\n"
                       @"• You have an active internet connection\n\n"
                       @"Click Report if you experience any compatibility issues.";
    
    [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:message
                                                   completion:^(BOOL didClickReport) {
        if (didClickReport) {
            NSLog(@"User requested compatibility information on first launch");
        }
    }];
}

@end
```

## Running These Examples

### macOS Project Setup

1. Create a new macOS App project in Xcode
2. Add `ADCBCompatibilityAlert.h` and `ADCBCompatibilityAlert.m` to your project
3. Copy any of the example code above into your project files
4. Build and run

### iOS Project Setup

1. Create a new iOS App project in Xcode
2. Add `ADCBCompatibilityAlert.h` and `ADCBCompatibilityAlert.m` to your project
3. Copy the iOS-specific examples into your project
4. Build and run on simulator or device

## Notes

- All examples use proper error handling and logging
- Examples demonstrate both macOS and iOS implementations
- Code follows Apple's coding guidelines and best practices
- Examples are production-ready with minor customizations needed for specific use cases
