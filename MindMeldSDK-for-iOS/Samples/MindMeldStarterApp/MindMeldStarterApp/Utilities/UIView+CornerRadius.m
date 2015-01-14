//
//  UIView+CornerRadius.m
//  JMJUtilities
//
//  Created by J.J. Jackson on 2/27/13.
//

#import "UIView+CornerRadius.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

static char kKeyCornerRadiusTopLeft;
static char kKeyCornerRadiusTopRight;
static char kKeyCornerRadiusBottomLeft;
static char kKeyCornerRadiusBottomRight;

struct JMJCornerRadii
{
  CGFloat topLeft;
  CGFloat topRight;
  CGFloat bottomLeft;
  CGFloat bottomRight;
};

@implementation UIView (CornerRadius)

#pragma mark - Variable Corner Radius

static CGPathRef variableCornerRadiusRoundedRectPath(CGRect rect, struct JMJCornerRadii cornerRadii) {
  CGMutablePathRef path = CGPathCreateMutable();
  // move to top left
  CGPathMoveToPoint(path, NULL,
                    rect.origin.x,
                    rect.origin.y + cornerRadii.topLeft);
  // draw left side
  CGPathAddLineToPoint(path, NULL,
                       rect.origin.x,
                       rect.origin.y + rect.size.height - cornerRadii.bottomLeft);
  if (cornerRadii.bottomLeft > 0)
  { // draw bottom left corner
    CGPathAddArcToPoint(path, NULL,
                        rect.origin.x, rect.origin.y + rect.size.height, // bottom left corner
                        rect.origin.x + cornerRadii.bottomLeft, rect.origin.y + rect.size.height,
                        cornerRadii.bottomLeft);
  }
  // draw bottom side
  CGPathAddLineToPoint(path, NULL,
                       rect.origin.x + rect.size.width - cornerRadii.bottomRight,
                       rect.origin.y + rect.size.height);
  if (cornerRadii.bottomRight > 0)
  { // draw bottom right corner
    CGPathAddArcToPoint(path, NULL,
                        rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, // bottom right corner
                        rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerRadii.bottomRight,
                        cornerRadii.bottomRight);
  }
  // draw right side
  CGPathAddLineToPoint(path, NULL,
                       rect.origin.x + rect.size.width,
                       rect.origin.y + cornerRadii.topRight);
  if (cornerRadii.topRight > 0)
  { // draw top right corner
    CGPathAddArcToPoint(path, NULL,
                        rect.origin.x + rect.size.width, rect.origin.y, // top right corner
                        rect.origin.x + rect.size.width - cornerRadii.topRight, rect.origin.y,
                        cornerRadii.topRight);
  }
  // draw top side
  CGPathAddLineToPoint(path, NULL,
                       rect.origin.x + cornerRadii.topLeft,
                       rect.origin.y);
  if (cornerRadii.topLeft > 0)
  { // draw top left corner
    CGPathAddArcToPoint(path, NULL,
                        rect.origin.x, rect.origin.y, // top left corner, aka origin
                        rect.origin.x, rect.origin.y + cornerRadii.topLeft,
                        cornerRadii.topLeft);
  }

  return path;
}

- (void)updateRoundedCornerLayerMask
{
  CGPathRef path = variableCornerRadiusRoundedRectPath(self.bounds, [self cornerRadii]);
  UIBezierPath *maskPath = [UIBezierPath bezierPathWithCGPath:path];
  CGPathRelease(path);

  // Create the shape layer and set its path
  CAShapeLayer *maskLayer = [CAShapeLayer layer];
  maskLayer.frame = self.bounds;
  maskLayer.path = maskPath.CGPath;
  self.layer.mask = maskLayer;
  [self setNeedsDisplay];
}

- (struct JMJCornerRadii)cornerRadii
{
  struct JMJCornerRadii theRadii;
  theRadii.topLeft     = self.topLeftCornerRadius;
  theRadii.topRight    = self.topRightCornerRadius;
  theRadii.bottomLeft  = self.bottomLeftCornerRadius;
  theRadii.bottomRight = self.bottomRightCornerRadius;

  return theRadii;
}

#pragma mark - Properties

- (CGFloat)cornerRadius
{
  struct JMJCornerRadii theRadii = [self cornerRadii];
  if ((theRadii.topLeft == theRadii.topRight) &&
      (theRadii.topLeft == theRadii.bottomLeft) &&
      (theRadii.topLeft == theRadii.bottomRight))
  {
    return theRadii.topLeft;
  }
  return -1.0;
}

- (void)setCornerRadius:(CGFloat)value
{
  if (value != self.cornerRadius)
  {
    NSNumber *number = [NSNumber numberWithFloat:value];
    objc_setAssociatedObject(self, &kKeyCornerRadiusTopLeft, [number copy], OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, &kKeyCornerRadiusTopRight, [number copy], OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, &kKeyCornerRadiusBottomLeft, [number copy], OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, &kKeyCornerRadiusBottomRight, number, OBJC_ASSOCIATION_RETAIN);
    [self updateRoundedCornerLayerMask];
  }
}

- (CGFloat)topLeftCornerRadius
{
  NSNumber *number = objc_getAssociatedObject(self, &kKeyCornerRadiusTopLeft);
  return number ? [number floatValue] : 0.0;
}

- (void)setTopLeftCornerRadius:(CGFloat)value
{
  if (value != self.topLeftCornerRadius)
  {
    NSNumber *number = [NSNumber numberWithFloat:value];
    objc_setAssociatedObject(self, &kKeyCornerRadiusTopLeft, number, OBJC_ASSOCIATION_RETAIN);
    [self updateRoundedCornerLayerMask];
  }
}

- (CGFloat)topRightCornerRadius
{
  NSNumber *number = objc_getAssociatedObject(self, &kKeyCornerRadiusTopRight);
  return number ? [number floatValue] : 0.0;
}

- (void)setTopRightCornerRadius:(CGFloat)value
{
  if (value != self.topRightCornerRadius)
  {
    NSNumber *number = [NSNumber numberWithFloat:value];
    objc_setAssociatedObject(self, &kKeyCornerRadiusTopRight, number, OBJC_ASSOCIATION_RETAIN);
    [self updateRoundedCornerLayerMask];
  }
}

- (CGFloat)bottomLeftCornerRadius
{
  NSNumber *number = objc_getAssociatedObject(self, &kKeyCornerRadiusBottomLeft);
  return number ? [number floatValue] : 0.0;
}

- (void)setBottomLeftCornerRadius:(CGFloat)value
{
  if (value != self.bottomLeftCornerRadius)
  {
    NSNumber *number = [NSNumber numberWithFloat:value];
    objc_setAssociatedObject(self, &kKeyCornerRadiusBottomLeft, number, OBJC_ASSOCIATION_RETAIN);
    [self updateRoundedCornerLayerMask];
  }
}

- (CGFloat)bottomRightCornerRadius
{
  NSNumber *number = objc_getAssociatedObject(self, &kKeyCornerRadiusBottomRight);
  return number ? [number floatValue] : 0.0;
}

- (void)setBottomRightCornerRadius:(CGFloat)value
{
  if (value != self.bottomRightCornerRadius)
  {
    NSNumber *number = [NSNumber numberWithFloat:value];
    objc_setAssociatedObject(self, &kKeyCornerRadiusBottomRight, number, OBJC_ASSOCIATION_RETAIN);
    [self updateRoundedCornerLayerMask];
  }
}

@end
