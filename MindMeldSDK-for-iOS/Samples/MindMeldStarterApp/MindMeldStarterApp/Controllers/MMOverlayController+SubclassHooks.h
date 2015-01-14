//
//  MMOverlayController+SubclassHooks.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "MMOverlayController.h"

@interface MMOverlayController (SubclassHooks)

@property (nonatomic, strong) UIImageView *underlyingImageView;

- (void)performTransition:(BOOL)entering
                 animated:(BOOL)animated
               completion:(void (^)(BOOL))completion;

- (void)prepareForBlurTransition:(BOOL)entering;
- (void)blurTransition:(BOOL)entering;
- (void)finishBlurTransition:(BOOL)entering;

- (void)prepareForContentTransition:(BOOL)entering;
- (void)contentTransition:(BOOL)entering;
- (void)finishContentTransition:(BOOL)entering;

@end
