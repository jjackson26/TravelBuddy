//
//  MMDocumentCollectionViewCell.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMDocumentCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) id documentJSON;

- (void)styleCell;

- (UIImage *)placeholderImage;

- (void)setImage:(UIImage *)image
        animated:(BOOL)animated;

- (void)usePlaceholderImage;

- (void)showImagePending;

@end
