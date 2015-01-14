//
//  MMessageView.m
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMMessageView.h"

static const CGFloat kOuterPadding = 16;
static const CGFloat kTextPadding = 2;
static const CGFloat kMaxWidth = 200;
static const CGFloat kCornerRadius = 5;

@implementation MMMessageView

// Here we just start this view, and all the subviews contained inside.
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = self.backgroundColor = [UIColor grayColor];
        self.layer.cornerRadius = kCornerRadius;
        
        // Create the text view
        CGRect rect = CGRectMake(kTextPadding, kTextPadding, frame.size.width - 2 * kTextPadding, frame.size.height - 2 * kTextPadding);
        UITextView *textView = [[UITextView alloc] initWithFrame:rect];
        textView.backgroundColor = [UIColor clearColor];
        textView.userInteractionEnabled = NO;
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        [self addSubview:textView];
        self.textView = textView;
        
    }
    return self;
}

// This method is used to update the subviews with the right information coming from a
// dictionary.
- (void)updateWithDict:(NSDictionary *)dict {
    // Set the dict
    self.json = dict;
    
    // Add the text
    self.textView.text = dict[@"text"];
}

// This method is necessary to dynamically calculate the size of this message.
// Note that the size is based on the amount of text.
+ (CGSize)calculateSizeForText:(NSString *)text {
    CGSize size = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16] constrainedToSize:CGSizeMake(kMaxWidth, 20000)];
    CGSize finalSize = CGSizeMake(size.width + 2 * kTextPadding + kOuterPadding, size.height + 2 * kTextPadding + kOuterPadding);
    return finalSize;
}

@end
