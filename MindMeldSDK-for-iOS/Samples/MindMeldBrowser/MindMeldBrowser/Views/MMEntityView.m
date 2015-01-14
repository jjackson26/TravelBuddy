//
//  MMEntityView.m
//  MindMeld IM
//
//  Created by Juan Rodriguez on 2/24/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMEntityView.h"

static const CGSize kEntitySize = { 280, 60 };
static const CGFloat kPadding = 2;
static const CGFloat kCornerRadius = 5;

@implementation MMEntityView

@synthesize json = _json;
@synthesize textView = _textView;

// Here we just start this view, and all the subviews contained inside.
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        self.layer.cornerRadius = kCornerRadius;
        
        // Create the name view
        CGRect r = CGRectMake(kPadding, kPadding, frame.size.width - 2 * kPadding, frame.size.height - 2 * kPadding);
        UILabel *tv = [[UILabel alloc] initWithFrame:r];
        tv.layer.cornerRadius = 5;
        tv.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
        tv.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:22];
        [self addSubview:tv];
        self.textView = tv;
    }
    return self;
}

// This method is used to update the subviews with the right information coming from a
// dictionary.
- (void)updateWithDict:(NSDictionary *)dict {
    // Set the json dictionary
    self.json = dict;
    
    // Set the name of the entity
    self.textView.text = dict[@"text"];
}

// This method is necesary to dynamically calculte the size of this message.
+ (CGSize)calculateSize {
    return kEntitySize;
}

@end
