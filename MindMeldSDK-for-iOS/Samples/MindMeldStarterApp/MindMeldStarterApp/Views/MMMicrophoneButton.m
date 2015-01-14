//
//  MMMicrophoneButton.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 17/09/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// interface
#import "MMMicrophoneButton.h"

// utilities
#import "CAShapeLayer+MindMeld.h"
#import "UIImage+Masks.h"

static const float kBorderWidth = 2.0f;
static const float kMaxVolumeScale = 4.00f;
static const float kMinVolumeScale = 2.00f;

static const float kBorderClosureRatio = 0.875f;

static const CFTimeInterval kVolumeAnimationDuration = 0.50;
static const CFTimeInterval kRecordingAnimationDuration = 0.50;
static const CFTimeInterval kBorderAnimationDuration = kRecordingAnimationDuration;

@interface MMMicrophoneButtonBorderLayer : CAShapeLayer

- (void)appear;
- (void)disappear;

@end

@interface MMMicrophoneButton ()

// subviews
@property (nonatomic, strong) UIView *fillBackgroundView;
@property (nonatomic, strong) UIView *volumeView;
@property (nonatomic, strong) UIButton *internalButton;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImage *activeIconImage;
@property (nonatomic, strong) UIImage *highlightedIconImage;

@property (nonatomic, strong) MMMicrophoneButtonBorderLayer *activeBorderLayer;

@property (nonatomic, strong) UIColor *privateBackgroundColor;

+ (UIColor *)defaultIconColor;
+ (UIColor *)defaultActiveIconColor;
+ (UIColor *)defaultHighlightedIconColor;
+ (UIColor *)defaultBackgroundColor;
+ (UIColor *)defaultActiveBackgroundColor;
+ (UIColor *)defaultHighlightedBackgroundColor;
+ (UIColor *)defaultBorderColor;
+ (UIColor *)defaultActiveBorderColor;
+ (UIColor *)defaultActiveBorderGlowColor;
+ (UIColor *)defaultHighlightedBorderColor;
+ (UIColor *)defaultVolumeColor;

@end

@implementation MMMicrophoneButton

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeMicrophoneButton];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeMicrophoneButton];
    }
    return self;
}

- (void)initializeMicrophoneButton
{
    // use default colors
    [self setDefaultAppearanceProperties];

    self.clipsToBounds = NO;

    self.volumeView = [self createViewWithFrame:self.bounds
                                backgroundColor:self.volumeColor
                                shouldRasterize:NO];
    self.volumeView.alpha = 0.15;
    self.volumeView.hidden = YES;
    [self addSubview:self.volumeView];


    CGFloat fillRadius = CGRectGetWidth(self.bounds) / 2.0;
    self.fillBackgroundView = [self createViewWithFrame:[self rectForRadius:fillRadius]
                                        backgroundColor:self.backgroundColor
                                        shouldRasterize:NO];
    self.fillBackgroundView.layer.borderWidth = kBorderWidth;
    self.fillBackgroundView.layer.borderColor = self.borderColor.CGColor;
    [self addSubview:self.fillBackgroundView];

    [self generateIconImages];
    self.internalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.internalButton setImage:self.iconImage
                         forState:UIControlStateNormal];
    [self.internalButton setImage:self.highlightedIconImage
                         forState:UIControlStateHighlighted];
    [self addSubview:self.internalButton];

    self.activeBorderLayer = [MMMicrophoneButtonBorderLayer layer];
    self.activeBorderLayer.strokeColor = self.activeBorderColor.CGColor;
    self.activeBorderLayer.shadowColor = self.activeBorderGlowColor.CGColor;
    [self.layer addSublayer:self.activeBorderLayer];

    [self layoutSubviews];

    [self addObservers];
}

- (void)setDefaultAppearanceProperties
{
    _iconColor = [MMMicrophoneButton defaultIconColor];
    _activeIconColor = [MMMicrophoneButton defaultActiveIconColor];
    _highlightedIconColor = [MMMicrophoneButton defaultHighlightedIconColor];
    _privateBackgroundColor = [MMMicrophoneButton defaultBackgroundColor];
    _activeBackgroundColor = [MMMicrophoneButton defaultActiveBackgroundColor];
    _highlightedBackgroundColor = [MMMicrophoneButton defaultHighlightedBackgroundColor];
    _borderColor = [MMMicrophoneButton defaultBorderColor];
    _activeBorderColor = [MMMicrophoneButton defaultActiveBorderColor];
    _activeBorderGlowColor = [MMMicrophoneButton defaultActiveBorderGlowColor];
    _volumeColor = [MMMicrophoneButton defaultVolumeColor];
}

