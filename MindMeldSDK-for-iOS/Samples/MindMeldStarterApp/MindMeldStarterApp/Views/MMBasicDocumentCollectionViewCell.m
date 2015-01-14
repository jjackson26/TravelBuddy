//
//  MMBasicDocumentCollectionViewCell.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/6/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// interface
#import "MMBasicDocumentCollectionViewCell.h"

// utilities
#import "UIView+CornerRadius.h"
#import "UIView+AutoLayout.h"

static NSString *const kPlaceholderImageName = @"basic-placeholder.jpg";

static const CGFloat kInterItemMargin = 8.0;
static const CGFloat kTextMargin = 12.0;

@interface MMBasicDocumentCollectionViewCell ()

@end


@implementation MMBasicDocumentCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    // clear placeholder text from nib
    self.leftDetailLabel1.text = nil;
    self.leftDetailLabel2.text = nil;
    self.rightDetailLabel1.text = nil;
    self.rightDetailLabel2.text = nil;
}

- (void)styleCell {
    [super styleCell];
    self.imageView.topLeftCornerRadius = self.imageView.topRightCornerRadius = 3.0f;
}

#pragma mark - layout

- (UIImage *)placeholderImage
{
    UIImage *image = [UIImage imageNamed:kPlaceholderImageName];
    return image;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect bounds = self.bounds;


    // image view
    CGFloat imageHeight = round(CGRectGetWidth(bounds) / self.imageAspectRatio * [UIScreen mainScreen].scale) / [UIScreen mainScreen].scale;
    CGRect imageFrame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds),
                                   CGRectGetWidth(bounds), imageHeight);

    self.imageView.frame = imageFrame;
    self.activityIndicator.center = self.imageView.center;

    CGFloat height = CGRectGetHeight(imageFrame);
    CGFloat textWidth = CGRectGetWidth(bounds) - 2 * kTextMargin;

    self.titleLabel.preferredMaxLayoutWidth = textWidth;
    CGSize titleSize = self.titleLabel.intrinsicContentSize;
    CGRect titleFrame = CGRectMake(CGRectGetMinX(bounds) + kTextMargin,
                                   CGRectGetMaxY(imageFrame) + kInterItemMargin,
                                   textWidth,
                                   titleSize.height);
    self.titleLabel.frame = titleFrame;
    height += CGRectGetHeight(titleFrame) + kInterItemMargin;

    // description
    self.descriptionLabel.preferredMaxLayoutWidth = textWidth;
    CGSize descriptionSize = self.descriptionLabel.intrinsicContentSize;
    CGRect descriptionFrame = CGRectMake(CGRectGetMinX(bounds) + kTextMargin,
                                         CGRectGetMaxY(titleFrame) + kInterItemMargin,
                                         textWidth,
                                         descriptionSize.height);
    self.descriptionLabel.frame = descriptionFrame;
    height += CGRectGetHeight(descriptionFrame) + kInterItemMargin;

    // detail labels
    CGSize (^getDetailLabelSize)(UILabel *, CGFloat) = ^(UILabel *label, CGFloat maxWidth) {
        if (label.text.length == 0) {
            return CGSizeZero;
        }
        label.preferredMaxLayoutWidth = maxWidth;
        return label.intrinsicContentSize;
    };

    NSArray *(^getColumnSizes)(NSArray *, CGFloat) = ^(NSArray *labels, CGFloat maxWidth) {
        CGSize size1 = getDetailLabelSize(labels[0], maxWidth);
        CGSize size2 = getDetailLabelSize(labels[1], maxWidth);
        CGSize size = CGSizeMake(MAX(size1.width, size2.width),
                                 size1.height + size2.height);

        return @[ [NSValue valueWithCGSize:size1],
                  [NSValue valueWithCGSize:size2],
                  [NSValue valueWithCGSize:size] ];
    };

    // Assume the maximum width for now
    CGFloat rightColumnWidth = textWidth * 0.30;
    NSArray *rightLabels = @[ self.rightDetailLabel1, self.rightDetailLabel2 ];
    NSArray *rightColumnSizes = getColumnSizes(rightLabels, rightColumnWidth);
    CGSize rightColumnSize;
    [rightColumnSizes[2] getValue:&rightColumnSize];
    rightColumnWidth = rightColumnSize.width;

    CGFloat leftColumnWidth = textWidth;
    if (rightColumnWidth > 0) {
        leftColumnWidth -= rightColumnWidth + kInterItemMargin;
    }

    NSArray *leftLabels = @[ self.leftDetailLabel1, self.leftDetailLabel2 ];
    NSArray *leftColumnSizes = getColumnSizes(leftLabels, leftColumnWidth);
    CGSize leftColumnSize;
    [leftColumnSizes[2] getValue:&leftColumnSize];

    CGFloat detailHeight = MAX(leftColumnSize.height, rightColumnSize.height);
    height += detailHeight + kTextMargin;
    if (detailHeight != 0) {
        height += kInterItemMargin;
    }

    // apply the column sizes
    NSArray *columnLabels = @[ leftLabels, rightLabels ];
    NSArray *columnSizes  = @[ leftColumnSizes, rightColumnSizes ];
    NSArray *columnXs     = @[ @(CGRectGetMinX(bounds) + kTextMargin),
                               @(CGRectGetMaxX(bounds) - kTextMargin - rightColumnSize.width) ];

    for (NSInteger col = 0; col < columnLabels.count; col++) {
        NSArray *labels = columnLabels[col];
        NSArray *sizes = columnSizes[col];
        CGFloat x = [columnXs[col] doubleValue];

        CGSize columnSize;
        [sizes[2] getValue:&columnSize];

        CGFloat y = height - kTextMargin - columnSize.height;

        for (NSInteger row = 0; row < labels.count; row++) {
            UILabel *label = labels[row];

            CGSize size;
            [sizes[row] getValue:&size];

            CGRect frame = CGRectMake(x, y, size.width, size.height);
            label.frame = frame;
            if (CGSizeEqualToSize(size, CGSizeZero)) {
                label.hidden = YES;
            } else {
                y += size.height;
            }
        }
    }
}

