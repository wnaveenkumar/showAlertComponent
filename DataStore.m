//
//  DataStore.m
//  LoanOriginationSystem
//
//  Created by Wuppuluri Naveen Kumar on 21/11/25.
//

#import "DataStore.h"

static NSString * const kDSLoanRequestNumberKey = @"loanRequestNumber";
static NSString * const kDSLastLoanSequenceKey = @"kLastLoanRequestSequenceKey";
static NSString * const kDSLoanAccountKey = @"DS_LoanAccountNumber";
static NSString * const kDSLoanAmountKey = @"DS_LoanAmount";
static NSString * const kDSLoanEMIKey = @"DS_LoanEMI";
static NSString * const kDSLoanInterestKey = @"DS_LoanInterest";
static NSString * const kDSLoanTenureKey = @"DS_LoanTenure";
static NSString * const kDSBankNameKey = @"DS_BankName";
static NSString * const kDSAppStatusKey = @"DS_ApplicationStatus";
static NSString * const kDSPersonalLoanCompletedKey = @"DS_IsPersonalLoanApplicationCompleted";
static NSString * const kDSCustomerLoanRequestConfirmedKey = @"DS_IsCustomerLoanRequestConfirmed";
static NSString * const kDSLoanApplicationCompletedKey = @"DS_IsLoanApplicationCompleted";
static NSString * const kDSLoanAgreementGeneratedKey = @"DS_IsLoanAgreementGenerated";

static NSString * const kDSKey_emi = @"DataStore.emi";
static NSString * const kDSKey_loanEMI = @"DataStore.loanEMI";
static NSString * const kDSKey_processingFee = @"DataStore.processingFee";



static NSString * const kDSKey_firstName = @"DataStore.firstName";
static NSString * const kDSKey_middleName = @"DataStore.middleName";
static NSString * const kDSKey_lastName = @"DataStore.lastName";
static NSString * const kDSKey_dob = @"DataStore.dob";
static NSString * const kDSKey_age = @"DataStore.age";
static NSString * const kDSKey_mobileNumber = @"DataStore.mobileNumber";
static NSString * const kDSKey_aadharNumber = @"DataStore.aadharNumber";
static NSString * const kDSKey_panNumber = @"DataStore.panNumber";
static NSString * const kDSKey_email = @"DataStore.email";

static NSString * const kDSKey_addressLineOne = @"DataStore.addressLineOne";
static NSString * const kDSKey_addressLineTwo = @"DataStore.addressLineTwo";
static NSString * const kDSKey_addressLineThree = @"DataStore.addressLineThree";
static NSString * const kDSKey_district = @"DataStore.district";
static NSString * const kDSKey_city = @"DataStore.city";
static NSString * const kDSKey_country = @"DataStore.country";
static NSString * const kDSKey_pincode = @"DataStore.pincode";

static NSString * const kDSKey_companyName = @"DataStore.companyName";
static NSString * const kDSKey_designation = @"DataStore.designation";
static NSString * const kDSKey_salarySlipFileName = @"DataStore.salarySlipFileName";
static NSString * const kDSKey_salarySlipFileURL = @"DataStore.salarySlipFileURL";
static NSString * const kDSKey_offerLetterFileName = @"DataStore.offerLetterFileName";
static NSString * const kDSKey_offerLetterFileURL = @"DataStore.offerLetterFileURL";

@interface DataStore ()
@end

@implementation DataStore

// Synthesize with custom backing storage for synonym properties
@synthesize emi = _emiStorage;
@synthesize loanEMI = _loanEMIStorage;
@synthesize interestRateAnnual = _interestRateAnnualStorage;
@synthesize loanInterestRate = _loanInterestRateStorage;

#pragma mark - Custom Property Accessors (Synchronize Synonyms)

// Synchronize emi and loanEMI
- (void)setEmi:(NSDecimalNumber *)emi {
    _emiStorage = emi;
    _loanEMIStorage = emi; // Keep synonym in sync
}

