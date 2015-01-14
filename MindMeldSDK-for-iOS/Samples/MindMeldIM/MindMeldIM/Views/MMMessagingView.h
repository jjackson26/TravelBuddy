//
//  MMMessagingView.h
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMMessagesScrollView;
/**
 *  This is the view that contains the messages scroll view
 */
@interface MMMessagingView : UIView

@property (nonatomic, strong) MMMessagesScrollView *scrollView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UITextView *messageTextField;
@property (nonatomic, strong) UIButton *sendButton;

@end
