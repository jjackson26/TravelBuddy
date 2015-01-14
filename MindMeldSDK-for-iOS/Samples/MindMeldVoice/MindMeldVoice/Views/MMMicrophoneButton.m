//
//  MMMicrophoneButton.m
//  MindMeldVoice
//
//  Created by J.J. Jackson on 17/09/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "MMMicrophoneButton.h"

#import "UIColor+MindMeldVoice.h"
#import "UIImage+Masks.h"

static const float kBorderWidth = 2.0f;
static const float kImageScale = 0.5f;
static const float kMaxVolumeScale = 1.50f;
static const float kMinVolumeScale = 1.10f;
static const float kRecordingScale = 0.75f;
static const CFTimeInterval kVolumeAnimationDuration = 0.50;
static const CFTimeInterval kRecordingAnimationDuration = 0.50;

@interface MMMicrophoneButton ()

// subviews
@property (nonatomic, strong) UIView *fillBackgroundView;
@property (nonatomic, strong) UIView *accentBackgroundView;
@property (nonatomic, strong) UIImageView *micImageView;
@property (nonatomic, strong) UIView *volumeView;
@property (nonatomic, strong) UIButton *internalButton;

@property (nonatomic, strong) UIColor *privateBackgroundColor;

+ (UIColor *)defaultIconColor;
+ (UIColor *)defaultBackgroundColor;
+ (UIColor *)defaultRecordingBackgroundColor;
+ (UIColor *)defaultAccentColor;
+ (UIColor *)defaultBorderColor;
+ (UIColor *)defaultVolumeColor;

@end

@implementation MMMicrophoneButton


#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [super setTitle:@""
          forState:UIControlStateNormal];
    self.clipsToBounds = NO;

    // use default colors
    self.iconColor = [MMMicrophoneButton defaultIconColor];
    self.backgroundColor = [MMMicrophoneButton defaultBackgroundColor];
    self.recordingBackgroundColor = [MMMicrophoneButton defaultRecordingBackgroundColor];
    self.accentColor = [MMMicrophoneButton defaultAccentColor];
    self.borderColor = [MMMicrophoneButton defaultBorderColor];
    self.volumeColor = [MMMicrophoneButton defaultVolumeColor];

    self.volumeView = [self createViewWithFrame:self.bounds
                                backgroundColor:self.volumeColor
                                shouldRasterize:YES];
    self.volumeView.alpha = 0.5;
    self.volumeView.hidden = YES;
    [self addSubview:self.volumeView];

    self.accentBackgroundView = [self createViewWithFrame:self.bounds
                                          backgroundColor:self.accentColor
                                          shouldRasterize:YES];
    self.accentBackgroundView.layer.borderColor = self.borderColor.CGColor;
    self.accentBackgroundView.layer.borderWidth = kBorderWidth;
    [self addSubview:self.accentBackgroundView];

    CGFloat fillRadius = CGRectGetWidth(self.bounds) / 2.0 - kBorderWidth;
    self.fillBackgroundView = [self createViewWithFrame:[self rectForRadius:fillRadius]
                                        backgroundColor:self.backgroundColor
                                        shouldRasterize:YES];
    [self addSubview:self.fillBackgroundView];

    UIImage *micImage = [UIImage colorizeImage:[UIImage imageNamed:@"microphone-mask"]
                                         color:self.iconColor];
    self.micImageView = [[UIImageView alloc] initWithImage:micImage];
    [self addSubview:self.micImageView];

    self.internalButton = [[UIButton alloc] initWithFrame:self.bounds];
    [self addSubview:self.internalButton];

    [self layoutSubviews];
}

- (UIView *)createViewWithFrame:(CGRect)frame
                backgroundColor:(UIColor *)backgroundColor
                shouldRasterize:(BOOL)shouldRasterize {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.layer.backgroundColor = backgroundColor.CGColor;
    self.layer.masksToBounds = NO;

    if (shouldRasterize) {
        view.layer.shouldRasterize = YES;
        view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }

    return view;
}

- (void)layoutSubviews {
    CGFloat radius = CGRectGetWidth(self.bounds) / 2.0;

    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    self.volumeView.bounds = self.bounds;
    self.volumeView.center = center;
    self.volumeView.layer.cornerRadius = radius;

    CGFloat fillRadius = CGRectGetWidth(self.bounds) / 2.0 - kBorderWidth;
    self.fillBackgroundView.center = self.volumeView.center;
    self.fillBackgroundView.bounds = [self rectForRadius:fillRadius];
    self.fillBackgroundView.layer.cornerRadius = fillRadius;

    self.accentBackgroundView.bounds = self.bounds;
    self.accentBackgroundView.center = center;
    self.accentBackgroundView.layer.cornerRadius = radius;

    CGFloat imageRadius = CGRectGetWidth(self.bounds) * kImageScale / 2;
    self.micImageView.frame = [self rectForRadius:imageRadius];
    self.micImageView.center = center;

    self.internalButton.bounds = self.bounds;
    self.internalButton.center = center;

    [super layoutSubviews];
}