- (NSDecimalNumber *)emi {
    return _emiStorage;
}

- (void)setLoanEMI:(NSDecimalNumber *)loanEMI {
    _loanEMIStorage = loanEMI;
    _emiStorage = loanEMI; // Keep synonym in sync
}

- (NSDecimalNumber *)loanEMI {
    return _loanEMIStorage;
}

// Synchronize interestRateAnnual and loanInterestRate
- (void)setInterestRateAnnual:(NSDecimalNumber *)interestRateAnnual {
    _interestRateAnnualStorage = interestRateAnnual;
    _loanInterestRateStorage = interestRateAnnual; // Keep synonym in sync
}

- (NSDecimalNumber *)interestRateAnnual {
    return _interestRateAnnualStorage;
}

- (void)setLoanInterestRate:(NSDecimalNumber *)loanInterestRate {
    _loanInterestRateStorage = loanInterestRate;
    _interestRateAnnualStorage = loanInterestRate; // Keep synonym in sync
}

- (NSDecimalNumber *)loanInterestRate {
    return _loanInterestRateStorage;
}

+ (instancetype)sharedInstance {
    static DataStore *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[DataStore alloc] init];
        // load persisted basic fields
        [shared loadPersistedBasicLoanFieldsFromUserDefaults];
        // load persisted personal fields (if implemented)
        if ([shared respondsToSelector:@selector(loadPersistedPersonalFieldsFromUserDefaults)]) {
            [shared loadPersistedPersonalFieldsFromUserDefaults];
        }
        // load persisted address fields (if implemented)
        if ([shared respondsToSelector:@selector(loadPersistedAddressFieldsFromUserDefaults)]) {
            [shared loadPersistedAddressFieldsFromUserDefaults];
        }
        // load persisted employment/document fields (new)
        [shared loadPersistedEmploymentFieldsFromUserDefaults];
        
        NSString *savedRequest = [[NSUserDefaults standardUserDefaults] stringForKey:kDSLoanRequestNumberKey];
        if (savedRequest.length > 0) {
            shared.loanRequestNumber = savedRequest;
        }


     
    });
    return shared;
}

#pragma mark - Computed name helpers

- (NSString *)combinedFirstMiddleName {
    NSString *first = (self.firstName ?: @"");
    NSString *middle = (self.middleName ?: @"");
    NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    first = [first stringByTrimmingCharactersInSet:trimSet];
    middle = [middle stringByTrimmingCharactersInSet:trimSet];
    if (first.length > 0 && middle.length > 0) {
        return [NSString stringWithFormat:@"%@ %@", first, middle];
    } else if (first.length > 0) {
        return first;
    } else if (middle.length > 0) {
        return middle;
    } else {
        return @""; // empty if neither present
    }
}

