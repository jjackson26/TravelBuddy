//
//  MMConversationScrollView.m
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMConversationScrollView.h"

@implementation MMConversationScrollView

// Here we just start this view, and all the subviews contained inside.
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        // Set the the scroll view properties
        self.contentSize = CGSizeMake(frame.size.width * 2, frame.size.height);
        self.showsHorizontalScrollIndicator = self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        
        // Add the Messages view
        CGRect messagingViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        MMMessagingView *messagingView = [[MMMessagingView alloc] initWithFrame:messagingViewFrame];
        [self addSubview:messagingView];
        self.messagingView = messagingView;
        
        // Add the Documents view
        CGRect documentsViewFrame = CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height);
        MMDocumentsScrollView *documentsScrollView = [[MMDocumentsScrollView alloc] initWithFrame:documentsViewFrame];
        [self addSubview:documentsScrollView];
        self.documentsScrollView = documentsScrollView;
    }
    return self;
}

@end