- (UIView *)createViewWithFrame:(CGRect)frame
                backgroundColor:(UIColor *)backgroundColor
                shouldRasterize:(BOOL)shouldRasterize {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = backgroundColor;

    if (shouldRasterize) {
        view.layer.shouldRasterize = YES;
        view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }

    return view;
}

- (void)dealloc
{
    [self removeObservers];
}

#pragma mark - layout

- (void)layoutSubviews {
    CGFloat radius = CGRectGetWidth(self.bounds) / 2.0;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    self.volumeView.bounds = self.bounds;
    self.volumeView.center = center;
    self.volumeView.layer.cornerRadius = radius;

    CGFloat fillRadius = CGRectGetWidth(self.bounds) / 2;
    self.fillBackgroundView.center = center;
    self.fillBackgroundView.bounds = [self rectForRadius:fillRadius];
    self.fillBackgroundView.layer.cornerRadius = fillRadius;

    self.activeBorderLayer.bounds = self.bounds;
    self.activeBorderLayer.position = center;

    self.internalButton.bounds = self.bounds;
    self.internalButton.center = center;
    UIImage *iconImage = self.iconImage;
    CGFloat verInset = (CGRectGetHeight(self.bounds) - iconImage.size.height) / 2;
    CGFloat horInset = (CGRectGetWidth(self.bounds) - iconImage.size.width) / 2;
    UIEdgeInsets imageInsets = UIEdgeInsetsMake(verInset, horInset, verInset, horInset);
    self.internalButton.contentEdgeInsets = imageInsets;

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


#pragma mark - KVO

- (void)addObservers
{
    [self.internalButton addObserver:self forKeyPath:@"highlighted"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
}

- (void)removeObservers
{
    [self.internalButton removeObserver:self forKeyPath:@"highlighted"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.internalButton) {
        UIColor *backgroundColor = self.backgroundColor;
        UIColor *borderColor = self.borderColor;
        if (self.internalButton.isHighlighted) {
            if (self.highlightedBackgroundColor) {
                backgroundColor = self.highlightedBackgroundColor;
            }
            if (self.highlightedBorderColor) {
                borderColor = self.highlightedBorderColor;
            }
        } else if (self.microphoneState >= MMMicrophoneButtonStatePending) {
            if (self.activeBackgroundColor) {
                backgroundColor = self.activeBackgroundColor;
            }
        }
        self.fillBackgroundView.backgroundColor = backgroundColor;
        self.fillBackgroundView.layer.borderColor = borderColor.CGColor;
    }
}

#pragma mark - Custom properties

- (void)setMicrophoneState:(enum MMMicrophoneButtonState)microphoneState
{
    enum MMMicrophoneButtonState previousState = _microphoneState;
    if (previousState == microphoneState) {
        return;
    }

    _microphoneState = microphoneState;

    BOOL active = NO;
    switch (microphoneState) {
        case MMMicrophoneButtonStatePending:
            [self.activeBorderLayer appear];
        case MMMicrophoneButtonStateRecording:
        case MMMicrophoneButtonStateProcessing:
            active = YES;
            break;
        case MMMicrophoneButtonStateIdle:
        default:
            [self.activeBorderLayer disappear];
            active = NO;
            break;
    }

    if (self.microphoneState == MMMicrophoneButtonStateRecording) {
        [self oscillateVolume];
    }

    if (self.internalButton.isHighlighted) {
        return; // don't animate background if button is highlighted
    }

    typeof(self) __weak weakSelf = self;
    void (^backgroundAnimation)() = ^{
        UIColor *backgroundColor = active ? self.activeBackgroundColor : self.backgroundColor;

        weakSelf.fillBackgroundView.layer.backgroundColor = backgroundColor.CGColor;
    };

    [UIView animateWithDuration:kRecordingAnimationDuration
                     animations:backgroundAnimation];
}

- (CGFloat)volumeViewScale
{
    return kMinVolumeScale + (kMaxVolumeScale - kMinVolumeScale) * self.volumeLevel;
}

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    [self layoutSubviews];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.privateBackgroundColor = backgroundColor;
    if (self.microphoneState == MMMicrophoneButtonStateIdle) {
        self.fillBackgroundView.backgroundColor = backgroundColor;
    }
}

- (UIColor *)backgroundColor
{
    return self.privateBackgroundColor;
}

- (void)setActiveBackgroundColor:(UIColor *)activeBackgroundColor
{
    _activeBackgroundColor = activeBackgroundColor;
    if (self.microphoneState >= MMMicrophoneButtonStatePending) {
        self.fillBackgroundView.backgroundColor = activeBackgroundColor;
    }
}

- (void)setIconColor:(UIColor *)iconColor {
    _iconColor = iconColor;
    [self generateIconImage];
    [self.internalButton setImage:self.iconImage forState:UIControlStateNormal];
}

- (void)setActiveIconColor:(UIColor *)activeIconColor
{
    _activeIconColor = activeIconColor;
    [self generateActiveIconImage];
    if (self.microphoneState >= MMMicrophoneButtonStatePending) {
        [self.internalButton setImage:self.activeIconImage
                             forState:UIControlStateNormal];
    }
}

- (void)setHighlightedIconColor:(UIColor *)highlightedIconColor
{
    _highlightedIconColor = highlightedIconColor;
    [self generateHighlightedIconImage];
    [self.internalButton setImage:self.highlightedIconImage forState:UIControlStateHighlighted];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    self.fillBackgroundView.layer.borderColor = borderColor.CGColor;
}

- (void)setActiveBorderColor:(UIColor *)activeBorderColor
{
    _activeBorderColor = activeBorderColor;
    self.activeBorderLayer.strokeColor = activeBorderColor.CGColor;
}

- (void)setActiveBorderGlowColor:(UIColor *)activeBorderGlowColor
{
    _activeBorderGlowColor = activeBorderGlowColor;
    self.activeBorderLayer.shadowColor = activeBorderGlowColor.CGColor;
}

- (void)setVolumeColor:(UIColor *)volumeColor
{
    _volumeColor = volumeColor;
    self.volumeView.backgroundColor = volumeColor;
}


#pragma mark - Icon
- (void)generateIconImages
{
    [self generateIconImage];
    [self generateActiveIconImage];
    [self generateHighlightedIconImage];
}

- (UIImage *)microphoneMask
{
    UIImage *iconImageMask = [UIImage imageNamed:@"microphone-mask"];
    return iconImageMask;
}

- (void)generateIconImage
{
    if (self.iconColor) {
    self.iconImage = [UIImage colorizeImage:self.microphoneMask
                                      color:self.iconColor];
    } else {
        self.iconImage = nil;
    }
}

- (void)generateActiveIconImage
{
    if (self.activeIconColor) {
        self.activeIconImage = [UIImage colorizeImage:self.microphoneMask
                                                color:self.activeIconColor];
    } else {
        self.activeIconImage = nil;
    }
}

- (void)generateHighlightedIconImage
{
    if (self.highlightedIconColor) {
        self.highlightedIconImage = [UIImage colorizeImage:self.microphoneMask
                                                     color:self.highlightedIconColor];
    } else {
        self.highlightedIconImage = nil;
    }
}


#pragma mark - UIControl (internal button)

- (void)sendAction:(SEL)action
                to:(id)target
          forEvent:(UIEvent *)event
{
    [self.internalButton sendAction:action
                                 to:target
                           forEvent:event];
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    [self.internalButton sendActionsForControlEvents:controlEvents];
}

- (void)addTarget:(id)target
           action:(SEL)action
 forControlEvents:(UIControlEvents)controlEvents
{
    [self.internalButton addTarget:target
                            action:action
                  forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target
              action:(SEL)action
    forControlEvents:(UIControlEvents)controlEvents
{
    [self.internalButton removeTarget:target
                               action:action
                     forControlEvents:controlEvents];
}

- (NSArray *)actionsForTarget:(id)target
              forControlEvent:(UIControlEvents)controlEvent
{
    return [self.internalButton actionsForTarget:target
                                 forControlEvent:controlEvent];
}

- (NSSet *)allTargets
{
    return self.internalButton.allTargets;
}

- (UIControlEvents)allControlEvents
{
    return self.internalButton.allControlEvents;
}

- (UIControlState)state
{
    return self.internalButton.state;
}

#pragma mark - Animations

- (void)oscillateVolume {
    typeof(self) __weak weakSelf = self;
    void (^completion)(BOOL) = ^(BOOL finished) {
        if (weakSelf.microphoneState == MMMicrophoneButtonStateRecording) {
            [weakSelf oscillateVolume];
        } else {
            [weakSelf animateVolumeViewToScale:1.0
                                      duration:kVolumeAnimationDuration / 2.0
                                    completion:^(BOOL finished) { weakSelf.volumeView.hidden = YES; }];
        }
    };


    CGFloat currentScale = [[self.volumeView.layer valueForKeyPath:@"transform.scale"] doubleValue];
    NSLog(@"currentScale %f", currentScale);
    CGFloat scale = self.volumeViewScale;
    scale = scale + ((currentScale > scale) ? -1 : 1) * 0.025;
    self.volumeView.hidden = NO;
    [self animateVolumeViewToScale:scale
                          duration:kVolumeAnimationDuration
                        completion:completion];
}

- (void)animateVolumeViewToScale:(CGFloat)scale
                        duration:(NSTimeInterval)duration
                      completion:(void (^)(BOOL finished))completion {

    typeof(self) __weak weakSelf = self;
    void (^animations)() = ^{
        weakSelf.volumeView.layer.transform = CATransform3DMakeScale(scale, scale, scale);
    };

    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:completion];
}


#pragma mark - Constants

+ (UIColor *)defaultIconColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)defaultActiveIconColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)defaultHighlightedIconColor
{
    return [UIColor darkGrayColor];
}