- (CGFloat)imageAspectRatio
{
    // for now always use the default aspect ratio
    return 180.0f / 260.0f; // default image aspect ratio
}

- (CGSize)intrinsicContentSize
{
    [self layoutIfNeeded];

    CGRect bounds = self.bounds;

    CGSize size;
    size.width = UIViewNoIntrinsicMetric;
    size.height = CGRectGetMaxY(self.leftDetailLabel2.frame) - CGRectGetMinY(bounds) + kTextMargin;

    return size;
}


#pragma mark - set data


- (void)usePlaceholderImage
{
    self.imageView.image = self.placeholderImage;
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.activityIndicator stopAnimating];
}

- (void)setImage:(UIImage *)image
{
    if ([image isEqual:super.image]) {
        return;
    }

    if (image) {
        self.imageView.contentMode = UIViewContentModeScaleToFill;
    }

    super.image = image;
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t dateFormatterOnceToken;
    dispatch_once(&dateFormatterOnceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY";
    });
    return dateFormatter;
}

- (void)setImage:(UIImage *)image
        animated:(BOOL)animated
{
    [super setImage:image
           animated:animated];
}


/*****
 * (1)
 *  Use the document JSON to display the title description and any additional information
 *  about the document.
 *
 *  @param documentJSON
 *****/
- (void)setDocumentJSON:(id)documentJSON
{
    if ([documentJSON isEqual:self.documentJSON]) {
        return;
    }
    super.documentJSON = documentJSON;

    self.titleLabel.text = self.documentJSON[@"title"];

    NSString *description = self.documentJSON[@"description"];
    if (description && ![description isEqualToString:@"0"] && description.length > 0) {
        self.descriptionLabel.text = description;
    } else {
        self.descriptionLabel.text = @"No Description";
    }

    [self applyDetailData];
    [self setNeedsLayout];
}

/*****
 *  (2)
 *  Here you can apply your own detail label to display additional document information in the cells.
 ****/
- (void)applyDetailData
{
//    self.leftDetailLabel1.text = self.documentJSON[@"your-custom-field"];
//    self.leftDetailLabel2.text = self.documentJSON[@"your-custom-field"];
//    self.rightDetailLabel1.text = self.documentJSON[@"your-custom-field"];
//    self.rightDetailLabel2.text = self.documentJSON[@"your-custom-field"];
}

@end
