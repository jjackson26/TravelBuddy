//
//  MMActivityIndicatorView.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/13/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// interface
#import "MMActivityIndicatorView.h"

// utilities
#import "CAShapeLayer+MindMeld.h"
#import "JMJParametricAnimation.h"

static const CGFloat kOuterRadius = 100.0f;
static const CGFloat kRadius = 65.0f;

static const CFTimeInterval kAnimationDuration = 2.5f;

// this is the fraction of the circle for which the deviation should be present
static const CGFloat kDeviationLength = 0.5f;
static const CGFloat kDeviationFrequency = 6.0f;
static const CGFloat kDeviationAmplitude = 7.5f;

static const CGFloat kInitialDeviationTimeOffset = 0.0;
static const CGFloat kMedialDeviationTimeOffset  = 1.0;
static const CGFloat kFinalDeviationTimeOffset   = 2.0;


NS_ENUM(NSInteger, MMActivityIndicatorState) {
    MMActivityIndicatorStateIdle = 0,
    MMActivityIndicatorStateStarting,
    MMActivityIndicatorStateActive,
    MMActivityIndicatorStateStopRequested,
    MMActivityIndicatorStateStopping
};

@interface MMActivityIndicatorLayer :CAShapeLayer

@property (nonatomic, assign) CGFloat animationShift;
@property (nonatomic, strong) NSArray *animations;
@property (nonatomic, assign) enum MMActivityIndicatorState state;

+ (instancetype)layerWithStrokeColor:(CGColorRef)color
                      animationShift:(CGFloat)animationShift;

- (void)cancelAnimation;

@end


@interface MMActivityIndicatorView ()

+ (UIColor *)defaultBackgroundColor;
+ (UIColor *)defaultStrokeColor;
+ (UIColor *)defaultGlowColor;

@property (nonatomic, strong) UIColor *privateBackgroundColor;

@property (nonatomic, strong) MMActivityIndicatorLayer *strokeLayer1;
@property (nonatomic, strong) MMActivityIndicatorLayer *strokeLayer2;

@end

@implementation MMActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect theRealFrame = CGRectMake(frame.origin.x, frame.origin.y, kOuterRadius * 2, kOuterRadius * 2);
    self = [super initWithFrame:theRealFrame];
    if (self) {
        [self initializeActivityIndicator];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeActivityIndicator];
    }
    return self;
}

- (void)initializeActivityIndicator
{
    [self setDefaultAppearanceProperties];

    super.backgroundColor = [UIColor clearColor];
    self.layer.backgroundColor = self.backgroundColor.CGColor;
    self.layer.cornerRadius = kOuterRadius;
    self.layer.shouldRasterize = YES;
    self.layer.contentsScale = self.layer.rasterizationScale = [UIScreen mainScreen].scale;

    self.strokeLayer1 = [MMActivityIndicatorLayer layerWithStrokeColor:self.strokeColor.CGColor
                                                        animationShift:0];
    self.strokeLayer2 = [MMActivityIndicatorLayer layerWithStrokeColor:self.strokeColor.CGColor
                                                        animationShift:0.25];
    self.strokeLayer1.position = self.strokeLayer2.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self.layer addSublayer:self.strokeLayer1];
    [self.layer addSublayer:self.strokeLayer2];
}

- (void)setDefaultAppearanceProperties
{
    _privateBackgroundColor = [MMActivityIndicatorView defaultBackgroundColor];
    _strokeColor = [MMActivityIndicatorView defaultStrokeColor];
    _glowColor   = [MMActivityIndicatorView defaultGlowColor];
}

- (CGSize)intrinsicContentSize
{
    CGFloat dimension = kOuterRadius * 2;
    return CGSizeMake(dimension, dimension);
}

#pragma mark - Animation

- (BOOL)isAnimating
{
    return (self.strokeLayer1.state != MMActivityIndicatorStateIdle ||
            self.strokeLayer2.state != MMActivityIndicatorStateIdle);
}

- (void)startAnimating
{
    if (self.animating) {
        return;
    }

    NSInteger divisor = 1000000;
    CGFloat angle = arc4random_uniform((unsigned int)divisor) * 2.0 * M_PI / divisor;
    self.strokeLayer1.transform = self.strokeLayer2.transform = CATransform3DMakeRotation(angle, 0, 0, 1);

    self.strokeLayer1.state = self.strokeLayer2.state = MMActivityIndicatorStateStarting;
}