- (CGRect)rectForRadius:(CGFloat)radius {
    CGFloat margin = (CGRectGetWidth(self.bounds) / 2) - radius;
    CGRect frame = {
        { margin, margin },
        { radius * 2, radius * 2 }
    };
    return frame;
}

#pragma mark - Custom properties

- (void)setRecording:(BOOL)recording {
    _recording = recording;

    typeof(self) __weak weakSelf = self;
    void (^animations)() = ^{
        CGFloat backgroundScale = weakSelf.recording ? kRecordingScale : 1.0;
        weakSelf.fillBackgroundView.backgroundColor = recording ? self.recordingBackgroundColor : self.backgroundColor;
        weakSelf.fillBackgroundView.layer.transform = CATransform3DMakeScale(backgroundScale, backgroundScale, 1);
    };

    [UIView animateWithDuration:kRecordingAnimationDuration
                     animations:animations];

    if (self.recording) {
        [self oscillateVolume];
    }
}

- (CGFloat)volumeViewScale {
    return kMinVolumeScale + (kMaxVolumeScale - kMinVolumeScale) * self.volumeLevel;
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    [self layoutSubviews];
}

- (void)setIconColor:(UIColor *)iconColor {
    _iconColor = iconColor;
    // TODO: colorize icon image
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.privateBackgroundColor = backgroundColor;
    if (!self.recording) {
        self.fillBackgroundView.layer.backgroundColor = backgroundColor.CGColor;
    }
}

- (UIColor *)backgroundColor {
    return self.privateBackgroundColor;
}

- (void)setRecordingBackgroundColor:(UIColor *)recordingBackgroundColor {
    _recordingBackgroundColor = recordingBackgroundColor;
    if (self.recording) {
        self.fillBackgroundView.layer.backgroundColor = recordingBackgroundColor.CGColor;
    }
}

- (void)setAccentColor:(UIColor *)accentColor {
    _accentColor = accentColor;
    self.accentBackgroundView.layer.backgroundColor = accentColor.CGColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.accentBackgroundView.layer.borderColor = borderColor.CGColor;
}

- (void)setVolumeColor:(UIColor *)volumeColor {
    _volumeColor = volumeColor;
    self.volumeView.layer.backgroundColor = volumeColor.CGColor;
}

#pragma mark - UIButton

- (void)setTitle:(NSString *)title
        forState:(UIControlState)state {
    // don't allow external title
}

#pragma mark - UIControl (internal button)

- (void)sendAction:(SEL)action
                to:(id)target
          forEvent:(UIEvent *)event {
    [self.internalButton sendAction:action
                                 to:target
                           forEvent:event];
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents {
    [self.internalButton sendActionsForControlEvents:controlEvents];
}

- (void)addTarget:(id)target
           action:(SEL)action
 forControlEvents:(UIControlEvents)controlEvents {
    [self.internalButton addTarget:target
                            action:action
                  forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target
              action:(SEL)action
    forControlEvents:(UIControlEvents)controlEvents {
    [self.internalButton removeTarget:target
                               action:action
                     forControlEvents:controlEvents];
}

- (NSArray *)actionsForTarget:(id)target
              forControlEvent:(UIControlEvents)controlEvent {
    return [self.internalButton actionsForTarget:target
                                 forControlEvent:controlEvent];
}

- (NSSet *)allTargets {
    return self.internalButton.allTargets;
}

- (UIControlEvents)allControlEvents {
    return self.internalButton.allControlEvents;
}


#pragma mark - Animations

- (void)oscillateVolume {
    typeof(self) __weak weakSelf = self;
    void (^completion)(BOOL) = ^(BOOL finished) {
        if (weakSelf.recording) {
            [weakSelf oscillateVolume];
        } else {
            [weakSelf animateVolumeViewToScale:1.0
                                        hidden:YES
                                    completion:nil];
        }
    };

    CGFloat currentScale = [[self.volumeView.layer valueForKeyPath:@"transform.scale"] doubleValue];
    CGFloat scale = self.volumeViewScale;
    scale = scale + ((currentScale > scale) ? -1 : 1) * 0.025;
    [self animateVolumeViewToScale:scale
                            hidden:NO
                        completion:completion];
}

- (void)animateVolumeViewToScale:(CGFloat)scale
                          hidden:(BOOL)hidden
                      completion:(void (^)(BOOL finished))completion {

    typeof(self) __weak weakSelf = self;
    void (^animations)() = ^{
        weakSelf.volumeView.hidden = hidden;
        weakSelf.volumeView.layer.transform = CATransform3DMakeScale(scale, scale, scale);
    };

    [UIView animateWithDuration:kVolumeAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:completion];
}


#pragma mark - Constants

+ (UIColor *)defaultIconColor {
    return [UIColor whiteColor];
}

+ (UIColor *)defaultBackgroundColor {
    return [UIColor mindMeldVoiceBlueColor];
}

+ (UIColor *)defaultRecordingBackgroundColor {
    return [UIColor mindMeldVoiceBlueColor];
}

+ (UIColor *)defaultAccentColor {
    return [UIColor blackColor];
}

+ (UIColor *)defaultBorderColor {
    return [UIColor whiteColor];
}

+ (UIColor *)defaultVolumeColor {
    return [UIColor darkGrayColor];
}


@end
