//
//  ADCBCompatibilityAlert.m
//  showAlertComponent
//
//  macOS compatibility alert for ADCB application
//

#import "ADCBCompatibilityAlert.h"

@implementation ADCBCompatibilityAlert

+ (void)showCompatibilityAlertWithCompletion:(void (^ _Nullable)(BOOL didClickReport))completionHandler {
    NSString *defaultMessage = @"Check with the developer to make sure ADCB works with this version of macOS. You may need to reinstall the application. Be sure to install any available updates for the application and macOS.\n\nClick Report to see more detailed information and send a report to Apple.";
    
    [self showCompatibilityAlertWithMessage:defaultMessage completion:completionHandler];
}

+ (void)showCompatibilityAlertWithMessage:(NSString *)message
                               completion:(void (^ _Nullable)(BOOL didClickReport))completionHandler {
#if TARGET_OS_OSX
    // macOS implementation using NSAlert
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"ADCB Compatibility"];
        [alert setInformativeText:message];
        [alert setAlertStyle:NSAlertStyleWarning];
        
        // Add "Report" button (first button is the default/primary)
        [alert addButtonWithTitle:@"Report"];
        
        // Add "OK" button (secondary)
        [alert addButtonWithTitle:@"OK"];
        
        // Set icon to warning (use NSImageNameCaution for macOS 11+, fallback for earlier versions)
        if (@available(macOS 11.0, *)) {
            [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
        } else {
            // Fallback for macOS 10.15 and earlier
            [alert setIcon:[NSImage imageNamed:NSImageNameStatusUnavailable]];
        }
        
        // Run modal and handle response
        NSModalResponse response = [alert runModal];
        
        if (completionHandler) {
            // NSAlertFirstButtonReturn = Report button
            // NSAlertSecondButtonReturn = OK button
            BOOL didClickReport = (response == NSAlertFirstButtonReturn);
            completionHandler(didClickReport);
        }
    });
#else
    // iOS/iPadOS implementation using UIAlertController
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ADCB Compatibility"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        // Add "Report" action
        UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"Report"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            if (completionHandler) {
                completionHandler(YES);
            }
        }];
        
        // Add "OK" action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
            if (completionHandler) {
                completionHandler(NO);
            }
        }];
        
        [alert addAction:reportAction];
        [alert addAction:okAction];
        
        // Get the top-most view controller to present the alert
        UIViewController *rootViewController = [self topMostViewController];
        if (rootViewController) {
            [rootViewController presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"ADCBCompatibilityAlert: Unable to find view controller to present alert");
        }
    });
#endif
}

#if !TARGET_OS_OSX
/**
 * Helper method to find the top-most view controller in the hierarchy (iOS only)
 */
+ (UIViewController *)topMostViewController {
    UIViewController *rootViewController = nil;
    UIWindow *keyWindow = nil;
    
    // iOS 13+ uses UIWindowScene
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
        for (UIScene *scene in connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
                if (keyWindow) break;
                
                // Fallback to first window if no key window
                if (!keyWindow && windowScene.windows.count > 0) {
                    keyWindow = windowScene.windows[0];
                }
                if (keyWindow) break;
            }
        }
    } else {
        // Pre-iOS 13 fallback
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        
        if (!keyWindow && [UIApplication sharedApplication].windows.count > 0) {
            keyWindow = [UIApplication sharedApplication].windows[0];
        }
#pragma clang diagnostic pop
    }
    
    rootViewController = keyWindow.rootViewController;
    
    // Traverse to find the top-most presented view controller
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    
    // Handle navigation and tab bar controllers
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)rootViewController;
        rootViewController = navController.visibleViewController;
    } else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)rootViewController;
        rootViewController = tabController.selectedViewController;
        
        if ([rootViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)rootViewController;
            rootViewController = navController.visibleViewController;
        }
    }
    
    return rootViewController;
}
#endif

@end