- (void)stopAnimating
{
    if (!self.animating ||
        self.strokeLayer1.state >= MMActivityIndicatorStateStopRequested ||
        self.strokeLayer2.state >= MMActivityIndicatorStateStopRequested) {
        return;
    }

    self.strokeLayer1.state = self.strokeLayer2.state = MMActivityIndicatorStateStopRequested;
}

- (void)cancelAnimation
{
    if (self.animating) {
        return;
    }

    [self.strokeLayer1 cancelAnimation];
    [self.strokeLayer2 cancelAnimation];
}


#pragma mark - properties

- (UIColor *)backgroundColor
{
    return self.privateBackgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.privateBackgroundColor = backgroundColor;

    self.layer.backgroundColor = backgroundColor.CGColor;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;

    self.strokeLayer1.strokeColor = strokeColor.CGColor;
    self.strokeLayer2.strokeColor = strokeColor.CGColor;
}

- (void)setGlowColor:(UIColor *)glowColor
{
    _glowColor = glowColor;

    self.strokeLayer1.shadowColor = glowColor.CGColor;
    self.strokeLayer2.shadowColor = glowColor.CGColor;
}

+ (UIColor *)defaultBackgroundColor
{
    return [UIColor colorWithWhite:0.0 alpha:0.25];
}

+ (UIColor *)defaultStrokeColor
{
    return [UIColor orangeColor];
}

+ (UIColor *)defaultGlowColor
{
    return [UIColor whiteColor];
}

@end


@implementation MMActivityIndicatorLayer

#pragma mark - Lifecycle

+ (instancetype)layerWithStrokeColor:(CGColorRef)strokeColor
                      animationShift:(CGFloat)animationShift
{
    MMActivityIndicatorLayer *layer = [[MMActivityIndicatorLayer alloc] initWithAnimationShift:animationShift];
    layer.strokeColor = strokeColor;
    return layer;
}

- (instancetype)initWithAnimationShift:(CGFloat)animationShift
{
    self = [super init];
    if (self) {
        self.animationShift = animationShift;
        [self initializeLayer];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithAnimationShift:0];
}

- (void)initializeLayer
{
    self.bounds = CGRectMake(0, 0, kOuterRadius, kOuterRadius);

    [[self class] styleLayerForMindMeldGlow:self];

    CGPathRef path = [self newCircularPathWithDeviationTime:0
                                                     length:0
                                                  frequency:1
                                                  amplitude:0
                                                      shift:0];
    self.path = path;
    CGPathRelease(path);

    [self createAnimations];
}

#pragma mark - Animation

- (void)setState:(enum MMActivityIndicatorState)state
{
    if (state == MMActivityIndicatorStateStarting) {
        [self addAnimation:self.animations[0]
                    forKey:@"starting"];
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        anim.duration = 10.0;
        NSNumber *fromValue = [self valueForKeyPath:@"transform.rotation.z"];
        anim.toValue = @((-2.0 * M_PI) + fromValue.doubleValue);
        anim.repeatCount = HUGE_VALF;

        [self addAnimation:anim
                    forKey:@"rotation"];
    }

    _state = state;
}

- (void)cancelAnimation
{
    self.state = MMActivityIndicatorStateIdle;
    [self removeAllAnimations];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    switch (self.state) {
        case MMActivityIndicatorStateStarting:
        case MMActivityIndicatorStateActive:
            [self addAnimation:self.animations[1]
                        forKey:@"active"];
            self.state = MMActivityIndicatorStateActive;
            break;
        case MMActivityIndicatorStateStopRequested:
            [self addAnimation:self.animations[2]
                        forKey:@"stopping"];
            self.state = MMActivityIndicatorStateStopping;
            break;
        case MMActivityIndicatorStateStopping:
            [self removeAllAnimations];
            self.state = MMActivityIndicatorStateIdle;
            break;
        case MMActivityIndicatorStateIdle:
        default: // only when cancelled
            break;
    }
}

