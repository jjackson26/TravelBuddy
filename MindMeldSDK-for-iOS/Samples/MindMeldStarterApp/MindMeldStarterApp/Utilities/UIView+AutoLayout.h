//
//  UIView+AutoLayout.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoLayout)

+ (instancetype)autoLayoutView;

+ (void)addConstraintsForVisualFormats:(NSArray *)visualFormats
                                 views:(NSDictionary *)views;

+ (void)addConstraintsForVisualFormats:(NSArray *)visualFormats
                                 views:(NSDictionary *)views
                               metrics:(NSDictionary *)metrics;

+ (void)addConstraintsForVisualFormats:(NSArray *)visualFormats
                                 views:(NSDictionary *)views
                               metrics:(NSDictionary *)metrics
                               options:(NSArray *)options;

+ (void)addConstraintsForVisualFormats:(NSArray *)visualFormats
                                 views:(NSDictionary *)views
                               metrics:(NSDictionary *)metrics
                               options:(NSArray *)options
                             superview:(UIView *)superview;

- (void)addConstraintsToFillSuperview;
- (void)addConstraintsToFillSuperviewWithInsets:(UIEdgeInsets)insets;

- (void)addConstraintsToCenterInSuperview;
- (void)addConstraintsToCenterInSuperviewWithOffset:(CGPoint)offset;

- (void)addConstraintToCenterHorizontallyInSuperview;
- (void)addConstraintToCenterHorizontallyInSuperviewWithOffset:(CGFloat)offset;

- (void)addConstraintToCenterVerticallyInSuperview;
- (void)addConstraintToCenterVerticallyInSuperviewWithOffset:(CGFloat)offset;

- (void)addConstraintsToMatchView:(UIView *)other;
- (void)addConstraintsToMatchView:(UIView *)other
                       withInsets:(UIEdgeInsets)insets;


/**
 *  @param aspectRatio The ratio of view's constrained width to height
 */
- (void)addConstraintForAspectRatio:(CGFloat)aspectRatio;


@end
