//  LoginAsample
//
//  Created by Wuppuluri Naveen Kumar on 10/09/25.
//
//  Updated: read values from DataStore and save only when Accept pressed.
//

#import "LoanApplicationViewController.h"

#import "CustomOTPAlertView.h"
#import "DataStore.h"

@interface LoanApplicationViewController ()

// existing outlets

@property (weak, nonatomic) IBOutlet UIImageView *loanShowDetailsButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIView *loanDetailsViewImp;
@property (nonatomic, assign) BOOL isCheckBoxChecked;
@property (weak, nonatomic) IBOutlet UIImageView *loandetailsCheckBox;

// Right-hand column labels in storyboard (make sure these are connected in IB)
@property (weak, nonatomic) IBOutlet UILabel *loanAccountNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *loanProductLabel;
@property (weak, nonatomic) IBOutlet UILabel *loanAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *interestRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *loanTenureLabel;
@property (weak, nonatomic) IBOutlet UILabel *loanEMILabel;
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *applicationStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *loanAmountLabelImp;
@property (weak, nonatomic) IBOutlet UILabel *loanTenureLabelImp;
@property (weak, nonatomic) IBOutlet UILabel *loanInterestRateImp;

@end

@implementation LoanApplicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loanDetailsViewImp.hidden  = YES;
    self.loanShowDetailsButton.userInteractionEnabled = YES;
    self.acceptButton.userInteractionEnabled = YES;
    self.declineButton.userInteractionEnabled = YES;
    self.isCheckBoxChecked = NO;
    self.loandetailsCheckBox.userInteractionEnabled = YES;
    self.acceptButton.enabled = NO; // Accept disabled until checkbox checked

    UITapGestureRecognizer *tapCheckbox = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(acceptCheckBoxTapped:)];
    [self.loandetailsCheckBox addGestureRecognizer:tapCheckbox];


    UITapGestureRecognizer *taploanShowDetailsButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loanShowDetailsButtonTapped:)];
    [self.loanShowDetailsButton addGestureRecognizer:taploanShowDetailsButton];
    
    // Safety: ensure the accept button triggers the action even if IB connection is missing
    [self.acceptButton addTarget:self action:@selector(acceptButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];

    // For debugging: make the accept button clearly visible (remove after debugging)
    self.acceptButton.backgroundColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.0 alpha:1.0]; // brownish as in UI
    self.acceptButton.layer.cornerRadius = 6.0;
    self.acceptButton.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // refresh UI from DataStore (no saving, no navigation)
    [self updateUIFromDataStore];
}

#pragma mark - Populate UI

- (void)updateUIFromDataStore {
    DataStore *store = [DataStore sharedInstance];

    // Debug log
    NSLog(@"[LoanApplication] populating UI from DataStore: acct=%@ product=%@ amount=%@ tenure=%ld interest=%@ emi=%@ bank=%@ status=%@",
          store.loanAccountNumber, store.loanProductName, store.loanAmount, (long)store.loanTenureMonths, store.interestRateAnnual ?: store.loanInterestRate, store.loanEMI ?: store.emi, store.bankName, store.applicationStatus);

    // Populate labels safely
    self.loanAccountNoLabel.text = (store.loanAccountNumber.length > 0) ? store.loanAccountNumber : @"";
    self.loanProductLabel.text   = (store.loanProductName.length > 0)   ? store.loanProductName   : @"";

    if (store.loanAmount != nil) {
        self.loanAmountLabel.text = [self formattedCurrencyStringFromDecimal:store.loanAmount];
        self.loanAmountLabelImp.text = [self formattedCurrencyStringFromDecimal:store.loanAmount];
    } else {
        self.loanAmountLabel.text = @"";
        self.loanAmountLabelImp.text = @"";
        
    }

    NSDecimalNumber *interest = store.interestRateAnnual ?: store.loanInterestRate;
    if (interest != nil) {
        self.interestRateLabel.text = [NSString stringWithFormat:@"%@ %%", [interest stringValue]];
        self.loanInterestRateImp.text = [NSString stringWithFormat:@"%@ %%", [interest stringValue]];
    } else {
        self.interestRateLabel.text = @"";
        self.loanInterestRateImp.text = @"";
    }

    if (store.loanTenureMonths > 0) {
        self.loanTenureLabel.text = [NSString stringWithFormat:@"%ld", (long)store.loanTenureMonths];
        self.loanTenureLabelImp.text = [NSString stringWithFormat:@"%ld", (long)store.loanTenureMonths];
    } else {
        self.loanTenureLabel.text = @"";
        self.loanTenureLabelImp.text = @"";
    }

    NSDecimalNumber *emiValue = store.loanEMI ?: store.emi;
    if (emiValue != nil) {
        self.loanEMILabel.text = [self formattedCurrencyStringFromDecimal:emiValue];
       
    } else {
        self.loanEMILabel.text = @"";
       
    }

    self.bankNameLabel.text = (store.bankName.length > 0) ? store.bankName : @"";
    self.applicationStatusLabel.text = (store.applicationStatus.length > 0) ? store.applicationStatus : @"";
}

