//
//  MMDocument.m
//  MindMeld IM
//
//  Created by Juan on 2/20/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMDocumentView.h"

static const CGSize kDocumentSize = { 300, 200 };
static const CGFloat kTitleHeight = 65;
static const CGFloat kTitlePadding = 4;
static const CGFloat kCornerRadius = 5;

@implementation MMDocumentView

// Here we just start this view, and all the subviews contained inside.
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = self.backgroundColor = [UIColor grayColor];
        self.layer.cornerRadius = kCornerRadius;
        
        // Create the title view
        CGRect rect = CGRectMake(kTitlePadding, kTitlePadding,
                                 frame.size.width - 2 * kTitlePadding, kTitleHeight);
        UITextView *titleView = [[UITextView alloc] initWithFrame:rect];
        titleView.userInteractionEnabled = NO;
        titleView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
        titleView.layer.cornerRadius = kCornerRadius;
        titleView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        [self addSubview:titleView];
        self.titleView = titleView;
        
        // Create the text view
        rect = CGRectMake(kTitlePadding, CGRectGetMaxY(self.titleView.frame) + kTitlePadding,
                          frame.size.width - 2 * kTitlePadding, frame.size.height - kTitleHeight - 3 * kTitlePadding);
        UITextView *textView = [[UITextView alloc] initWithFrame:rect];
        textView.userInteractionEnabled = NO;
        textView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
        textView.layer.cornerRadius = kCornerRadius;
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        [self addSubview:textView];
        self.textView = textView;
        
    }
    return self;
}

// This method is used to update the subviews with the right information coming from a
// dictionary.
- (void)updateWithDict:(NSDictionary *)dict {
    // Add the title
    self.titleView.text = dict[@"title"];
    
    // Add the text
    self.titleView.text = dict[@"description"];
}

// This method is necesary to dinamically calculte the size of this view.
+ (CGSize)calculateSize {
    return kDocumentSize;
}

@end
