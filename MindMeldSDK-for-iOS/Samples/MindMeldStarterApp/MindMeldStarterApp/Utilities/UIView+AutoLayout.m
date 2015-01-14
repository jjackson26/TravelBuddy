//
//  UIView+AutoLayout.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)

+ (instancetype)autoLayoutView {
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

+ (void)addConstraintsForVisualFormats:(NSArray *)visualFormats
                                 views:(NSDictionary *)views {
    [self addConstraintsForVisualFormats:visualFormats
                                   views:views
                                 metrics:nil];
}

+ (void)addConstraintsForVisualFormats:(NSArray *)visualFormats
                                 views:(NSDictionary *)views
                               metrics:(NSDictionary *)metrics {
    [self addConstraintsForVisualFormats:visualFormats
                                   views:views
                                 metrics:metrics
                                 options:nil];
}

+ (void)addConstraintsForVisualFormats:(NSArray *)visualFormats
                                 views:(NSDictionary *)views
                               metrics:(NSDictionary *)metrics
                               options:(NSArray *)options {
    [self addConstraintsForVisualFormats:visualFormats
                                   views:views
                                 metrics:metrics
                                 options:options
                               superview:nil];
}

+ (void)addConstraintsForVisualFormats:(NSArray *)visualFormats
                                 views:(NSDictionary *)views
                               metrics:(NSDictionary *)metrics
                               options:(NSArray *)allOptions
                             superview:(UIView *)superview {
    if (!superview) {
        NSString *key = views.allKeys.lastObject;
        UIView *view = views[key];
        superview = view.superview;
    }


    NSMutableArray *allConstraints = [NSMutableArray array];
    for (NSInteger i = 0; i < visualFormats.count; i++) {
        NSString *visualFormat = visualFormats[i];

        // get options if any
        NSLayoutFormatOptions options = 0;
        if (allOptions.count > i) {
            options = [allOptions[i] unsignedIntegerValue];
        }

        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                       options:options
                                                                       metrics:metrics
                                                                         views:views];
        [allConstraints addObjectsFromArray:constraints];
    }
    [superview addConstraints:allConstraints];
}


#pragma mark - Instance methods

- (void)addConstraintsToFillSuperview
{
    [self addConstraintsToFillSuperviewWithInsets:UIEdgeInsetsZero];
}

- (void)addConstraintsToFillSuperviewWithInsets:(UIEdgeInsets)insets
{
    if (!self.superview) {
        return;
    }

    NSDictionary *views = @{ @"view": self };
    NSDictionary *metrics = @{ @"top": @(insets.top),
                               @"left": @(insets.left),
                               @"bottom": @(insets.bottom),
                               @"right": @(insets.right) };
    NSArray *visualFormats = @[ @"H:|-(left)-[view]-(right)-|",
                                @"V:|-(top)-[view]-(bottom)-|" ];

    [UIView addConstraintsForVisualFormats:visualFormats
                                     views:views
                                   metrics:metrics];
}

- (void)addConstraintsToCenterInSuperview
{
    [self addConstraintsToCenterInSuperviewWithOffset:CGPointZero];
}

- (void)addConstraintsToCenterInSuperviewWithOffset:(CGPoint)offset
{
    if (!self.superview) {
        return;
    }

    [self addConstraintToCenterHorizontallyInSuperviewWithOffset:offset.x];
    [self addConstraintToCenterVerticallyInSuperviewWithOffset:offset.y];
}

- (void)addConstraintToCenterHorizontallyInSuperview;
{
    [self addConstraintToCenterHorizontallyInSuperviewWithOffset:0.0];
}

- (void)addConstraintToCenterHorizontallyInSuperviewWithOffset:(CGFloat)offset;
{
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:offset]];
}

- (void)addConstraintToCenterVerticallyInSuperview;
{
    [self addConstraintToCenterVerticallyInSuperviewWithOffset:0.0];
}

- (void)addConstraintToCenterVerticallyInSuperviewWithOffset:(CGFloat)offset;
{
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:offset]];
}

- (void)addConstraintsToMatchView:(UIView *)other
{
    [self addConstraintsToMatchView:other
                         withInsets:UIEdgeInsetsZero];
}

- (void)addConstraintsToMatchView:(UIView *)other
                       withInsets:(UIEdgeInsets)insets
{
    if (!other) {
        return;
    }

    UIView *superview = self.superview;

    NSMutableArray *constraints = [NSMutableArray array];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:other
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1
                                                         constant:insets.top]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:other
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1
                                                         constant:insets.left]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:other
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:insets.bottom]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:other
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1
                                                         constant:insets.right]];

    [superview addConstraints:constraints];
}

- (void)addConstraintForAspectRatio:(CGFloat)aspectRatio {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:aspectRatio
                                                      constant:0]];
}


@end
