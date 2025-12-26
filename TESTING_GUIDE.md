# Testing Guide for ADCB Compatibility Alert

This guide explains how to test the ADCBCompatibilityAlert component.

## Prerequisites

- Xcode 12.0 or later
- macOS 10.15 (Catalina) or later for macOS testing
- iOS 13.0 or later for iOS testing

## Setup for Testing

### 1. Create a Test Project

#### macOS Test Project

```bash
# Create a new macOS application project
1. Open Xcode
2. File > New > Project
3. Choose "macOS" > "App"
4. Name it "ADCBAlertTest"
5. Language: Objective-C
6. Click "Create"
```

#### iOS Test Project

```bash
# Create a new iOS application project
1. Open Xcode
2. File > New > Project
3. Choose "iOS" > "App"
4. Name it "ADCBAlertTest"
5. Language: Objective-C
6. Click "Create"
```

### 2. Add Source Files

1. Drag and drop these files into your Xcode project:
   - `ADCBCompatibilityAlert.h`
   - `ADCBCompatibilityAlert.m`
   - `SampleViewController.h` (optional)
   - `SampleViewController.m` (optional)

2. Ensure "Copy items if needed" is checked
3. Select your app target

### 3. Add Unit Tests (Optional)

1. Add `ADCBCompatibilityAlertTests.m` to your test target
2. Build and run tests: Cmd+U

## Manual Testing Procedures

### Test 1: Basic Alert Display (macOS)

**Purpose:** Verify the alert appears correctly on macOS

**Steps:**
1. Open `AppDelegate.m`
2. Import the header: `#import "ADCBCompatibilityAlert.h"`
3. Add to `applicationDidFinishLaunching:`:
   ```objc
   [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
       NSLog(@"User clicked: %@", didClickReport ? @"Report" : @"OK");
   }];
   ```
4. Build and run (Cmd+R)

**Expected Result:**
- Alert appears with title "ADCB Compatibility"
- Warning icon (⚠️) is visible
- Message contains the default text about ADCB and macOS compatibility
- Two buttons: "Report" (primary) and "OK" (secondary)
- Alert is modal (blocks interaction with other windows)

**Pass Criteria:**
- ✅ Alert appears immediately on launch
- ✅ Warning icon is displayed
- ✅ Message text is readable and complete
- ✅ Both buttons are visible and properly labeled
- ✅ Alert is properly centered on screen

### Test 2: Basic Alert Display (iOS)

**Purpose:** Verify the alert appears correctly on iOS

**Steps:**
1. Open `AppDelegate.m` (iOS)
2. Import the header: `#import "ADCBCompatibilityAlert.h"`
3. Add to `application:didFinishLaunchingWithOptions:`:
   ```objc
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
       [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
           NSLog(@"User clicked: %@", didClickReport ? @"Report" : @"OK");
       }];
   });
   ```
4. Build and run on simulator or device

**Expected Result:**
- Alert appears after 1 second delay
- Title reads "ADCB Compatibility"
- Message contains default text
- Two buttons: "Report" and "OK"

**Pass Criteria:**
- ✅ Alert appears after delay
- ✅ Alert is centered on screen
- ✅ Text is readable on the device
- ✅ Both buttons work correctly

### Test 3: Report Button Action

**Purpose:** Verify the Report button triggers the correct callback

**Steps:**
1. Show the alert with a completion handler:
   ```objc
   [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
       if (didClickReport) {
           NSLog(@"✅ Report button clicked correctly");
           // Show confirmation
           #if TARGET_OS_OSX
           NSAlert *confirm = [[NSAlert alloc] init];
           [confirm setMessageText:@"Report Confirmed"];
           [confirm setInformativeText:@"Report button was clicked"];
           [confirm runModal];
           #else
           UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"Report Confirmed"
                                                                            message:@"Report button was clicked"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
           [confirm addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
           // Present from top view controller
           #endif
       }
   }];
   ```
2. Click "Report" button

**Expected Result:**
- Completion handler is called with `didClickReport = YES`
- Log message appears in console
- Confirmation alert appears

**Pass Criteria:**
- ✅ Callback receives YES when Report is clicked
- ✅ Console shows success message
- ✅ No crashes or errors

### Test 4: OK Button Action

**Purpose:** Verify the OK button triggers the correct callback

**Steps:**
1. Show the alert (same code as Test 3)
2. Click "OK" button

**Expected Result:**
- Completion handler is called with `didClickReport = NO`
- Alert dismisses
- No confirmation alert (since we only show it for Report)

**Pass Criteria:**
- ✅ Callback receives NO when OK is clicked
- ✅ Alert dismisses properly
- ✅ No crashes or errors

### Test 5: Custom Message

**Purpose:** Verify custom messages display correctly

**Steps:**
1. Create a custom message:
   ```objc
   NSString *customMsg = @"This is a custom compatibility message for testing purposes. "
                         @"It should display properly in the alert dialog.";
   
   [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:customMsg
                                                   completion:^(BOOL didClickReport) {
       NSLog(@"Custom message alert: %@", didClickReport ? @"Report" : @"OK");
   }];
   ```
2. Run the app

**Expected Result:**
- Alert displays with custom message instead of default
- Title remains "ADCB Compatibility"
- Buttons remain the same

**Pass Criteria:**
- ✅ Custom message is displayed correctly
- ✅ Message is fully visible and readable
- ✅ Title and buttons unchanged
- ✅ Functionality works the same

### Test 6: Nil Completion Handler

**Purpose:** Verify the alert works without a completion handler

**Steps:**
1. Show alert with nil completion:
   ```objc
   [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:nil];
   ```
2. Click both buttons separately (run twice)

