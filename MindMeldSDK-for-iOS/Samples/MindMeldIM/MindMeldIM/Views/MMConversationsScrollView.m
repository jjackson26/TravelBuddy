//
//  MMConversationsScrollView.m
//  MindMeld IM
//
//  Created by Juan Rodriguez on 2/24/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMConversationsScrollView.h"

static const CGFloat kSessionVerticalPadding = 10;

@interface MMConversationsScrollView ()

@property (nonatomic, strong) NSMutableArray *sessionViews;

@end

@implementation MMConversationsScrollView

// Here we just start this view, and all the subviews contained inside.
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];

        _sessionViews = [NSMutableArray array];
    }
    return self;
}

// This scroll view is responsible for updating it's subviews. In particular, it needs to
// update the sessions it displays. This is the method that takes an array of sessions
// and creates a view for each one of them.
- (void)updateWithSessions:(NSArray *)sessions {
    // First remove all the documents
    [self.sessionViews removeAllObjects];
    
    // Now create a view for each document
    for (NSDictionary *nextSession in sessions) {
        CGSize size = [MMSessionView calculateSize];
        MMSessionView *sessionView = [[MMSessionView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        sessionView.sessionViewDelegate = self.sessionViewDelegate;
        [sessionView updateWithDict:nextSession];
        [self.sessionViews addObject:sessionView];
    }
    
    // Now arrange the messages
    [self arrangeSessions];
}

// This methods takes all the views inside the scroll view and arranges them by order.
- (void)arrangeSessions {
    NSInteger index = 0;
    for (MMSessionView *sessionView in self.sessionViews) {
        CGRect frame = sessionView.frame;
        CGFloat x = (self.frame.size.width - frame.size.width) / 2;
        CGFloat y = kSessionVerticalPadding + (kSessionVerticalPadding + sessionView.frame.size.height) * index;
        CGPoint origin = CGPointMake(x, y);
        frame.origin = origin;
        sessionView.frame = frame;
        [self addSubview:sessionView];
        
        index++;
    }
    
    // Set the content size of the scroll
    CGFloat itemHeight = [self.sessionViews.firstObject frame].size.height;
    CGFloat totalHeight = kSessionVerticalPadding + (kSessionVerticalPadding + itemHeight) * index;
    self.contentSize = CGSizeMake(self.frame.size.width, totalHeight);
}

@end