+ (UIColor *)defaultBackgroundColor
{
    return [UIColor orangeColor];
}

+ (UIColor *)defaultActiveBackgroundColor
{
    return nil;
}

+ (UIColor *)defaultHighlightedBackgroundColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)defaultBorderColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)defaultActiveBorderColor
{
    return [UIColor lightGrayColor];
}

+ (UIColor *)defaultActiveBorderGlowColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)defaultHighlightedBorderColor
{
    return nil;
}

+ (UIColor *)defaultVolumeColor
{
    return [UIColor lightGrayColor];
}

@end

@interface MMMicrophoneButtonBorderLayer ()

@property (nonatomic, copy) void (^onAnimationDidStop)(id anim, BOOL finished);

@end

@implementation MMMicrophoneButtonBorderLayer

+ (instancetype)layer
{
    MMMicrophoneButtonBorderLayer *layer = [self new];
    [self styleLayerForMindMeldGlow:layer];
    layer.masksToBounds = NO;
    layer.lineWidth = kBorderWidth;

    return layer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.strokeStart = self.strokeEnd = 0.0;;
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];

    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = CGRectGetWidth(self.bounds) / 2.0;

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius - 1.0
                                                    startAngle:M_PI_2
                                                      endAngle:M_PI_2 + (2.0 * M_PI)
                                                     clockwise:YES];
    self.path = path.CGPath;
}

