//
//  MMActivityIndicatorView.m
//  MindMeldVoice
//
//  Created by J.J. Jackson on 3/1/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "MMActivityIndicatorView.h"

static const NSTimeInterval kFadeDuration = 0.5;

@interface MMActivityIndicatorView ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation MMActivityIndicatorView

+ (UIColor *)defaultBackgroundColor {
    return [[UIColor darkGrayColor] colorWithAlphaComponent:0.75];
}

#pragma mark - lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self initialize];
    }

    return self;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        [self initialize];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self initialize];
    }

    return self;
}

- (void)initialize {
    self.backgroundColor = [self class].defaultBackgroundColor;
    self.alpha = 0;

    self.activityIndicatorView = ({
        UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhiteLarge;
        UIActivityIndicatorView *aiView;
        aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        aiView.center = CGPointMake(self.bounds.size.width / 2,
                                    self.bounds.size.height / 2);
        [self addSubview:aiView];
        aiView;
    });
}

- (void)layoutSubviews {
    self.activityIndicatorView.center = CGPointMake(self.bounds.size.width / 2,
                                                    self.bounds.size.height / 2);
}

#pragma mark - show / hide

- (void)showInView:(UIView *)view
          animated:(BOOL)animated {
    [self.activityIndicatorView startAnimating];

    if (animated) {
        self.alpha = 0;
    }

    [view addSubview:self];
    [view bringSubviewToFront:self];

    if (animated) {
        typeof(self) __weak weakSelf = self;
        void (^animations)(void) = ^{
            weakSelf.alpha = 1;
        };

        [UIView animateWithDuration:kFadeDuration
                         animations:animations];
    }
}

- (void)hide:(BOOL)animated {
    [self.activityIndicatorView stopAnimating];

    typeof(self) __weak weakSelf = self;
    void (^animations)(void) = ^{
        weakSelf.alpha = 0;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        [weakSelf removeFromSuperview];
    };
    [UIView animateWithDuration:kFadeDuration
                     animations:animations
                     completion:completion];
}

@end
