//
//  MobileNumberViewController.m
//  showAlertComponent
//
//  Created on 12/29/2024.
//

#import "MobileNumberViewController.h"

@interface MobileNumberViewController ()

@end

@implementation MobileNumberViewController

#define MAX_LENGTH 10

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the delegate to self
    self.mobileNumberTextField.delegate = self;
    
    // Set the keyboard type to number pad for numeric input
    self.mobileNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    // Optional: Set placeholder text
    self.mobileNumberTextField.placeholder = @"Enter mobile number";
}

#pragma mark - UITextFieldDelegate Methods

/**
 * This method is called whenever the text field's text is about to change.
 * We use it to restrict the input to numeric characters only and enforce max length.
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Allow backspace/delete
    if ([string length] == 0) {
        return YES;
    }
    
    // Check if the replacement string contains only numeric characters
    NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *characterSetFromString = [NSCharacterSet characterSetWithCharactersInString:string];
    
    if (![numbersOnly isSupersetOfSet:characterSetFromString]) {
        // String contains non-numeric characters, reject the change
        return NO;
    }
    
    // Calculate the new length after the change
    NSString *currentString = textField.text;
    NSUInteger newLength = [currentString length] + [string length] - range.length;
    
    // Check if the new length exceeds the maximum length
    if (newLength > MAX_LENGTH) {
        return NO;
    }
    
    return YES;
}

/**
 * Alternative implementation using NSPredicate for numeric validation
 * Uncomment this method and comment out the above method to use this approach
 */
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Allow backspace/delete
    if ([string length] == 0) {
        return YES;
    }
    
    // Check if the replacement string contains only numeric characters using regex
    NSString *numberRegex = @"^[0-9]+$";
    NSPredicate *numberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    
    if (![numberPredicate evaluateWithObject:string]) {
        // String contains non-numeric characters, reject the change
        return NO;
    }
    
    // Calculate the new length after the change
    NSString *currentString = textField.text;
    NSUInteger newLength = [currentString length] + [string length] - range.length;
    
    // Check if the new length exceeds the maximum length
    if (newLength > MAX_LENGTH) {
        return NO;
    }
    
    return YES;
}
*/

@end
