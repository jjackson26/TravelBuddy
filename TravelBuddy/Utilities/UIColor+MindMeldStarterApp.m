//
//  UIColor+MindMeldStarterApp.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/18/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "UIColor+MindMeldStarterApp.h"

@implementation UIColor (MindMeldStarterApp)

+ (instancetype)mindMeldLightGrayColor
{
    return [UIColor colorWithRed:0.8 green:0.8157 blue:0.8314 alpha:1.0];
}

+ (instancetype)mindMeldDarkGrayColor
{
    return [UIColor colorWithRed:0.184 green:0.188 blue:0.196 alpha:1.000];
}

+ (instancetype)mindMeldBlueColor
{
    return [UIColor colorWithRed:0.078 green:0.336 blue:0.546 alpha:1.000];
}

+ (instancetype)mindMeldDarkBlueColor
{
    return [UIColor colorWithRed:0.048 green:0.177 blue:0.278 alpha:1.000];
}

@end
