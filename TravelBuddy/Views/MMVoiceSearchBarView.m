//
//  MMVoiceSearchView.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "MMVoiceSearchBarView.h"

// utilities
#import "UIView+AutoLayout.h"
#import "UIColor+MindMeldStarterApp.h"

static const CGFloat kSearchBarHeight = 60.0;

static const CGFloat kSearchVerticalMargin = 8.0;
static const CGFloat kLeftMargin = 12.0;
static const CGFloat kMicrophoneMargin = 3.0;

static const NSTimeInterval kBrandingAnimationDuration = 0.5;
static const CGFloat kFontSize = 16.0;


@interface MMVoiceSearchBarView () <UITextFieldDelegate>

// default colors
+ (UIColor *)defaultBackgroundColor;
+ (UIColor *)defaultBorderColor;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *brandingImageView;

@property (nonatomic, strong) UIColor *privateBackgroundColor;

@property (nonatomic, assign, readwrite) BOOL editing;

@property (nonatomic, strong) MMListener *listener;

@property (nonatomic, copy) void (^onTextFieldDidEndEditing)();

@end

@implementation MMVoiceSearchBarView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSearchView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeSearchView];
    }
    return self;
}

- (void)initializeSearchView
{
    [self setDefaultAppearanceProperties];

    [self addObservers];
    [self createSubviews];
    [self createListener];
    [self connectActions];
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)setDefaultAppearanceProperties
{
    _privateBackgroundColor = [MMVoiceSearchBarView defaultBackgroundColor];
    _borderColor = [MMVoiceSearchBarView defaultBorderColor];
}

- (void)createSubviews
{
    super.backgroundColor = [UIColor clearColor];
//    self.layer.cornerRadius = kSearchBarHeight / 2.0;
    self.layer.masksToBounds = NO;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.contentsScale = [UIScreen mainScreen].scale;

    self.backgroundView = [UIView autoLayoutView];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView.layer.backgroundColor = self.backgroundColor.CGColor;
//    self.backgroundView.layer.cornerRadius = kSearchBarHeight / 2.0;
    self.backgroundView.layer.masksToBounds = NO;
    self.backgroundView.layer.borderWidth = 2.0;
    self.backgroundView.layer.borderColor = self.borderColor.CGColor;
    [self addSubview:self.backgroundView];

    self.brandingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branding"]];
    self.brandingImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.brandingImageView];

    self.label = [UILabel autoLayoutView];
    self.label.lineBreakMode = NSLineBreakByTruncatingHead;
    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont systemFontOfSize:kFontSize];
    [self addSubview:self.label];

    self.textField = [UITextField autoLayoutView];
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.delegate = self;

    self.attributedPlaceholder = [self attributedPlaceholderString:@"Search"];

    self.textField.textColor = [UIColor whiteColor];
    self.textField.font = [UIFont systemFontOfSize:kFontSize];
    [self addSubview:self.textField];

    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchButton setImage:[UIImage imageNamed:@"search"]
                       forState:UIControlStateNormal];
    self.searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.searchButton];

    self.microphoneButton = [[MMMicrophoneButton alloc] initWithFrame:CGRectZero];
    [self addSubview:self.microphoneButton];
    self.microphoneButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self createConstraints];
}

- (void)createConstraints
{
    [self.backgroundView addConstraintsToFillSuperview];

    NSDictionary *metrics = @{ @"leftMargin": @(kLeftMargin),
                               @"micMargin": @(kMicrophoneMargin),
                               @"searchMargin": @(kSearchVerticalMargin) };

    UIImageView *brandImage = self.brandingImageView;
    UITextField *textField = self.textField;
    UIButton *searchButton = self.searchButton;
    MMMicrophoneButton *microphoneButton = self.microphoneButton;
    UILabel *label = self.label;
    NSDictionary *views = NSDictionaryOfVariableBindings(textField, searchButton, microphoneButton, label, brandImage);

    NSArray *visualFormats = @[ @"H:|-(leftMargin)-[searchButton]-[textField]-[microphoneButton]-(micMargin)-|",
                                @"H:[searchButton]-[label]-[microphoneButton]",
                                @"H:[brandImage]-[microphoneButton]",
                                @"V:|[textField]|",
                                @"V:|[label]|",
                                @"V:|-(searchMargin)-[searchButton]-(searchMargin)-|",
                                @"V:|-(micMargin)-[microphoneButton]-(micMargin)-|"];

    NSArray *aspectRatioViews = @[ searchButton, microphoneButton ];
    for (UIView *view in aspectRatioViews) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:view
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1
                                                                       constant:0];
        [view addConstraint:constraint];
    }

    [UIView addConstraintsForVisualFormats:visualFormats
                                     views:views
                                   metrics:metrics];

    [self.brandingImageView addConstraintToCenterVerticallyInSuperview];
}