- (NSString *)fullName {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    NSString *first = [self.firstName ?: @"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *middle = [self.middleName ?: @"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *last = [self.lastName ?: @"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (first.length > 0) [parts addObject:first];
    if (middle.length > 0) [parts addObject:middle];
    if (last.length > 0) [parts addObject:last];
    if (parts.count == 0) return @"";
    return [parts componentsJoinedByString:@" "];
}

#pragma mark - Generate Loan Request Number

- (NSString *)generateAndSaveLoanRequestNumber {
    @synchronized (self) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

        // Read last sequence; start from a seed if missing
        NSInteger lastSeq = [ud integerForKey:kDSLastLoanSequenceKey];
        if (lastSeq == 0) {
            // seed value — change as required
            lastSeq = 101000000;
        }

        // increment
        NSInteger newSeq = lastSeq + 1;

        // Persist the new sequence
        [ud setInteger:newSeq forKey:kDSLastLoanSequenceKey];

        // Format as string. Example format: 9 digits (e.g., 101010001)
        NSString *requestNo = [NSString stringWithFormat:@"%09ld", (long)newSeq];

        // Save into DataStore property and persist the last generated string too
        self.loanRequestNumber = requestNo;
        [ud setObject:requestNo forKey:kDSLoanRequestNumberKey];

        [ud synchronize];

        return requestNo;
    }
}

#pragma mark - Persistence helpers

- (void)persistBasicLoanFieldsToUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    if (self.loanRequestNumber != nil) {
        [ud setObject:self.loanRequestNumber forKey:kDSLoanRequestNumberKey];
    }
    if (self.loanAccountNumber != nil) {
        [ud setObject:self.loanAccountNumber forKey:kDSLoanAccountKey];
    }
    if (self.loanAmount != nil) {
        [ud setObject:[self.loanAmount stringValue] forKey:kDSLoanAmountKey];
    }
    
    // Save EMI values using new keys only
    if (self.emi != nil) {
        [ud setObject:[self.emi stringValue] forKey:kDSKey_emi];
    } else {
        [ud removeObjectForKey:kDSKey_emi];
    }
    
    if (self.loanEMI != nil) {
        [ud setObject:[self.loanEMI stringValue] forKey:kDSKey_loanEMI];
    } else {
        [ud removeObjectForKey:kDSKey_loanEMI];
    }
    
    if (self.interestRateAnnual != nil) {
        [ud setObject:[self.interestRateAnnual stringValue] forKey:kDSLoanInterestKey];
    } else if (self.loanInterestRate != nil) {
        [ud setObject:[self.loanInterestRate stringValue] forKey:kDSLoanInterestKey];
    }
    if (self.loanTenureMonths > 0) {
        [ud setObject:@(self.loanTenureMonths) forKey:kDSLoanTenureKey];
    }
    if (self.bankName != nil) {
        [ud setObject:self.bankName forKey:kDSBankNameKey];
    }
    if (self.applicationStatus != nil) {
        [ud setObject:self.applicationStatus forKey:kDSAppStatusKey];
    }
    if (self.processingFee) {
        [ud setObject:[self.processingFee stringValue] forKey:kDSKey_processingFee];
    } else {
        [ud removeObjectForKey:kDSKey_processingFee];
    }

    // Flags
    [ud setBool:self.isPersonalLoanApplicationCompleted forKey:kDSPersonalLoanCompletedKey];
    [ud setBool:self.isCustomerLoanRequestConfirmed forKey:kDSCustomerLoanRequestConfirmedKey];
    [ud setBool:self.isLoanApplicationCompleted forKey:kDSLoanApplicationCompletedKey];
    [ud setBool:self.isLoanAgreementGenerated forKey:kDSLoanAgreementGeneratedKey];

    [ud synchronize];
}

