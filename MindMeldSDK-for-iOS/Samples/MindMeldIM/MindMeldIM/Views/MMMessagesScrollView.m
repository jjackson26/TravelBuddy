//
//  MMMessagesScrollView.m
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMMessagesScrollView.h"

static const CGFloat kMessageHorizontalPadding = 15;
static const CGFloat kMessageVerticalPadding = 5;

@implementation MMMessagesScrollView

// Here we just start this view, and all the subviews contained inside.
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialize the properties
        NSMutableDictionary *viewsDict = [NSMutableDictionary dictionary];
        self.viewsDictionary = viewsDict;
        
        NSMutableArray *messages = [NSMutableArray array];
        self.messageViews = messages;
    }
    return self;
}

// This scroll view is responsible for updating it's subviews. In particular, it needs to
// update the messages it displays. This is the method that takes an array of messages
// (text entries) and creates a view for each one of them.
- (void)updateWithMessages:(NSArray *)messages {
    
    // Find the new messages
    NSMutableArray *newMessages = [NSMutableArray array];
    for (NSDictionary *message in messages) {
        NSString *messageid = message[@"textentryid"];
        if (!(self.viewsDictionary)[messageid]) {
            [newMessages addObject:message];
        }
    }
    
    // Now add the new views
    [self addNewMessages:newMessages];
    
    // Now arrange the messages
    [self arrangeMessages];
    
    // Scroll to bottom
    [self scrollToBottom];
}

// This method adds the new messages that have been retrieved from the server.
// We add the new messages in this separate method so that we only have to create
// new messages, but also so we can use animations if we want when showing them.
- (void)addNewMessages:(NSMutableArray *)newMessages {
    for (NSInteger i = [newMessages count] - 1; i < [newMessages count]; i--) {
        NSDictionary *newMessage = newMessages[i];
        NSString *messageid = newMessage[@"textentryid"];
        NSString *text = newMessage[@"text"];
        CGSize size = [MMMessageView calculateSizeForText:text];
        MMMessageView *mv = [[MMMessageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        (self.viewsDictionary)[messageid] = mv;
        [mv updateWithDict:newMessage];
        
        [self.messageViews insertObject:mv atIndex:0];
        [self addSubview:mv];
    }
}

// This methods takes all the views inside the scroll view and arranges them by order.
// The messages from the own user will appear to the right, and the messages from
// another users will appear to the left of the screen.
- (void)arrangeMessages {
    CGRect r;
    CGFloat y = kMessageVerticalPadding;
    CGFloat x = 0;
    CGFloat scrollHeight = 0;
    for (NSInteger i = [self.messageViews count] - 1; i < [self.messageViews count]; i--) {
        // Get the next message view
        MMMessageView *nextMessage = (self.messageViews)[i];
        
        // Now move the view to the propper place
        if ([self.userid isEqualToString:(nextMessage.json)[@"user"][@"userid"]]) {
            x = self.frame.size.width - nextMessage.frame.size.width - kMessageHorizontalPadding;
        } else {
            x = kMessageHorizontalPadding;
        }
    
        r = CGRectMake(x, y, nextMessage.frame.size.width, nextMessage.frame.size.height);
        nextMessage.frame = r;
        
        // Update the y for the next message
        y += kMessageVerticalPadding + nextMessage.frame.size.height;
        
        // Increase the scroll height
        scrollHeight += nextMessage.frame.size.height + kMessageVerticalPadding;
    }
    
    // Set the content size of the scroll
    self.contentSize = CGSizeMake(self.frame.size.width, kMessageVerticalPadding + scrollHeight);
}

// This method is used to scroll this scroll view to the bottom.
- (void)scrollToBottom {
    // Scroll to bottom
    CGPoint bottomOffset = CGPointMake(0, self.contentSize.height - self.bounds.size.height);
    [self setContentOffset:bottomOffset animated:YES];
}

@end
