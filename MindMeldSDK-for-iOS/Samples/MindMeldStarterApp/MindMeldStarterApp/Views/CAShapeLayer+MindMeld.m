//
//  CAShapeLayer+MindMeld.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/18/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

// interface
#import "CAShapeLayer+MindMeld.h"


static const CGFloat kLineWidth = 2.0f;
static const CGFloat kShadowRadius = 3.0f;

@implementation CAShapeLayer (MindMeld)

+ (void)styleLayerForMindMeldGlow:(CAShapeLayer *)layer
{
    layer.shadowOpacity = 1.0f;
    layer.shadowRadius = kShadowRadius;
    layer.shadowOffset = CGSizeZero;

    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = kLineWidth;
}

@end
