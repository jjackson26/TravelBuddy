//
//  MMDocumentCollectionViewCell.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// interface
#import "MMDocumentCollectionViewCell.h"

// utilities
#import "UIView+AutoLayout.h"

static NSString *const kBackgroundImage = @"cell-background";
static NSString *const kBorderImage = @"cell-border";

static const CGFloat kBackgroundInset = -15.0;
static const CGFloat kBorderInset = -6.0;

@implementation MMDocumentCollectionViewCell

- (void)awakeFromNib
{
    [self styleCell];
}

- (void)styleCell
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;

    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;

    if (!self.backgroundView) {
        [self  createBackground];
    }
}

- (void)renderDynamically
{
    self.layer.backgroundColor = [UIColor blackColor].CGColor;

    CGFloat cornerRadius = 3.0f;
    self.layer.cornerRadius = cornerRadius;


    self.layer.shadowOpacity = 0.75f;
    self.layer.shadowRadius = 7.5f;
    self.layer.shadowOffset = CGSizeZero;
}

- (void)createBackground
{
    UIEdgeInsets backgroundImageInsets = UIEdgeInsetsMake(29.0, 29.0, 29.0, 29.0);
    UIImage *image = [[UIImage imageNamed:kBackgroundImage] resizableImageWithCapInsets:backgroundImageInsets
                                                                           resizingMode:UIImageResizingModeStretch];

    UIImageView *imageView = [UIImageView autoLayoutView];
    imageView.image = image;
    self.backgroundView = imageView;
    [self addSubview:self.backgroundView];
    [self sendSubviewToBack:self.backgroundView];

    UIEdgeInsets borderImageInsets = UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0);
    image = [[UIImage imageNamed:kBorderImage] resizableImageWithCapInsets:borderImageInsets
                                                                           resizingMode:UIImageResizingModeStretch];
    imageView = [UIImageView autoLayoutView];
    imageView.image = image;
    self.borderView = imageView;
    self.borderView.userInteractionEnabled = NO;
    [self addSubview:self.borderView];
}


#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect bounds = self.bounds;

    CGRect backgroundFrame = CGRectInset(bounds, kBackgroundInset, kBackgroundInset);
    self.backgroundView.frame = backgroundFrame;

    CGRect borderFrame = CGRectInset(bounds, kBorderInset, kBorderInset);
    self.borderView.frame = borderFrame;
}


#pragma mark - properties

- (void)setImage:(UIImage *)image
{
    if ([image isEqual:_image]) {
        return;
    }

    [self.activityIndicator stopAnimating];
    _image = image;
    self.imageView.image = image;
}

- (void)setImage:(UIImage *)image
        animated:(BOOL)animated
{
    void (^animations)() = ^{
        self.image = image;
    };
    if (animated) {
        [UIView transitionWithView:self.imageView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:animations
                        completion:nil];
    } else {
        animations();
    }
}

- (void)setDocumentJSON:(id)documentJSON
{
    if ([documentJSON isEqual:self.documentJSON]) {
        return;
    }

    _documentJSON = documentJSON;
}

- (void)usePlaceholderImage
{
    self.imageView.image = self.placeholderImage;
    [self.activityIndicator stopAnimating];
}

- (UIImage *)placeholderImage
{
    // subclass this
    return nil;
}

- (void)showImagePending
{
    [self.activityIndicator startAnimating];
}

@end
