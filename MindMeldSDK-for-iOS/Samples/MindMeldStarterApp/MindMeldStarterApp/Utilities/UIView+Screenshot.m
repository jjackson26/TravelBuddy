//
//  UIView+Screenshot.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)

- (UIImage *)screenshotWithShadow
{
    CGFloat radius = self.layer.shadowRadius;

    CGRect rect = CGRectMake(0, 0,
                             CGRectGetWidth(self.bounds) + (4.0 * radius),
                             CGRectGetHeight(self.bounds) + (4.0 * radius));

    UIView *originalSuperview = self.superview;
    CGPoint originalCenter = self.center;

    NSUInteger positionInSuperview = -1;
    if (originalSuperview) {
        positionInSuperview = [originalSuperview.subviews indexOfObject:self];
    }

    UIView *tempView = [[UIView alloc] initWithFrame:rect];
    tempView.translatesAutoresizingMaskIntoConstraints = NO;
    [tempView addSubview:self];

    self.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));

    UIImage *image = [tempView screenshotInRect:tempView.bounds
                                         opaque:NO];

    if (originalSuperview) {
        [originalSuperview insertSubview:self
                                 atIndex:positionInSuperview];
    }

    self.center = originalCenter;

    return image;
}

- (UIImage *)screenshot {
    return [self screenshotInRect:self.bounds
                           opaque:YES];
}

- (UIImage *)screenshotInRect:(CGRect)rect
                       opaque:(BOOL)opaque
{
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, [UIScreen mainScreen].scale);

    [self drawViewHierarchyInRect:rect
               afterScreenUpdates:YES];

    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return screenshot;
}

@end