- (void)appear
{
    typeof(self) __weak weakSelf = self;
    void (^onRotateDidStop)(id, BOOL) = ^(CABasicAnimation *anim, BOOL finished) {
        CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];

        rotate.delegate = weakSelf;
        rotate.duration = kBorderAnimationDuration * 2.0;
        rotate.toValue = @(2 * M_PI);

        [weakSelf addAnimation:rotate
                        forKey:@"rotate"];
    };
    self.onAnimationDidStop = ^(CABasicAnimation *anim, BOOL finished) {
        weakSelf.strokeEnd = kBorderClosureRatio;
        weakSelf.onAnimationDidStop = onRotateDidStop;
        onRotateDidStop(anim, finished);
    };

    [self animateStrokeKeyPath:@"strokeEnd"
                            to:kBorderClosureRatio];
}

- (void)disappear
{
    typeof(self) __weak weakSelf = self;
    self.onAnimationDidStop = ^(id anim, BOOL finished) {
        weakSelf.strokeStart = weakSelf.strokeEnd = 0.0;

    };
    [self animateStrokeKeyPath:@"strokeStart"
                            to:kBorderClosureRatio];
}

- (void)animateStrokeKeyPath:(NSString *)keyPath
                          to:(CGFloat)value
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:keyPath];

    anim.duration = kBorderAnimationDuration;
    anim.toValue = @(value);
    anim.delegate = self;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;

    [self addAnimation:anim
                forKey:@"stroke"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.onAnimationDidStop) {
        self.onAnimationDidStop(anim, flag);
    }
}

@end
