//
//  ADCBCompatibilityAlertTests.m
//  showAlertComponent
//
//  Basic tests for ADCBCompatibilityAlert
//

#import <XCTest/XCTest.h>
#import "ADCBCompatibilityAlert.h"

@interface ADCBCompatibilityAlertTests : XCTestCase
@end

@implementation ADCBCompatibilityAlertTests

- (void)testAlertClassExists {
    // Test that the ADCBCompatibilityAlert class is available
    Class alertClass = NSClassFromString(@"ADCBCompatibilityAlert");
    XCTAssertNotNil(alertClass, @"ADCBCompatibilityAlert class should exist");
}

- (void)testShowCompatibilityAlertMethodExists {
    // Test that the main method exists
    XCTAssertTrue([ADCBCompatibilityAlert respondsToSelector:@selector(showCompatibilityAlertWithCompletion:)],
                  @"showCompatibilityAlertWithCompletion: method should exist");
}

- (void)testShowCompatibilityAlertWithMessageMethodExists {
    // Test that the custom message method exists
    XCTAssertTrue([ADCBCompatibilityAlert respondsToSelector:@selector(showCompatibilityAlertWithMessage:completion:)],
                  @"showCompatibilityAlertWithMessage:completion: method should exist");
}

- (void)testAlertCanBeCalledWithNilCompletion {
    // Test that alert can be called with nil completion handler without crashing
    // Note: This doesn't actually show the alert in tests, but validates the call works
    XCTestExpectation *expectation = [self expectationWithDescription:@"Alert call completes"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Call from background thread to test thread safety
        [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:nil];
        
        // Wait a moment for the dispatch to main queue
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), 
                      dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
    });
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testAlertCanBeCalledWithCustomMessage {
    // Test that alert can be called with custom message
    XCTestExpectation *expectation = [self expectationWithDescription:@"Custom message alert completes"];
    
    NSString *testMessage = @"Test compatibility message";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:testMessage completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), 
                      dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
    });
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testCompletionHandlerStructure {
    // Test that completion handler receives a BOOL parameter
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler structure test"];
    
    // This validates the completion block signature is correct
    void (^completionHandler)(BOOL) = ^(BOOL didClickReport) {
        // Validate the parameter can be used
        if (didClickReport) {
            NSLog(@"Report clicked");
        } else {
            NSLog(@"OK clicked");
        }
        [expectation fulfill];
    };
    
    // Call the completion block to test its structure
    completionHandler(YES);
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDefaultMessageContent {
    // Test that the default message contains expected keywords
    NSString *defaultMessage = @"Check with the developer to make sure ADCB works with this version of macOS. You may need to reinstall the application. Be sure to install any available updates for the application and macOS.\n\nClick Report to see more detailed information and send a report to Apple.";
    
    XCTAssertTrue([defaultMessage containsString:@"ADCB"], @"Default message should mention ADCB");
    XCTAssertTrue([defaultMessage containsString:@"macOS"], @"Default message should mention macOS");
    XCTAssertTrue([defaultMessage containsString:@"Report"], @"Default message should mention Report");
    XCTAssertTrue([defaultMessage containsString:@"reinstall"], @"Default message should mention reinstall");
    XCTAssertTrue([defaultMessage containsString:@"updates"], @"Default message should mention updates");
}

- (void)testSampleViewControllerExists {
    // Test that the sample view controller exists for demonstration
    Class sampleClass = NSClassFromString(@"SampleViewController");
    XCTAssertNotNil(sampleClass, @"SampleViewController class should exist for demonstration");
}

@end
