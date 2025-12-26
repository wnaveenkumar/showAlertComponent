//
//  ADCBCompatibilityAlert.h
//  showAlertComponent
//
//  macOS compatibility alert for ADCB application
//

#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * ADCBCompatibilityAlert displays a macOS system alert informing users about
 * ADCB application compatibility issues with the current version of macOS.
 */
@interface ADCBCompatibilityAlert : NSObject

/**
 * Shows a compatibility alert with standard message about ADCB and macOS compatibility.
 * The alert includes options to "Report" (send details to Apple) and "OK" (dismiss).
 *
 * @param completionHandler Called when user interacts with the alert.
 *                          Returns YES if "Report" was clicked, NO if "OK" was clicked.
 */
+ (void)showCompatibilityAlertWithCompletion:(void (^ _Nullable)(BOOL didClickReport))completionHandler;

/**
 * Shows a compatibility alert with a custom message.
 *
 * @param message Custom message to display in the alert
 * @param completionHandler Called when user interacts with the alert.
 *                          Returns YES if "Report" was clicked, NO if "OK" was clicked.
 */
+ (void)showCompatibilityAlertWithMessage:(NSString *)message
                               completion:(void (^ _Nullable)(BOOL didClickReport))completionHandler;

@end

NS_ASSUME_NONNULL_END
