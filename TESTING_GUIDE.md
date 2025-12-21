# How to Test the Fix

## Quick Summary

**Problem:** Loan values were being saved with duplicate keys, causing old/incorrect data to be retrieved instead of newly saved data.

**Solution:** 
1. Removed duplicate EMI persistence logic
2. Added property synchronization for synonym properties (emi/loanEMI, interestRateAnnual/loanInterestRate)

## Testing Steps

### Step 1: Clean UserDefaults (Important!)

Before testing, clear any stale data from previous runs:

```objective-c
// Add this code in your app delegate or initial view controller
NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

// Clear old keys (if any)
[ud removeObjectForKey:@"DS_LoanAmount"];
[ud removeObjectForKey:@"DS_LoanEMI"];
[ud removeObjectForKey:@"DS_LoanInterest"];
[ud removeObjectForKey:@"DS_LoanTenure"];

// Clear new keys
[ud removeObjectForKey:@"DataStore.emi"];
[ud removeObjectForKey:@"DataStore.loanEMI"];

[ud synchronize];

NSLog(@"UserDefaults cleared for testing");
```

### Step 2: Test Save Operation

In your loan generator or application screen:

```objective-c
DataStore *store = [DataStore sharedInstance];

// Set loan values (example from problem statement)
store.loanAmount = [NSDecimalNumber decimalNumberWithString:@"451000"];
store.loanTenureMonths = 24;
store.interestRateAnnual = [NSDecimalNumber decimalNumberWithString:@"7.78"];
store.emi = [NSDecimalNumber decimalNumberWithString:@"20352.37"];

NSLog(@"Saved Loan values to DataStore: amount=%@ tenure=%ld interest=%@ emi=%@",
      store.loanAmount, (long)store.loanTenureMonths, 
      store.interestRateAnnual, store.emi);

// Persist to UserDefaults
[store persistBasicLoanFieldsToUserDefaults];

NSLog(@"Values persisted to UserDefaults");
```

### Step 3: Test Load Operation

When navigating to "My Loans" or the loan application screen:

```objective-c
DataStore *store = [DataStore sharedInstance];

// This should happen automatically in sharedInstance, but you can manually test:
[store loadPersistedBasicLoanFieldsFromUserDefaults];

NSLog(@"[LoanApplication] populating UI from DataStore: amount=%@ tenure=%ld interest=%@ emi=%@",
      store.loanAmount, (long)store.loanTenureMonths, 
      store.interestRateAnnual ?: store.loanInterestRate, 
      store.loanEMI ?: store.emi);

// Verify values match what was saved
NSAssert([store.loanAmount isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"451000"]], 
         @"Loan amount should be 451000");
NSAssert(store.loanTenureMonths == 24, 
         @"Tenure should be 24");
NSAssert([store.interestRateAnnual isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"7.78"]], 
         @"Interest should be 7.78");
NSAssert([store.emi isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"20352.37"]], 
         @"EMI should be 20352.37");
```

### Step 4: Test Synonym Synchronization

Test that synonym properties stay synchronized:

```objective-c
DataStore *store = [DataStore sharedInstance];

// Set emi - loanEMI should automatically update
store.emi = [NSDecimalNumber decimalNumberWithString:@"20352.37"];
NSLog(@"Set emi=%@, loanEMI=%@", store.emi, store.loanEMI);
NSAssert([store.emi isEqualToNumber:store.loanEMI], @"emi and loanEMI should match");

// Set loanEMI - emi should automatically update
store.loanEMI = [NSDecimalNumber decimalNumberWithString:@"25000"];
NSLog(@"Set loanEMI=%@, emi=%@", store.loanEMI, store.emi);
NSAssert([store.emi isEqualToNumber:store.loanEMI], @"emi and loanEMI should match");

// Same for interest rate
store.interestRateAnnual = [NSDecimalNumber decimalNumberWithString:@"7.78"];
NSLog(@"Set interestRateAnnual=%@, loanInterestRate=%@", 
      store.interestRateAnnual, store.loanInterestRate);
NSAssert([store.interestRateAnnual isEqualToNumber:store.loanInterestRate], 
         @"interestRateAnnual and loanInterestRate should match");
```

## Expected Results

### Before Fix ❌

```
Saved Loan values to DataStore: amount=451000 tenure=24 interest=7.78 emi=20352.37
[LoanApplication] populating UI from DataStore: amount=999762.57 tenure=60 interest=10 emi=21242
```

The loaded values are completely different from saved values!

### After Fix ✅

```
Saved Loan values to DataStore: amount=451000 tenure=24 interest=7.78 emi=20352.37
[LoanApplication] populating UI from DataStore: amount=451000 tenure=24 interest=7.78 emi=20352.37
```

The loaded values match the saved values exactly!

## Troubleshooting

### If values still don't match:

1. **Check for multiple DataStore instances**: Make sure you're always using `[DataStore sharedInstance]` and never `[[DataStore alloc] init]`

2. **Verify UserDefaults is cleared**: Old data might still be present
   ```objective-c
   NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
   NSDictionary *dict = [ud dictionaryRepresentation];
   for (NSString *key in dict.allKeys) {
       if ([key hasPrefix:@"DS_"] || [key hasPrefix:@"DataStore."]) {
           NSLog(@"UserDefaults key: %@ = %@", key, dict[key]);
       }
   }
   ```

3. **Check app reinstallation**: If testing on a device/simulator, try deleting the app and reinstalling to completely clear UserDefaults

4. **Verify property usage**: Make sure you're using the DataStore properties consistently (either use `emi` everywhere or `loanEMI` everywhere, but not mixing them randomly)

## Integration Checklist

- [ ] Copy the updated `DataStore.m` to your project
- [ ] Clean and rebuild your project
- [ ] Clear UserDefaults before testing (see Step 1)
- [ ] Test save operation (see Step 2)
- [ ] Test load operation (see Step 3)
- [ ] Test synonym synchronization (see Step 4)
- [ ] Verify UI displays correct values
- [ ] Test on fresh app install (no existing data)
- [ ] Test with existing data (upgrade scenario)

## Questions?

If you still see incorrect values after following these steps, check:
1. Are you using the latest DataStore.m with the custom setters?
2. Did you clear UserDefaults before testing?
3. Are you calling `persistBasicLoanFieldsToUserDefaults` after setting values?
4. Are you always using `[DataStore sharedInstance]`?
