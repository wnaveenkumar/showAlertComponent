//
//  SampleViewController.m
//  showAlertComponent
//
//  Sample view controller demonstrating ADCBCompatibilityAlert usage
//

#import "SampleViewController.h"
#import "ADCBCompatibilityAlert.h"

@implementation SampleViewController

#if TARGET_OS_OSX
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Example: Show the alert when view loads
    // In real usage, you would trigger this based on a specific event or condition
    [self showCompatibilityAlert];
}

- (void)showCompatibilityAlert {
    [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
        if (didClickReport) {
            NSLog(@"User clicked Report - would send diagnostic information to Apple");
            [self handleReportAction];
        } else {
            NSLog(@"User clicked OK - dismissing alert");
        }
    }];
}

- (void)handleReportAction {
    // In a real implementation, this would collect diagnostic information
    // and prepare a report to send to Apple
    NSLog(@"Collecting diagnostic information...");
    NSLog(@"macOS Version: %@", [[NSProcessInfo processInfo] operatingSystemVersionString]);
    NSLog(@"Application Version: 1.0");
    
    // You could show another alert or open the system problem reporter
    NSAlert *reportAlert = [[NSAlert alloc] init];
    [reportAlert setMessageText:@"Report Sent"];
    [reportAlert setInformativeText:@"Diagnostic information has been collected and would be sent to Apple."];
    [reportAlert setAlertStyle:NSAlertStyleInformational];
    [reportAlert addButtonWithTitle:@"OK"];
    [reportAlert runModal];
}

#else // iOS implementation

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Add a button to trigger the alert
    UIButton *showAlertButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [showAlertButton setTitle:@"Show ADCB Compatibility Alert" forState:UIControlStateNormal];
    [showAlertButton addTarget:self action:@selector(showCompatibilityAlert) forControlEvents:UIControlEventTouchUpInside];
    showAlertButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:showAlertButton];
    
    // Center the button
    [NSLayoutConstraint activateConstraints:@[
        [showAlertButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [showAlertButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (void)showCompatibilityAlert {
    [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
        if (didClickReport) {
            NSLog(@"User clicked Report - would send diagnostic information to Apple");
            [self handleReportAction];
        } else {
            NSLog(@"User clicked OK - dismissing alert");
        }
    }];
}

- (void)handleReportAction {
    // In a real implementation, this would collect diagnostic information
    // and prepare a report to send to Apple
    NSLog(@"Collecting diagnostic information...");
    NSLog(@"iOS Version: %@", [[UIDevice currentDevice] systemVersion]);
    NSLog(@"Device Model: %@", [[UIDevice currentDevice] model]);
    NSLog(@"Application Version: 1.0");
    
    // Show confirmation
    UIAlertController *reportAlert = [UIAlertController alertControllerWithTitle:@"Report Sent"
                                                                         message:@"Diagnostic information has been collected and would be sent to Apple."
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [reportAlert addAction:okAction];
    
    [self presentViewController:reportAlert animated:YES completion:nil];
}

#endif

@end
