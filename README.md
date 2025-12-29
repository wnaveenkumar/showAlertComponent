# showAlertComponent

## Mobile Number TextField Implementation

This repository contains an Objective-C implementation for restricting a UITextField to accept only numeric input with a maximum length of 10 characters, suitable for mobile number entry.

## Features

- ✅ Maximum length of 10 characters
- ✅ Numeric input only (0-9)
- ✅ Number pad keyboard for better UX
- ✅ Proper validation using UITextFieldDelegate

## Implementation

### Files

- `MobileNumberViewController.h` - Header file with view controller declaration
- `MobileNumberViewController.m` - Implementation file with text field validation logic

### Key Components

#### 1. Set Up the Text Field Delegate

```objective-c
self.mobileNumberTextField.delegate = self;
self.mobileNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
```

#### 2. Implement UITextFieldDelegate Method

The `textField:shouldChangeCharactersInRange:replacementString:` delegate method validates:
- Only numeric characters (0-9) are allowed
- Maximum length does not exceed 10 characters
- Backspace/delete operations are always allowed

```objective-c
#define MAX_LENGTH 10

- (BOOL)textField:(UITextField *)textField 
shouldChangeCharactersInRange:(NSRange)range 
replacementString:(NSString *)string {
    
    // Allow backspace/delete
    if ([string length] == 0) {
        return YES;
    }
    
    // Check if numeric only
    NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *characterSetFromString = [NSCharacterSet characterSetWithCharactersInString:string];
    
    if (![numbersOnly isSupersetOfSet:characterSetFromString]) {
        return NO;
    }
    
    // Check max length
    NSString *currentString = textField.text;
    NSUInteger newLength = [currentString length] + [string length] - range.length;
    
    if (newLength > MAX_LENGTH) {
        return NO;
    }
    
    return YES;
}
```

## How to Use in Your Xcode Project

### Step 1: Add Files to Your Project
1. Copy `MobileNumberViewController.h` and `MobileNumberViewController.m` to your Xcode project
2. Or copy the implementation code into your existing view controller

### Step 2: Interface Builder Setup
1. Open your Storyboard or XIB file
2. Add a UITextField to your view
3. Connect the text field to the `mobileNumberTextField` IBOutlet
4. In the Identity Inspector, set the Custom Class to `MobileNumberViewController`

### Step 3: Programmatic Setup (Alternative)
If creating the text field programmatically:

```objective-c
UITextField *mobileTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, 280, 40)];
mobileTextField.delegate = self;
mobileTextField.keyboardType = UIKeyboardTypeNumberPad;
mobileTextField.placeholder = @"Enter mobile number";
mobileTextField.borderStyle = UITextBorderStyleRoundedRect;
[self.view addSubview:mobileTextField];
```

Then implement the delegate method in your view controller.

### Step 4: Make Your View Controller Conform to UITextFieldDelegate
In your header file:
```objective-c
@interface YourViewController : UIViewController <UITextFieldDelegate>
```

## Configuration

### Changing Maximum Length
To change the maximum length, modify the `MAX_LENGTH` constant in the implementation file:

```objective-c
#define MAX_LENGTH 10  // Change this value as needed
```

### Alternative Validation Methods
The implementation file includes an alternative validation method using NSPredicate with regex. Uncomment the alternative method if you prefer that approach.

## Testing
Test the implementation by:
1. Running the app in iOS Simulator or on a device
2. Attempting to enter non-numeric characters (should be rejected)
3. Attempting to enter more than 10 digits (11th digit should be rejected)
4. Verifying backspace/delete works correctly

## Requirements
- iOS 8.0 or later
- Xcode 7.0 or later
- Objective-C

## License
This code is provided as-is for educational and implementation purposes.