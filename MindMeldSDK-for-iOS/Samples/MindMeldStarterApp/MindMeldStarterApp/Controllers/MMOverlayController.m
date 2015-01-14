//
//  MMOverlayController.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// interface
#import "MMOverlayController.h"
#import "MMOverlayController+SubclassHooks.h"

// utilities
#import "UIImage+ImageEffects.h"
#import "UIView+AutoLayout.h"


static const NSTimeInterval kEntranceAnimationDuration = 0.5;
static const NSTimeInterval kEntranceAnimationContentDelay = 0.125;
static const NSTimeInterval kExitAnimationDuration = 0.375;
static const NSTimeInterval kExitAnimationContentDelay = 0.0;

@interface MMOverlayController ()

@property (nonatomic, strong) UIImage *blurredUnderlyingImage;
@property (nonatomic, strong) UIImageView *underlyingImageView;

@end

@implementation MMOverlayController


#pragma mark - view lifecycle

- (void)loadView
{
    [super loadView]; // load main view
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = [UIColor clearColor];

    self.underlyingImageView = [self prepareRootView:[UIImageView class]];

    self.contentView = [self prepareRootView:[UIView class]];
    self.contentView.hidden = YES;
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (id)prepareRootView:(Class)viewClass
{
    UIView *view = [viewClass autoLayoutView];
    [self.view addSubview:view];
    [view addConstraintsToFillSuperview];

    return view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureBlur];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.underlyingImageView.image = self.underlyingImage;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self performTransition:YES
                   animated:YES
                 completion:nil];

    [super viewDidAppear:animated];
}

- (void)configureBlur
{
    UIColor *blurTintColor = [UIColor colorWithWhite:0
                                               alpha:0.3];
    self.blurredUnderlyingImage = [self.underlyingImage applyBlurWithRadius:8.0
                                                                  tintColor:blurTintColor
                                                      saturationDeltaFactor:1.0
                                                                  maskImage:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - present and dismiss

- (void)dismiss
{
    typeof(self) __weak weakSelf = self;
    void (^completion)(BOOL) = ^(BOOL finished) {
        [weakSelf.presentingViewController dismissViewControllerAnimated:NO
                                                              completion:weakSelf.onDismissed];
    };
    [self performTransition:NO
                   animated:YES
                 completion:completion];
}

@end

@implementation MMOverlayController (SubclassHooks)

- (void)performTransition:(BOOL)entering
                 animated:(BOOL)animated
               completion:(void (^)(BOOL))completion
{
    typeof(self) __weak weakSelf = self;
    void (^blurAnimations)() = ^{
        [weakSelf blurTransition:entering];
    };
    void (^blurCompletion)(BOOL) = ^(BOOL finished) {
        [weakSelf finishBlurTransition:entering];
    };
    void (^contentAnimations)() = ^{
        [weakSelf contentTransition:entering];
    };
    void (^contentCompletion)(BOOL) = ^(BOOL finished) {
        [weakSelf finishContentTransition:entering];
        if (completion) {
            completion(finished);
        }
    };

    [self prepareForBlurTransition:entering];
    [self prepareForContentTransition:entering];
    if (animated) {
        [UIView transitionWithView:self.underlyingImageView
                          duration:entering ? kEntranceAnimationDuration : kExitAnimationDuration
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:blurAnimations
                        completion:blurCompletion];
        [UIView animateWithDuration:entering ? kEntranceAnimationDuration : kExitAnimationDuration
                              delay:entering ? kEntranceAnimationContentDelay : kExitAnimationContentDelay
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:contentAnimations
                         completion:contentCompletion];
    } else {
        blurAnimations();
        blurCompletion(YES);
        contentAnimations();
        contentCompletion(YES);
    }
}

- (void)prepareForBlurTransition:(BOOL)entering;
{
    // nothing for now
}

- (void)blurTransition:(BOOL)entering
{
    self.underlyingImageView.image = entering ? self.blurredUnderlyingImage : self.underlyingImage;
}

- (void)finishBlurTransition:(BOOL)entering
{
    // nothing for now
}

- (void)prepareForContentTransition:(BOOL)entering
{
    if (entering) {
        self.contentView.alpha = 0;
        self.contentView.hidden = NO;
        self.contentView.transform = CGAffineTransformMakeTranslation(0, -30);
    }
}

- (void)contentTransition:(BOOL)entering
{
    self.contentView.alpha = entering ? 1.0 : 0.0;
    self.contentView.transform = CGAffineTransformIdentity;
}

- (void)finishContentTransition:(BOOL)entering
{
    if (!entering) {
        self.contentView.hidden = YES;
        self.contentView.transform = CGAffineTransformIdentity;
    }
}

@end
