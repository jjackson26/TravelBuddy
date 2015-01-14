//
//  MMListenerConfigController.m
//  MindMeldVoice
//
//  Created by J.J. Jackson on 09/09/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "MMListenerConfigController.h"

@interface MMListenerConfigController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, strong) UIPickerView *languagePickerView;

@property (nonatomic, assign) NSInteger selectedLanguageIndex;
@property (nonatomic, assign) NSInteger selectedDialectIndex;

@end

@implementation MMListenerConfigController


#pragma mark - lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createLanguageDataModel];
    }
    return self;
}

- (void)createLanguageDataModel
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"languages" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error = nil;
    NSArray *rawLanguages = [NSJSONSerialization JSONObjectWithData:data
                                                            options:0
                                                              error:&error];

    NSMutableArray *languages = [NSMutableArray arrayWithCapacity:rawLanguages.count];
    for (NSArray *rawLanguage in rawLanguages) {
        NSMutableArray *dialects = [NSMutableArray array];
        for (NSInteger dialectIndex = 1; dialectIndex < rawLanguage.count; dialectIndex++) {
            NSArray *rawDialect = rawLanguage[dialectIndex];
            NSString *dialectLabel = rawDialect.count > 1 ? rawDialect.lastObject : @"";
            [dialects addObject:@{ @"label": dialectLabel ,
                                   @"code": rawDialect.firstObject }];
        }

        [languages addObject:@{ @"label": rawLanguage.firstObject,
                                @"dialects": [NSArray arrayWithArray:dialects] }];
    }

    self.languages = [NSArray arrayWithArray:languages];
}


#pragma mark - view lifecycle

- (void)viewDidLoad {
    if (self.listener) {
        [self displayListenerConfig:self.listener];
    }

    self.languageTextField.textAlignment = NSTextAlignmentRight;
    self.languageTextField.inputView = self.languagePickerView;

    [self createTextFieldInputAccessoryView];
    [super viewDidLoad];
}


#pragma mark - properties

- (void)displayListenerConfig:(MMListener *)listener
{
    [self.continuousToggle setOn:listener.continuous
                        animated:YES];
    [self.interimToggle setOn:listener.interimResults
                     animated:YES];

    NSString *language = listener.language ? listener.language : @"en-US";
    NSIndexPath *languageIndexPath = [self pickerComponentsForLanguageCode:language];
    self.selectedLanguageIndex = languageIndexPath.section;
    self.selectedDialectIndex = languageIndexPath.item;
    self.languageTextField.text = [self languageStringForIndexPath:languageIndexPath];
}

- (void)setListener:(MMListener *)listener {
    _listener = listener;
    [self displayListenerConfig:listener];
}

- (NSString *)languageStringForIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedLanguage = self.languages[indexPath.section];

    NSString *languageString = selectedLanguage[@"label"];
    if ([selectedLanguage[@"dialects"] count] > 1) {
        languageString = [languageString stringByAppendingFormat:@", %@",
                          selectedLanguage[@"dialects"][indexPath.item][@"label"]];
    }

    return languageString;
}

- (NSString *)languageCodeForIndexPath:(NSIndexPath *)indexPath
{
    return self.languages[indexPath.section][@"dialects"][indexPath.item][@"code"];
}

- (NSIndexPath *)pickerComponentsForLanguageCode:(NSString *)languageCode
{
    for (NSInteger languageIndex = 0; languageIndex < self.languages.count; languageIndex++) {
        NSDictionary *language = self.languages[languageIndex];
        for (NSInteger dialectIndex = 0; dialectIndex < [language[@"dialects"] count]; dialectIndex++) {
            NSDictionary *dialect = language[@"dialects"][dialectIndex];
            if ([dialect[@"code"] isEqualToString:languageCode]) {
                return [NSIndexPath indexPathForRow:dialectIndex
                                          inSection:languageIndex];
            }
        }
    }
    return nil;
}

- (UIPickerView *)languagePickerView
{
    if (!_languagePickerView) {
        _languagePickerView = [[UIPickerView alloc] init];
        _languagePickerView.dataSource = self;
        _languagePickerView.delegate = self;
        _languagePickerView.showsSelectionIndicator = YES;
    }

    return _languagePickerView;
}


#pragma mark - IBActions

- (void)toggleValueChanged:(UISwitch *)toggle {
    if (toggle == self.continuousToggle) {
        self.listener.continuous = self.continuousToggle.isOn;
    } else if (toggle == self.interimToggle) {
        self.listener.interimResults = self.interimToggle.isOn;
    }
}


#pragma mark - UITableViewDelegate

static const NSInteger kTableSectionListener = 0;
static const NSInteger kTableSectionListenerRowContinuous = 0;
static const NSInteger kTableSectionListenerRowInterim = 1;
static const NSInteger kTableSectionListenerRowLanguage = 2;

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kTableSectionListener) {
    if (indexPath.row == kTableSectionListenerRowLanguage) {
        [self.languageTextField becomeFirstResponder];
    } else {
        UISwitch *toggle;
        if (indexPath.row == kTableSectionListenerRowContinuous) {
            toggle = self.continuousToggle;
        } else if (indexPath.row == kTableSectionListenerRowInterim) {
            toggle = self.interimToggle;
        }

        [toggle setOn:toggle.isOn
             animated:YES];
    }
    }
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.languagePickerView selectRow:self.selectedLanguageIndex
                           inComponent:kPickerComponentLanguage
                              animated:NO];
    [self.languagePickerView selectRow:self.selectedDialectIndex
                           inComponent:kPickerComponentDialect
                              animated:NO];
    return YES;
}


#pragma mark - UIPickerViewDataSource

static const NSInteger kPickerComponentLanguage = 0;
static const NSInteger kPickerComponentDialect = 1;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (component == kPickerComponentLanguage) {
        return self.languages.count;
    } else {
        return [self.languages[self.selectedLanguageIndex][@"dialects"] count];
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (component == kPickerComponentLanguage) {
        return self.languages[row][@"label"];
    } else {
        return self.languages[self.selectedLanguageIndex][@"dialects"][row][@"label"];
    }
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    if (component == kPickerComponentLanguage) {
        self.selectedLanguageIndex = row;
        [pickerView reloadComponent:kPickerComponentDialect];
        self.selectedDialectIndex = 0;
    } else {
        self.selectedDialectIndex = row;
    }

    NSIndexPath *languageIndexPath = [NSIndexPath indexPathForItem:self.selectedDialectIndex
                                                         inSection:self.selectedLanguageIndex];
    self.languageTextField.text = [self languageStringForIndexPath:languageIndexPath];
    self.listener.language = [self languageCodeForIndexPath:languageIndexPath];
}

- (void)donePickingLanguage
{
    [self.languageTextField resignFirstResponder];
}

- (void)createTextFieldInputAccessoryView
{
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(donePickingLanguage)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barTintColor = toolbar.backgroundColor = [UIColor whiteColor];
    toolbar.items = @[ spacer, barButton ];
    self.languageTextField.inputAccessoryView = toolbar;
}


@end