- (void)loadPersistedBasicLoanFieldsFromUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    NSString *acct = [ud stringForKey:kDSLoanAccountKey];
    if (acct) self.loanAccountNumber = acct;

    NSString *amountStr = [ud stringForKey:kDSLoanAmountKey];
    if (amountStr) self.loanAmount = [NSDecimalNumber decimalNumberWithString:amountStr];

    NSString *emiStr = [ud stringForKey:kDSKey_emi];
    if (emiStr) {
        self.emi = [NSDecimalNumber decimalNumberWithString:emiStr];
    }
    
    NSString *loanEmiStr = [ud stringForKey:kDSKey_loanEMI];
    if (loanEmiStr) {
        self.loanEMI = [NSDecimalNumber decimalNumberWithString:loanEmiStr];
    }

    NSString *interestStr = [ud stringForKey:kDSLoanInterestKey];
    if (interestStr) {
        self.interestRateAnnual = [NSDecimalNumber decimalNumberWithString:interestStr];
        self.loanInterestRate = self.interestRateAnnual;
    }

    NSNumber *tenureNum = [ud objectForKey:kDSLoanTenureKey];
    if (tenureNum) self.loanTenureMonths = tenureNum.integerValue;

    NSString *bank = [ud stringForKey:kDSBankNameKey];
    if (bank) self.bankName = bank;

    NSString *status = [ud stringForKey:kDSAppStatusKey];
    if (status) self.applicationStatus = status;

    // Flags
    if ([ud objectForKey:kDSPersonalLoanCompletedKey] != nil) {
        self.isPersonalLoanApplicationCompleted = [ud boolForKey:kDSPersonalLoanCompletedKey];
    }
    if ([ud objectForKey:kDSCustomerLoanRequestConfirmedKey] != nil) {
        self.isCustomerLoanRequestConfirmed = [ud boolForKey:kDSCustomerLoanRequestConfirmedKey];
    }
    if ([ud objectForKey:kDSLoanApplicationCompletedKey] != nil) {
        self.isLoanApplicationCompleted = [ud boolForKey:kDSLoanApplicationCompletedKey];
    }
    if ([ud objectForKey:kDSLoanAgreementGeneratedKey] != nil) {
        self.isLoanAgreementGenerated = [ud boolForKey:kDSLoanAgreementGeneratedKey];
    }
    
    NSString *pfStr = [ud stringForKey:kDSKey_processingFee];
    if (pfStr) {
        self.processingFee = [NSDecimalNumber decimalNumberWithString:pfStr];
    }
}

#pragma mark - Clear

- (void)clearAll {
    // Identity
    self.mobileNumber = nil;
    self.aadharNumber = nil;
    self.panNumber = nil;
    self.email = nil;

    // Personal
    self.firstName = nil;
    self.middleName = nil;
    self.lastName = nil;
    self.dob = nil;
    self.age = nil;

    // Address
    self.addressLineOne = nil;
    self.addressLineTwo = nil;
    self.addressLineThree = nil;
    self.district = nil;
    self.city = nil;
    self.country = nil;
    self.pincode = nil;

    // Employment / documents
    self.companyName = nil;
    self.designation = nil;
    self.salarySlipFileName = nil;
    self.salarySlipFileURL = nil;
    self.offerLetterFileName = nil;
    self.offerLetterFileURL = nil;

    // Loan-related
    self.loanProductName = nil;
    self.loanAmount = nil;
    self.loanTenureMonths = 0;
    self.interestRateAnnual = nil;
    self.loanInterestRate = nil;
    self.emi = nil;
    self.loanEMI = nil;

    // Loan ids & status
    self.loanAccountNumber = nil;
    self.loanRequestNumber = nil;
    self.bankName = nil;
    self.applicationStatus = nil;

    // Flags
    self.isPersonalLoanApplicationCompleted = NO;
    self.isCustomerLoanRequestConfirmed = NO;
    self.isLoanApplicationCompleted = NO;
    self.isLoanAgreementGenerated = NO;

    // Also remove persisted basic fields (optional)
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:kDSLoanRequestNumberKey];
    [ud removeObjectForKey:kDSLastLoanSequenceKey];
    [ud removeObjectForKey:kDSLoanAccountKey];
    [ud removeObjectForKey:kDSLoanAmountKey];
    [ud removeObjectForKey:kDSLoanEMIKey];
    [ud removeObjectForKey:kDSLoanInterestKey];
    [ud removeObjectForKey:kDSLoanTenureKey];
    [ud removeObjectForKey:kDSBankNameKey];
    [ud removeObjectForKey:kDSAppStatusKey];
    [ud removeObjectForKey:kDSPersonalLoanCompletedKey];
    [ud removeObjectForKey:kDSCustomerLoanRequestConfirmedKey];
    [ud removeObjectForKey:kDSLoanApplicationCompletedKey];
    [ud removeObjectForKey:kDSLoanAgreementGeneratedKey];
    [ud removeObjectForKey:kDSKey_firstName];
    [ud removeObjectForKey:kDSKey_middleName];
    [ud removeObjectForKey:kDSKey_lastName];
    [ud removeObjectForKey:kDSKey_dob];
    [ud removeObjectForKey:kDSKey_age];
    [ud removeObjectForKey:kDSKey_mobileNumber];
    [ud removeObjectForKey:kDSKey_aadharNumber];
    [ud removeObjectForKey:kDSKey_panNumber];
    [ud removeObjectForKey:kDSKey_email];

    [ud removeObjectForKey:kDSKey_addressLineOne];
    [ud removeObjectForKey:kDSKey_addressLineTwo];
    [ud removeObjectForKey:kDSKey_addressLineThree];
    [ud removeObjectForKey:kDSKey_district];
    [ud removeObjectForKey:kDSKey_city];
    [ud removeObjectForKey:kDSKey_country];
    [ud removeObjectForKey:kDSKey_pincode];
    
    [ud removeObjectForKey:kDSKey_companyName];
    [ud removeObjectForKey:kDSKey_designation];
    [ud removeObjectForKey:kDSKey_salarySlipFileName];
    [ud removeObjectForKey:kDSKey_salarySlipFileURL];
    [ud removeObjectForKey:kDSKey_offerLetterFileName];
    [ud removeObjectForKey:kDSKey_offerLetterFileURL];
    [ud synchronize];
}



