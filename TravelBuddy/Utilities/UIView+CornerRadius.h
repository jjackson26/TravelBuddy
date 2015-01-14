//
//  UIView+CornerRadius.h
//  JMJUtilities
//
//  Created by J.J. Jackson on 2/27/13.
//

#import <UIKit/UIKit.h>

@interface UIView (CornerRadius)

/**
 * A corner radius used to round the corners. Setting this removes any corner specific radii.
 * If specific radii are set, this will return -1.0.
 */
@property (assign,nonatomic) CGFloat cornerRadius;

/**
 * A corner radius used to round the top left corner.
 */
@property (assign,nonatomic) CGFloat topLeftCornerRadius;

/**
 * A corner radius used to round the top right corner
 */
@property (assign,nonatomic) CGFloat topRightCornerRadius;

/**
 * A corner radius used to round the bottom left corner
 */
@property (assign,nonatomic) CGFloat bottomLeftCornerRadius;

/**
 * A corner radius used to round the bottom right corner
 */
@property (assign,nonatomic) CGFloat bottomRightCornerRadius;

@end