#pragma mark - Observers

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (void)keyboardDidHide
{
    if (self.editing) {
        [self resignFirstResponder];
    }
}

#pragma mark - Listener

- (void)createListener
{
    self.listener = [MMListener listener];
    self.listener.interimResults = YES;

    typeof(self) __weak weakSelf = self;
    self.listener.onBeganRecording = ^(MMListener *listener) {
        NSLog(@"listener began recording:");
        weakSelf.microphoneButton.microphoneState = MMMicrophoneButtonStateRecording;

        weakSelf.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Speak Now"
                                                                                   attributes:weakSelf.placeholderAttributes];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.listener.listening &&
                weakSelf.text.length == 0) {
                weakSelf.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Listening..."
                                                                                           attributes:weakSelf.placeholderAttributes];
            }
        });

        if (weakSelf.onListenerBeganRecording) {
            weakSelf.onListenerBeganRecording(listener);
        }
    };

    self.listener.onFinishedRecording = ^(MMListener *listener) {
        NSLog(@"listener finished recording:");
        weakSelf.microphoneButton.microphoneState = MMMicrophoneButtonStateProcessing;

        if (weakSelf.onListenerFinishedRecording) {
            weakSelf.onListenerFinishedRecording(listener);
        }
    };

    self.listener.onFinished = ^(MMListener *listener) {
        NSLog(@"listener finished:");
        weakSelf.microphoneButton.microphoneState = MMMicrophoneButtonStateIdle;
        if (!weakSelf.text.length) {
            weakSelf.textField.attributedPlaceholder = weakSelf.attributedPlaceholder;
        }

        if (weakSelf.onListenerFinished) {
            weakSelf.onListenerFinished(listener);
        }
    };

    self.listener.onVolumeChanged = ^(MMListener *listener, Float32 avgVolumeLevel, Float32 peakVolumeLevel) {
        weakSelf.microphoneButton.volumeLevel = avgVolumeLevel;

        if (weakSelf.onListenerVolumeChanged) {
            weakSelf.onListenerVolumeChanged(listener, avgVolumeLevel, peakVolumeLevel);
        }
    };

    self.listener.onResult = ^(MMListener *listener, MMListenerResult *newResult) {
        if (newResult.transcript.length) {
            // use different text colors to indicate interim and final results
            NSDictionary *finalStringAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
            NSDictionary *interimStringAttributes = @{ NSForegroundColorAttributeName: [UIColor lightGrayColor] };
            NSMutableAttributedString *text = [NSMutableAttributedString new];
            for (MMListenerResult *result in listener.results) {
                NSDictionary *textAttributes = result.final ? finalStringAttributes : interimStringAttributes;
                NSAttributedString *textSegment = [[NSAttributedString alloc] initWithString:result.transcript
                                                                                  attributes:textAttributes];
                [text appendAttributedString:textSegment];
            }

            weakSelf.attributedText = text;
        }

        if (weakSelf.onListenerResult) {
            weakSelf.onListenerResult(listener, newResult);
        }
    };

    // Here we handle any errors that may be ocurring
    self.listener.onError = ^(MMListener *listener, NSError *error) {
        NSLog(@"listener error: %@", error);
        weakSelf.microphoneButton.microphoneState = MMMicrophoneButtonStateIdle;

        if (weakSelf.onListenerError) {
            weakSelf.onListenerError(listener, error);
        }
    };
}

- (void)startListening
{
    [self resignFirstResponder];
    self.attributedText = nil;
    self.microphoneButton.microphoneState = MMMicrophoneButtonStatePending;
    [self.listener startListening];
    if (self.onListenerStarted) {
        self.onListenerStarted(self.listener);
    }
}

- (void)stopListening
{
    [self.listener stopListening];
}


#pragma mark - Branding image

- (void)updateBranding
{
    CGFloat alpha = self.text.length == 0 ? 1.0 : 0.0;
    [self animateBrandingToAlpha:alpha];
}

- (void)animateBrandingToAlpha:(CGFloat)alpha
{
    if (self.brandingImageView.alpha != alpha) {
        [UIView animateWithDuration:kBrandingAnimationDuration
                         animations:^{ self.brandingImageView.alpha = alpha; }];
    }
}


