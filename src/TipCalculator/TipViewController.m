//
//  TipViewController.m
//  TipCalculator
//
//  Created by Danilo Resende on 1/31/15.
//  Copyright (c) 2015 danilotsr. All rights reserved.
//

#import "TipViewController.h"
#import "SettingsViewController.h"
#import "SettingsConstants.h"

@interface TipViewController ()

@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;
@property BOOL useRoundValues;
@property NSLocale* currentLocale;

- (IBAction)onTap:(id)sender;
- (void)onSettingsButton;
- (NSString*) sanitizeInputAmount:(NSString*)input;
- (float)calculateTipAmountForBill:(float)billAmount;
- (void)updateValues;
- (void)updateValuesForBillAmount:(float)billAmount;
- (void)updateSettings;
- (void)initBillAmount;
- (NSLocale*)getLocaleFromCurrencyCode:(NSString*)currencyCode;
- (void)saveBillAmount:(float)billAmount;
@end

@implementation TipViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Tip Calculator";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(onSettingsButton)];
    [self initBillAmount];
    [self.billTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSettings];
    [self updateValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onTap:(id)sender {
    [self updateValues];
}

- (void)onSettingsButton {
    [self.navigationController pushViewController:[[SettingsViewController alloc] init] animated:YES];
}

- (NSString*) sanitizeInputAmount:(NSString*)input {
    NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < [input length]; i++) {
        unichar current = [input characterAtIndex:i];
        if ([numbersOnly characterIsMember:current]) {
            [result appendString:[NSString stringWithCharacters:&current length:1]];
        }
    }
    return result;
}

- (float)billAmount {
    NSString *billAmountText = [self sanitizeInputAmount:self.billTextField.text];
    return [billAmountText floatValue] / 100;
}

- (float)calculateTipAmountForBill:(float)billAmount {
    NSArray *tipValues = @[@0.15, @0.18, @0.2];
    float tipAmount = billAmount * [tipValues[self.tipControl.selectedSegmentIndex] floatValue];
    if (self.useRoundValues) {
        float roundTotal = [[NSNumber numberWithFloat:tipAmount + billAmount + kRoundFactor] intValue];
        tipAmount = MAX(roundTotal - billAmount, 0);
    }
    return tipAmount;
}

- (NSLocale*)getLocaleFromCurrencyCode:(NSString*)currencyCode {
    if (currencyCode == nil) {
        return nil;
    }
    NSString* localeIdentifier = [NSLocale localeIdentifierFromComponents:@{NSLocaleCurrencyCode:currencyCode}];
    return [NSLocale localeWithLocaleIdentifier:localeIdentifier];
}

- (void)updateValues {
    [self updateValuesForBillAmount:[self billAmount]];
}

- (void)updateValuesForBillAmount:(float)billAmount {
    float tipAmount = [self calculateTipAmountForBill:billAmount];
    float totalAmount = billAmount + tipAmount;

    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:self.currentLocale];
    
    self.billTextField.text = [currencyFormatter stringFromNumber:@(billAmount)];
    self.tipLabel.text = [currencyFormatter stringFromNumber:@(tipAmount)];
    self.totalLabel.text = [currencyFormatter stringFromNumber:@(totalAmount)];
    
    [self saveBillAmount:billAmount];
}

- (void)updateSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.tipControl.selectedSegmentIndex = [defaults integerForKey:kDefaultTipAmountIndex];
    self.useRoundValues = [defaults boolForKey:kUseRoundValues];
    NSString* currencyCode = [defaults objectForKey:kCurrencyCode];
    if (currencyCode == nil) {
        currencyCode = kDefaultCurrencyCode;
    }
    self.currentLocale = [self getLocaleFromCurrencyCode:currencyCode];
}

- (void)initBillAmount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastTimeUsed = [NSDate dateWithTimeIntervalSince1970:[defaults doubleForKey:kLastUseTimestamp]];
    NSDate *cutoffDate = [NSDate dateWithTimeInterval:kRememberBillTimeInSeconds sinceDate:lastTimeUsed];
    NSDate *now = [NSDate date];
    if ([now compare:cutoffDate] < 0) {
        [self updateValuesForBillAmount:[defaults doubleForKey:kLastBillAmount]];
    }
}

- (void)saveBillAmount:(float)billAmount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:billAmount forKey:kLastBillAmount];
    NSDate *now = [NSDate date];
    [defaults setDouble:now.timeIntervalSince1970 forKey:kLastUseTimestamp];
}
@end