- (void)persistPersonalFieldsToUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    if (self.firstName != nil) [ud setObject:self.firstName forKey:kDSKey_firstName]; else [ud removeObjectForKey:kDSKey_firstName];
    if (self.middleName != nil) [ud setObject:self.middleName forKey:kDSKey_middleName]; else [ud removeObjectForKey:kDSKey_middleName];
    if (self.lastName != nil) [ud setObject:self.lastName forKey:kDSKey_lastName]; else [ud removeObjectForKey:kDSKey_lastName];
    if (self.dob != nil) [ud setObject:self.dob forKey:kDSKey_dob]; else [ud removeObjectForKey:kDSKey_dob];
    if (self.age != nil) [ud setObject:self.age forKey:kDSKey_age]; else [ud removeObjectForKey:kDSKey_age];
    if (self.mobileNumber != nil) [ud setObject:self.mobileNumber forKey:kDSKey_mobileNumber]; else [ud removeObjectForKey:kDSKey_mobileNumber];
    if (self.aadharNumber != nil) [ud setObject:self.aadharNumber forKey:kDSKey_aadharNumber]; else [ud removeObjectForKey:kDSKey_aadharNumber];
    if (self.panNumber != nil) [ud setObject:self.panNumber forKey:kDSKey_panNumber]; else [ud removeObjectForKey:kDSKey_panNumber];
    if (self.email != nil) [ud setObject:self.email forKey:kDSKey_email]; else [ud removeObjectForKey:kDSKey_email];

    [ud synchronize];
}

- (void)loadPersistedPersonalFieldsFromUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    NSString *val = nil;

    val = [ud stringForKey:kDSKey_firstName];
    if (val) self.firstName = val;

    val = [ud stringForKey:kDSKey_middleName];
    if (val) self.middleName = val;

    val = [ud stringForKey:kDSKey_lastName];
    if (val) self.lastName = val;

    val = [ud stringForKey:kDSKey_dob];
    if (val) self.dob = val;

    val = [ud stringForKey:kDSKey_age];
    if (val) self.age = val;

    val = [ud stringForKey:kDSKey_mobileNumber];
    if (val) self.mobileNumber = val;

    val = [ud stringForKey:kDSKey_aadharNumber];
    if (val) self.aadharNumber = val;

    val = [ud stringForKey:kDSKey_panNumber];
    if (val) self.panNumber = val;

    val = [ud stringForKey:kDSKey_email];
    if (val) self.email = val;
}

