//
//  MMBrowserView.m
//  MindMeld Browser
//
//  Created by Juan Rodriguez on 2/27/14.
//  Copyright (c) 2014 Regio Systems. All rights reserved.
//

#import "MMBrowserView.h"

static const CGFloat kHeaderHeight = 80;

@implementation MMBrowserView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        // Add a header view
        UIView *hv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kHeaderHeight)];
        hv.backgroundColor = [UIColor whiteColor];
        [self addSubview:hv];
        self.headerView = hv;
        
        // Add a label with the title
        UILabel *tl = [[UILabel alloc] initWithFrame:CGRectMake(0, kHeaderHeight * 0.25 , frame.size.width, kHeaderHeight * 0.75)];
        tl.textAlignment = NSTextAlignmentCenter;
        tl.font = [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:22];
        tl.text = @"MindMeld Browser";
        [self.headerView addSubview:tl];
        
        // Add the browser scroll view
        CGFloat y = CGRectGetMaxY(self.headerView.frame);
        MMBrowserScrollView *browserScrollView = [[MMBrowserScrollView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, frame.size.height - y + 20)];
        [self addSubview:browserScrollView];
        self.browserScrollView = browserScrollView;
    }
    return self;
}

@end