#pragma mark - Actions

- (void)connectActions
{
    [self.textField addTarget:self
                       action:@selector(textFieldEditingChanged)
             forControlEvents:UIControlEventEditingChanged];
    [self.searchButton addTarget:self
                          action:@selector(searchTapped)
                forControlEvents:UIControlEventTouchUpInside];
    [self.microphoneButton addTarget:self
                              action:@selector(microphoneTapped)
                    forControlEvents:UIControlEventTouchUpInside];
}

- (void)textFieldEditingChanged
{
    _text = self.textField.text;
    _attributedText = self.textField.attributedText;
    [self updateBranding];
}

- (void)searchTapped
{
    if (self.listener.listening) {
        return;
    }

    if (self.isFirstResponder) {
        [self resignFirstResponder];
        [self submitText];
    } else {
        [self becomeFirstResponder];
    }
}

- (void)microphoneTapped
{
    if (self.listener.listening) {
        [self stopListening];
    } else {
        self.text = @"";
        [self startListening];
    }
}

- (void)submitText
{
    if (self.onTextSubmitted) {
        self.onTextSubmitted(self.text);
    }
}


#pragma mark - Custom properties

- (void)setText:(NSString *)text
{
    _text = text;
    _attributedText = [[NSAttributedString alloc] initWithString:text];
    [self updateBranding];

    if (!self.label.hidden) {
        self.label.text = text;
        self.label.lineBreakMode = NSLineBreakByTruncatingHead;
        self.textField.placeholder = nil;
        self.textField.text = nil;
    } else {
        self.textField.text = text;
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    _attributedText = attributedText;
    _text = attributedText.string;
    [self updateBranding];

    if (!self.label.hidden) {
        self.label.attributedText = attributedText;
        self.label.lineBreakMode = NSLineBreakByTruncatingHead;
        self.textField.attributedPlaceholder = nil;
        self.textField.attributedText = nil;
    } else {
        self.textField.attributedText = attributedText;
    }
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;

    if (!self.text.length) {
        self.textField.placeholder = placeholder;
    }
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    _attributedPlaceholder = attributedPlaceholder;
    _placeholder = attributedPlaceholder.string;

    if (!self.text.length) {
        self.textField.attributedPlaceholder = attributedPlaceholder;
    }
}

- (NSAttributedString *)attributedPlaceholderString:(NSString *)string
{
    return [[NSAttributedString alloc] initWithString:string
                                           attributes:self.placeholderAttributes];
}

- (NSDictionary *)placeholderAttributes
{
    NSDictionary *placeholderAttributes = @{ NSForegroundColorAttributeName: [UIColor lightGrayColor] };
    return  placeholderAttributes;
}

- (UIColor *)backgroundColor
{
    return self.privateBackgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.privateBackgroundColor = backgroundColor;

    self.backgroundView.layer.backgroundColor = backgroundColor.CGColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;

    self.backgroundView.layer.borderColor = borderColor.CGColor;
}


#pragma mark - UIResponder

- (BOOL)resignFirstResponder
{
    return [self.textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

- (BOOL)isFirstResponder
{
    return [self.textField isFirstResponder];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.listener.listening) {
        return NO;
    }

    // hide the label while we edit the text using the textfield
    self.label.hidden = YES;
    self.textField.attributedText = self.attributedText;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.editing = YES;
    self.textField.attributedPlaceholder = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // when the text field finishes editing submit the text
    typeof(self) __weak weakSelf = self;
    self.onTextFieldDidEndEditing = ^() {
        [weakSelf submitText];
        weakSelf.onTextFieldDidEndEditing = nil;
    };

    [self resignFirstResponder];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.editing = NO;

    if (self.textField.text.length) {
        self.label.attributedText = textField.attributedText;
        self.label.lineBreakMode = NSLineBreakByTruncatingHead;
        self.label.hidden = NO;
        textField.attributedText = nil;
        textField.attributedPlaceholder = nil;
    } else {
        textField.attributedPlaceholder = self.attributedPlaceholder;
    }

    if (self.onTextFieldDidEndEditing) {
        self.onTextFieldDidEndEditing();
    }
}

#pragma mark - default colors

+ (UIColor *)defaultBackgroundColor
{
    return [UIColor blackColor];
}

+ (UIColor *)defaultBorderColor
{
    return [UIColor colorWithRed:0.129 green:0.059 blue:0.18 alpha:1.000];
}

@end