- (void)persistAddressFieldsToUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    if (self.addressLineOne != nil) [ud setObject:self.addressLineOne forKey:kDSKey_addressLineOne]; else [ud removeObjectForKey:kDSKey_addressLineOne];
    if (self.addressLineTwo != nil) [ud setObject:self.addressLineTwo forKey:kDSKey_addressLineTwo]; else [ud removeObjectForKey:kDSKey_addressLineTwo];
    if (self.addressLineThree != nil) [ud setObject:self.addressLineThree forKey:kDSKey_addressLineThree]; else [ud removeObjectForKey:kDSKey_addressLineThree];
    if (self.district != nil) [ud setObject:self.district forKey:kDSKey_district]; else [ud removeObjectForKey:kDSKey_district];
    if (self.city != nil) [ud setObject:self.city forKey:kDSKey_city]; else [ud removeObjectForKey:kDSKey_city];
    if (self.country != nil) [ud setObject:self.country forKey:kDSKey_country]; else [ud removeObjectForKey:kDSKey_country];
    if (self.pincode != nil) [ud setObject:self.pincode forKey:kDSKey_pincode]; else [ud removeObjectForKey:kDSKey_pincode];

    [ud synchronize];
}

- (void)loadPersistedAddressFieldsFromUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    NSString *val = nil;
    val = [ud stringForKey:kDSKey_addressLineOne];
    if (val) self.addressLineOne = val;

    val = [ud stringForKey:kDSKey_addressLineTwo];
    if (val) self.addressLineTwo = val;

    val = [ud stringForKey:kDSKey_addressLineThree];
    if (val) self.addressLineThree = val;

    val = [ud stringForKey:kDSKey_district];
    if (val) self.district = val;

    val = [ud stringForKey:kDSKey_city];
    if (val) self.city = val;

    val = [ud stringForKey:kDSKey_country];
    if (val) self.country = val;

    val = [ud stringForKey:kDSKey_pincode];
    if (val) self.pincode = val;
}


- (void)persistEmploymentFieldsToUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    if (self.companyName != nil) [ud setObject:self.companyName forKey:kDSKey_companyName]; else [ud removeObjectForKey:kDSKey_companyName];
    if (self.designation != nil) [ud setObject:self.designation forKey:kDSKey_designation]; else [ud removeObjectForKey:kDSKey_designation];
    if (self.salarySlipFileName != nil) [ud setObject:self.salarySlipFileName forKey:kDSKey_salarySlipFileName]; else [ud removeObjectForKey:kDSKey_salarySlipFileName];
    if (self.salarySlipFileURL != nil) [ud setObject:self.salarySlipFileURL forKey:kDSKey_salarySlipFileURL]; else [ud removeObjectForKey:kDSKey_salarySlipFileURL];
    if (self.offerLetterFileName != nil) [ud setObject:self.offerLetterFileName forKey:kDSKey_offerLetterFileName]; else [ud removeObjectForKey:kDSKey_offerLetterFileName];
    if (self.offerLetterFileURL != nil) [ud setObject:self.offerLetterFileURL forKey:kDSKey_offerLetterFileURL]; else [ud removeObjectForKey:kDSKey_offerLetterFileURL];

    [ud synchronize];
}

- (void)loadPersistedEmploymentFieldsFromUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *val = nil;

    val = [ud stringForKey:kDSKey_companyName];
    if (val) self.companyName = val;

    val = [ud stringForKey:kDSKey_designation];
    if (val) self.designation = val;

    val = [ud stringForKey:kDSKey_salarySlipFileName];
    if (val) self.salarySlipFileName = val;

    val = [ud stringForKey:kDSKey_salarySlipFileURL];
    if (val) self.salarySlipFileURL = val;

    val = [ud stringForKey:kDSKey_offerLetterFileName];
    if (val) self.offerLetterFileName = val;

    val = [ud stringForKey:kDSKey_offerLetterFileURL];
    if (val) self.offerLetterFileURL = val;
}

@end
