//
//  DataStore.h
//  LoanOriginationSystem
//
//  Created by Wuppuluri Naveen Kumar on 21/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataStore : NSObject

+ (instancetype)sharedInstance;

/// Identity / contact
@property (nonatomic, copy, nullable) NSString *mobileNumber;
@property (nonatomic, copy, nullable) NSString *aadharNumber;
@property (nonatomic, copy, nullable) NSString *panNumber;
@property (nonatomic, copy, nullable) NSString *email;

/// Customer personal details
@property (nonatomic, copy, nullable) NSString *firstName;
@property (nonatomic, copy, nullable) NSString *middleName;
@property (nonatomic, copy, nullable) NSString *lastName;
@property (nonatomic, copy, nullable) NSString *dob;
@property (nonatomic, copy, nullable) NSString *age;

/// Computed name helpers (read-only)
@property (nonatomic, readonly, copy) NSString *combinedFirstMiddleName; // "First Middle" or "First" or "Middle"
@property (nonatomic, readonly, copy) NSString *fullName;


/// Address fields
@property (nonatomic, copy, nullable) NSString *addressLineOne;
@property (nonatomic, copy, nullable) NSString *addressLineTwo;
@property (nonatomic, copy, nullable) NSString *addressLineThree;
@property (nonatomic, copy, nullable) NSString *district;
@property (nonatomic, copy, nullable) NSString *city;
@property (nonatomic, copy, nullable) NSString *country;
@property (nonatomic, copy, nullable) NSString *pincode;

/// Employment / documents
@property (nonatomic, copy, nullable) NSString *companyName;
@property (nonatomic, copy, nullable) NSString *designation;
@property (nonatomic, copy, nullable) NSString *salarySlipFileName;
@property (nonatomic, copy, nullable) NSString *salarySlipFileURL;
@property (nonatomic, copy, nullable) NSString *offerLetterFileName;
@property (nonatomic, copy, nullable) NSString *offerLetterFileURL;

/// Loan / requirement fields
@property (nonatomic, copy, nullable) NSString *loanProductName;
@property (nonatomic, strong, nullable) NSDecimalNumber *loanAmount;        // principal
@property (nonatomic, assign) NSInteger loanTenureMonths;                  // months

// Interest rate: provide two property names so callers using either compile
@property (nonatomic, strong, nullable) NSDecimalNumber *interestRateAnnual; // e.g. 8.15 (annual %)
@property (nonatomic, strong, nullable) NSDecimalNumber *loanInterestRate;   // synonym (some files use this name)

// EMI: provide both names used across code
@property (nonatomic, strong, nullable) NSDecimalNumber *emi;      // monthly EMI (used in LoanGeneratorViewController)
@property (nonatomic, strong, nullable) NSDecimalNumber *loanEMI;  // synonym (if other files use loanEMI)

// Processing fee (added property)
@property (nonatomic, strong, nullable) NSDecimalNumber *processingFee; // e.g. ₹3500.00

/// Loan identifiers & status
@property (nonatomic, copy, nullable) NSString *loanAccountNumber;
@property (nonatomic, copy, nullable) NSString *loanRequestNumber;
@property (nonatomic, copy, nullable) NSString *bankName;
@property (nonatomic, copy, nullable) NSString *applicationStatus; // e.g. "IN PROGRESS", "ACCEPTED", "DECLINED"

/// Flags
@property (nonatomic, assign) BOOL isPersonalLoanApplicationCompleted;
@property (nonatomic, assign) BOOL isCustomerLoanRequestConfirmed;
@property (nonatomic, assign) BOOL isLoanApplicationCompleted;
@property (nonatomic, assign) BOOL isLoanAgreementGenerated;

/// Persistence helpers
- (void)persistBasicLoanFieldsToUserDefaults;
- (void)loadPersistedBasicLoanFieldsFromUserDefaults;

/// Generate a new Loan Request Number, save it to DataStore.loanRequestNumber and persist sequence.
/// Returns the generated request number string (e.g. "101010001").
- (NSString *)generateAndSaveLoanRequestNumber;

/// Reset everything in-memory and persisted basic fields
- (void)clearAll;


// add these method declarations to the DataStore interface

/// Persist personal fields (name, dob, age, identity numbers, mobile) to user defaults
- (void)persistPersonalFieldsToUserDefaults;

/// Load previously persisted personal fields from user defaults into the DataStore properties
- (void)loadPersistedPersonalFieldsFromUserDefaults;

// Add these method declarations in the @interface section

/// Persist address-related fields (addressLineOne, addressLineTwo, addressLineThree, district, city, country, pincode)
- (void)persistAddressFieldsToUserDefaults;

/// Load previously persisted address fields from user defaults into the DataStore properties
- (void)loadPersistedAddressFieldsFromUserDefaults;

// Add these declarations to DataStore.h (inside @interface)
/// Persist employment/document fields (companyName, designation, salarySlipFileName/URL, offerLetterFileName/URL)
- (void)persistEmploymentFieldsToUserDefaults;

/// Load previously persisted employment/document fields from user defaults into the DataStore properties
- (void)loadPersistedEmploymentFieldsFromUserDefaults;


@end

NS_ASSUME_NONNULL_END
