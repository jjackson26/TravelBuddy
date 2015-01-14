//
//  UIView+Screenshot.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Screenshot)

- (UIImage *)screenshot;
- (UIImage *)screenshotWithShadow;
- (UIImage *)screenshotInRect:(CGRect)rect
                       opaque:(BOOL)opaque;

@end