#pragma mark - UI helpers

- (NSString *)formattedCurrencyStringFromDecimal:(NSDecimalNumber *)number {
    if (number == nil) return @"";
    static NSNumberFormatter *currencyFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currencyFormatter = [[NSNumberFormatter alloc] init];
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        NSLocale *ind = [[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"];
        if (ind) currencyFormatter.locale = ind;
        currencyFormatter.maximumFractionDigits = 2;
    });
    NSString *s = [currencyFormatter stringFromNumber:number];
    return s ?: [number stringValue];
}

- (NSString *)sanitizedNumberStringFromLabelText:(NSString *)text {
    if (text == nil) return @"";
    NSString *t = [text copy];
    t = [t stringByReplacingOccurrencesOfString:@"," withString:@""];
    t = [t stringByReplacingOccurrencesOfString:@"Re" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, t.length)];
    t = [t stringByReplacingOccurrencesOfString:@"₹" withString:@""];
    t = [t stringByReplacingOccurrencesOfString:@" " withString:@""];
    t = [t stringByReplacingOccurrencesOfString:@"%" withString:@""];
    t = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return t;
}

#pragma mark - Actions

- (void)acceptCheckBoxTapped:(UITapGestureRecognizer *)gestureRecognizer {
    self.isCheckBoxChecked = !self.isCheckBoxChecked;

      NSLog(@"acceptCheckBoxTapped: new state = %d", (int)self.isCheckBoxChecked);

    if (self.isCheckBoxChecked) {
        self.acceptButton.enabled = YES;
        self.acceptButton.alpha = 1.0;
        self.loandetailsCheckBox.image = [UIImage imageNamed:@"whitecheckboxone"];
    } else {
        self.acceptButton.enabled = NO;
        self.acceptButton.alpha = 0.5;
        self.loandetailsCheckBox.image = [UIImage imageNamed:@"whitecheckbox"];
    }
}


- (void)loanShowDetailsButtonTapped:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"Show Loan Details tapped!");
    self.loanDetailsViewImp.hidden  = NO;
}

#pragma mark - Save to DataStore (Accept button)

