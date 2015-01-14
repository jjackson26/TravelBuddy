//
//  MMMessagingView.m
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMMessagingView.h"
#import "MMMessagesScrollView.h"
#import "UIColor+MindMeldIM.h"

static const CGFloat kFooterHeight = 74;
static const CGFloat kSendButtonWidthRatio = 0.25;

@implementation MMMessagingView

// Here we just start this view, and all the subviews contained inside.
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Create the messages scroll view
        CGFloat scrollViewHeight = frame.size.height - kFooterHeight;
        MMMessagesScrollView *scrollView = [[MMMessagesScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                                  frame.size.width, scrollViewHeight)];
        [self addSubview:scrollView];
        self.scrollView = scrollView;

        // Add a footer view
        CGRect footerViewFrame = CGRectMake(0, scrollViewHeight, frame.size.width, kFooterHeight);
        UIView *footerView = [[UIView alloc] initWithFrame:footerViewFrame];
        footerView.backgroundColor = [UIColor mindMeldIMLightBlueColor];
        [self addSubview:footerView];
        self.footerView = footerView;

        // Add message text field
        CGFloat sendButtonWidth = self.footerView.frame.size.width * kSendButtonWidthRatio;
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - sendButtonWidth, kFooterHeight)];
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        [self.footerView addSubview:textView];
        self.messageTextField = textView;

        // Add the send button
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.frame = CGRectMake(frame.size.width - sendButtonWidth, 0, sendButtonWidth, kFooterHeight);
        [sendButton setTitle:@"Send" forState:UIControlStateNormal];
        UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        [sendButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [sendButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [self.footerView addSubview:sendButton];
        self.sendButton = sendButton;
    }
    return self;
}

@end
