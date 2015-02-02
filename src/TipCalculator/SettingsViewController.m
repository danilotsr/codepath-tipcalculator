//
//  SettingsViewController.m
//  TipCalculator
//
//  Created by Danilo Resende on 1/31/15.
//  Copyright (c) 2015 danilotsr. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsConstants.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *roundValuesToggle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *defaultTipControl;
@property (weak, nonatomic) IBOutlet UIPickerView *currencyPicker;
@property (nonatomic) NSArray* currencyCodes;

- (IBAction)onChange:(id)sender;
- (void)updateSettings;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currencyPicker.delegate = self;
    self.currencyPicker.dataSource = self;
    self.currencyPicker.showsSelectionIndicator = YES;
    [self updateSettings];
}

- (NSArray*) currencyCodes {
    if (!_currencyCodes) {
        _currencyCodes = @[@"AUD", @"BRL", @"EUR", @"GBP", @"JPY", @"MXN", @"USD"];
    }
    return _currencyCodes;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.currencyCodes count];
}

- (NSString*) pickerView:(UIPickerView *)pickerView
              titleForRow:(NSInteger)row
              forComponent:(NSInteger)component {
    NSLocale *userLocale = [NSLocale autoupdatingCurrentLocale];
    
    // Re-initialize NSLocale* based on localeIdentifier as displayNameForKey:value yields nil otherwise.
    userLocale = [NSLocale localeWithLocaleIdentifier:userLocale.localeIdentifier];
    
    return [userLocale displayNameForKey:NSLocaleCurrencyCode
                                   value:self.currencyCodes[row]];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    [self onChange:pickerView];
}

- (IBAction)onChange:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.roundValuesToggle.isOn forKey:kUseRoundValues];
    [defaults setInteger:self.defaultTipControl.selectedSegmentIndex forKey:kDefaultTipAmountIndex];
    NSInteger currencyCodeIndex = [self.currencyPicker selectedRowInComponent:0];
    [defaults setObject:self.currencyCodes[currencyCodeIndex] forKey:kCurrencyCode];
    [defaults synchronize];
    [self updateSettings];
}

- (void)updateSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.roundValuesToggle.on = [defaults boolForKey:kUseRoundValues];
    self.defaultTipControl.selectedSegmentIndex = [defaults integerForKey:kDefaultTipAmountIndex];
    NSString* currencyCode = [defaults objectForKey:kCurrencyCode];
    if (!currencyCode) {
        currencyCode = kDefaultCurrencyCode;
    }
    [self.currencyPicker selectRow:[self.currencyCodes indexOfObject:currencyCode]
                       inComponent:0
                          animated:NO];
}
@end