- (IBAction)acceptButtonOnClick:(id)sender {
    if (!self.isCheckBoxChecked) {
        NSLog(@"accept: checkbox not checked - showing alert");
        CustomOTPAlertView *alert = [[CustomOTPAlertView alloc] initWithMessage:@"Please accept terms to continue."];
        [alert.okButton addTarget:self action:@selector(dismissCustomAlert:) forControlEvents:UIControlEventTouchUpInside];
        [alert showInView:self.view];
        return;
    }

    DataStore *store = [DataStore sharedInstance];

    // Read UI values
    NSString *acctText = self.loanAccountNoLabel.text ?: @"";
    NSString *productText = self.loanProductLabel.text ?: @"";
    NSString *amountText = self.loanAmountLabel.text ?: @"";
    NSString *emiText = self.loanEMILabel.text ?: @"";
    NSString *interestText = self.interestRateLabel.text ?: @"";
    NSString *tenureText = self.loanTenureLabel.text ?: @"";
    NSString *bankText = self.bankNameLabel.text ?: @"";
    NSString *statusText = self.applicationStatusLabel.text ?: @"IN PROGRESS";

    // sanitize and convert
    NSString *amountSanitized = [self sanitizedNumberStringFromLabelText:amountText];
    NSString *emiSanitized = [self sanitizedNumberStringFromLabelText:emiText];
    NSString *interestSanitized = [self sanitizedNumberStringFromLabelText:interestText];
    NSInteger tenureValue = [tenureText integerValue];

    NSDecimalNumber *amountNumber = (amountSanitized.length > 0) ? [NSDecimalNumber decimalNumberWithString:amountSanitized] : [NSDecimalNumber zero];
    NSDecimalNumber *emiNumber = (emiSanitized.length > 0) ? [NSDecimalNumber decimalNumberWithString:emiSanitized] : [NSDecimalNumber zero];
    NSDecimalNumber *interestNumber = (interestSanitized.length > 0) ? [NSDecimalNumber decimalNumberWithString:interestSanitized] : [NSDecimalNumber zero];

    // Save to DataStore
    store.isPersonalLoanApplicationCompleted = YES;
    store.loanAccountNumber = acctText;
    store.loanProductName = productText;
    store.loanAmount = amountNumber;
    store.loanEMI = emiNumber;
    store.emi = emiNumber;
    store.interestRateAnnual = interestNumber;
    store.loanInterestRate = interestNumber;
    store.loanTenureMonths = tenureValue;
    store.bankName = bankText;
    store.applicationStatus = statusText;

    // Flags
    store.isCustomerLoanRequestConfirmed = YES;
    store.isLoanAgreementGenerated = YES;

    // Persist basic fields
    [store persistBasicLoanFieldsToUserDefaults];

    // Optional: maintain compatibility with existing NSUserDefaults keys
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isPersonalLoanApplicationCompleted"];
    [[NSUserDefaults standardUserDefaults] setObject:store.loanAccountNumber ?: @"" forKey:@"accountNo"];
    [[NSUserDefaults standardUserDefaults] setObject:[store.loanAmount stringValue] forKey:@"loanAmount"];
    [[NSUserDefaults standardUserDefaults] setObject:[store.loanEMI stringValue] forKey:@"loanEMI"];
    [[NSUserDefaults standardUserDefaults] setObject:[store.interestRateAnnual stringValue] forKey:@"loanInterest"];
    [[NSUserDefaults standardUserDefaults] setObject:[@(store.loanTenureMonths) stringValue] forKey:@"tenure"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isPanCardValidated"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isPanCardValidatedBefore"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCustomerDetailsValidated"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCustomerDetailsValidatedBefore"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCustomerLoanRequestConfirmed"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCustomerLoanRequestConfirmedBefore"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoanApplicationCompleted"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoanApplicationCompletedBefore"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoanAggrementGenerated"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Navigate forward
    
    NSLog(@"About to present AadharcarddetailsViewController");
    dispatch_async(dispatch_get_main_queue(), ^{
    self.loanDetailsViewImp.hidden = YES;
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AadharcarddetailsViewController"];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:^{
                NSLog(@"presentViewController completion called");
            }];
        });
        
        
}

- (void)dismissCustomAlert:(UIButton *)sender {
    UIView *alertView = sender.superview;
    [UIView animateWithDuration:0.2 animations:^{
        alertView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
    }];
}

- (IBAction)declineButtonOnclick:(id)sender {
    NSLog(@"Decline Button tapped!");
    self.loanDetailsViewImp.hidden  = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoanApplyViewController"];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
