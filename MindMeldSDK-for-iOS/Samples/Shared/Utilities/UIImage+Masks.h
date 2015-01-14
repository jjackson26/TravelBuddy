//
//  UIImage+Masks.h
//  MindMeldVoice
//
//  Created by J.J. Jackson on 18/09/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Masks)

+ (UIImage *)imageOfColor:(UIColor *)color
                     size:(CGSize)size;

+ (UIImage *)maskFromImage:(UIImage *)sourceImage;

+ (UIImage *)maskImage:(UIImage *)image
              withMask:(UIImage *)maskImage;

+ (UIImage *)colorizeImage:(UIImage *)sourceImage
                     color:(UIColor *)color;

@end
