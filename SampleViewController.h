//
//  SampleViewController.h
//  showAlertComponent
//
//  Sample view controller demonstrating ADCBCompatibilityAlert usage
//

#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <Cocoa/Cocoa.h>
@interface SampleViewController : NSViewController
#else
#import <UIKit/UIKit.h>
@interface SampleViewController : UIViewController
#endif

@end