**Expected Result:**
- Alert appears normally
- Buttons work (dismiss alert)
- No crashes when buttons are clicked

**Pass Criteria:**
- ✅ Alert displays properly
- ✅ Report button dismisses alert
- ✅ OK button dismisses alert
- ✅ No crashes or errors

### Test 7: Thread Safety

**Purpose:** Verify alert can be called from background thread

**Steps:**
1. Call from background thread:
   ```objc
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       NSLog(@"Calling from background thread");
       [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
           NSLog(@"Callback from background call: %@", didClickReport ? @"Report" : @"OK");
       }];
   });
   ```

**Expected Result:**
- Alert appears correctly (auto-dispatched to main queue)
- No threading warnings or crashes
- Buttons work normally

**Pass Criteria:**
- ✅ Alert appears without issues
- ✅ No threading-related crashes
- ✅ Functionality works correctly

### Test 8: Multiple Alerts

**Purpose:** Verify behavior when showing multiple alerts

**Steps:**
1. Show first alert
2. While first alert is visible, trigger second alert:
   ```objc
   [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
       NSLog(@"First alert: %@", didClickReport ? @"Report" : @"OK");
   }];
   
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
       [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:^(BOOL didClickReport) {
           NSLog(@"Second alert: %@", didClickReport ? @"Report" : @"OK");
       }];
   });
   ```

**Expected Result:**
- First alert appears
- Second alert appears after delay (macOS: queued, iOS: may queue or show immediately)
- Both alerts can be dismissed independently

**Pass Criteria:**
- ✅ Both alerts appear
- ✅ No crashes or visual glitches
- ✅ Each alert functions independently

### Test 9: Long Message Text

**Purpose:** Verify alert handles long messages properly

**Steps:**
1. Create a very long message:
   ```objc
   NSString *longMsg = @"This is a very long compatibility message that tests how the alert "
                       @"handles extensive text content. The alert should resize appropriately "
                       @"or provide scrolling if needed. This ensures that important information "
                       @"is not cut off or hidden from the user. The text should remain readable "
                       @"and the buttons should still be accessible. Additional text here to make "
                       @"this message even longer for comprehensive testing purposes.";
   
   [ADCBCompatibilityAlert showCompatibilityAlertWithMessage:longMsg completion:nil];
   ```

**Expected Result:**
- Alert displays all text (with scrolling if necessary)
- Buttons remain visible and accessible
- Alert doesn't extend beyond screen bounds

**Pass Criteria:**
- ✅ All text is accessible
- ✅ Buttons are visible
- ✅ Alert layout is reasonable

### Test 10: SampleViewController Integration

**Purpose:** Verify the sample view controller works correctly

**Steps:**
1. Add SampleViewController to your project
2. Set it as the initial view controller (storyboard or programmatically)
3. Run the app

**For macOS:**
- Alert should appear automatically on view load

**For iOS:**
- Button should appear saying "Show ADCB Compatibility Alert"
- Tap the button to show the alert

**Expected Result:**
- macOS: Alert appears on launch with proper handling
- iOS: Button triggers alert, both buttons work, and follow-up alerts appear

**Pass Criteria:**
- ✅ Sample view controller loads without errors
- ✅ Alert displays correctly
- ✅ Report button shows diagnostic confirmation
- ✅ OK button dismisses properly

## Automated Testing

### Running Unit Tests

```bash
# In Xcode
1. Cmd+U to run all tests
2. Or: Product > Test

# From command line
xcodebuild test -scheme ADCBAlertTest -destination 'platform=macOS'
```

**Expected Test Results:**
- All 8 unit tests should pass:
  - ✅ testAlertClassExists
  - ✅ testShowCompatibilityAlertMethodExists
  - ✅ testShowCompatibilityAlertWithMessageMethodExists
  - ✅ testAlertCanBeCalledWithNilCompletion
  - ✅ testAlertCanBeCalledWithCustomMessage
  - ✅ testCompletionHandlerStructure
  - ✅ testDefaultMessageContent
  - ✅ testSampleViewControllerExists

## Common Issues and Solutions

### Issue: Alert doesn't appear on iOS

**Solution:** Ensure you're calling from main thread and after view hierarchy is set up:
```objc
dispatch_async(dispatch_get_main_queue(), ^{
    [ADCBCompatibilityAlert showCompatibilityAlertWithCompletion:nil];
});
```

### Issue: Completion handler not called

**Solution:** Verify the alert is actually being presented. Check console for errors.

### Issue: Build errors about missing frameworks

**Solution:** Ensure these frameworks are linked:
- Foundation.framework
- AppKit.framework (macOS)
- UIKit.framework (iOS)

## Test Summary Checklist

After completing all tests, verify:

- [ ] Basic alert display works on macOS
- [ ] Basic alert display works on iOS
- [ ] Report button triggers correct callback
- [ ] OK button triggers correct callback
- [ ] Custom messages display correctly
- [ ] Nil completion handler doesn't crash
- [ ] Thread-safe operation confirmed
- [ ] Multiple alerts handled properly
- [ ] Long messages display correctly
- [ ] Sample view controller works
- [ ] All unit tests pass

## Performance Testing

### Memory Leaks

Use Xcode's Instruments (Product > Profile > Leaks):
1. Show alert multiple times
2. Check for memory leaks
3. Verify proper cleanup

**Expected:** No leaks detected

### UI Responsiveness

1. Show alert
2. Monitor main thread
3. Verify no blocking operations

**Expected:** Alert appears within 100ms, no main thread blocking

## Conclusion

If all tests pass, the ADCBCompatibilityAlert component is ready for production use. Document any issues found and ensure they are addressed before deployment.
