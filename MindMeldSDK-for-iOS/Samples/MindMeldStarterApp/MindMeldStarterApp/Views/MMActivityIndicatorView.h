//
//  MMActivityIndicatorView.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/13/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This activity indicator displays a ring with sine oscillations over a circular background.
 */
@interface MMActivityIndicatorView : UIView

@property (nonatomic, assign, readonly, getter=isAnimating) BOOL animating;

/**
 *  The activity indicator's background color.
 */
@property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

/**
 *  The main color of the activity indicator.
 */
@property (nonatomic, strong) UIColor *strokeColor UI_APPEARANCE_SELECTOR;

/**
 *  The color of the activity indicator's glow.
 */
@property (nonatomic, strong) UIColor *glowColor UI_APPEARANCE_SELECTOR;


- (void)startAnimating;
- (void)stopAnimating;
- (void)cancelAnimation;

@end