- (void)createAnimations
{
    JMJParametricValueBlock pathValueFxn =  ^id (double progress, id value1, id value2) {
        NSNumber *shift = (NSNumber *)value1; // this is the period shift of the
        NSNumber *timeOffset = (NSNumber *)value2;

        CGFloat to = progress + timeOffset.floatValue;

        CGPathRef path = [self newCircularPathWithDeviationTime:to
                                                         length:kDeviationLength
                                                      frequency:kDeviationFrequency
                                                      amplitude:kDeviationAmplitude
                                                          shift:shift.floatValue];
        return (__bridge_transfer id)path;
    };


    CAKeyframeAnimation *initial = [CAKeyframeAnimation animationWithKeyPath:@"path"
                                                                    timeFxn:JMJParametricAnimationTimeBlockLinear
                                                                   valueFxn:pathValueFxn
                                                                  fromValue:@(self.animationShift)
                                                                    toValue:@(kInitialDeviationTimeOffset)];
    CAKeyframeAnimation *medial = [CAKeyframeAnimation animationWithKeyPath:@"path"
                                                                    timeFxn:JMJParametricAnimationTimeBlockLinear
                                                                   valueFxn:pathValueFxn
                                                                  fromValue:@(self.animationShift)
                                                                    toValue:@(kMedialDeviationTimeOffset)];
    CAKeyframeAnimation *final = [CAKeyframeAnimation animationWithKeyPath:@"path"
                                                                    timeFxn:JMJParametricAnimationTimeBlockLinear
                                                                   valueFxn:pathValueFxn
                                                                  fromValue:@(self.animationShift)
                                                                    toValue:@(kFinalDeviationTimeOffset)];

    initial.delegate = medial.delegate = final.delegate = self;
    initial.duration = medial.duration = final.duration = kAnimationDuration;
    initial.fillMode = medial.fillMode = final.fillMode = kCAFillModeForwards;
    initial.removedOnCompletion = medial.removedOnCompletion = final.removedOnCompletion = NO;

    // Remove second half of final animation which has no changes
    NSMutableArray *finalValues = [NSMutableArray arrayWithArray:final.values];
    NSInteger pos = finalValues.count / 2;
    [finalValues removeObjectsInRange:NSMakeRange(pos, finalValues.count - pos)];
    final.values = [NSArray arrayWithArray:finalValues];
    final.duration = kAnimationDuration / 2.0;

    self.animations = @[ initial, medial, final ];
}


#pragma mark - Drawing

/**
 *  This method returns a circular path with a sinusoidal oscillation which ends
 *
 *  @param time      The current head of the oscillation as a normalized radian. 0 means the x-axis, 0.25 means the
 *                   y-axis (which points down in iOS' standard coordinate system), 0.5 means the negative x-axis, etc.
 *  @param length    the length of the oscillation as a normalized radian. 0 would mean no oscillation, 0.5 would mean 
 *                   an oscillation that spans half the circle, 1 would mean an oscillation that spans the entire arc 
 *                   of the circle.
 *  @param frequency The frequency
 *  @param amplitude The size of the deviation from the standard radius.
 *  @param shift     The period shift of the
 *
 *  @return A circular path about the center of this layer, with the oscillation described by the parameters
 */
- (CGPathRef)newCircularPathWithDeviationTime:(CGFloat)time
                                       length:(CGFloat)length
                                    frequency:(CGFloat)frequency
                                    amplitude:(CGFloat)amplitude
                                        shift:(CGFloat)shift
{
    BOOL initial = YES;
    if (time >= 1.0) {
        initial = NO;
    }

    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat from = time - length;

    CGMutablePathRef path = CGPathCreateMutable();

    NSInteger numPoints = 101;
    CGPoint points[numPoints];

    CGFloat radian = 0;
    for (NSInteger i = 0; i < numPoints; i++) {
        CGFloat progress = i * 1.0 / (numPoints - 1);
        radian = progress * 2.0 * M_PI;

        CGFloat taperEffect = 0;
        if (length != 0) {
            CGFloat deviationProgress = (progress - from) / length;

            if (deviationProgress < 0.0 || deviationProgress > 1.0) {
                if (time >= 1.0 &&
                    deviationProgress >= -2.0 &&
                    deviationProgress <= -1.0) {
                    deviationProgress += 2.0;
                } else {
                    deviationProgress = 0.0;
                }
            }

            taperEffect = sinf(deviationProgress * M_PI);
        }
        CGFloat radiusOffset = amplitude * taperEffect * sinf((progress + shift) * 2 * M_PI * frequency);
        CGFloat effectiveRadius = kRadius + radiusOffset;

        points[i].x = center.x + effectiveRadius * cos(radian);
        points[i].y = center.y + effectiveRadius * sin(radian);
    }

    CGPathAddLines(path, NULL, points, numPoints);

    CGPathRef result = CGPathCreateCopy(path);
    CGPathRelease(path);
    return result;
}


@end