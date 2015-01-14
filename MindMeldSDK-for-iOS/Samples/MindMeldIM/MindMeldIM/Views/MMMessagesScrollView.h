//
//  MMMessagesScrollView.h
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMessageView.h"

/**
 *  This is the scroll view that contains the list of available messages.
 */
@interface MMMessagesScrollView : UIScrollView

@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSMutableDictionary *viewsDictionary;
@property (nonatomic, strong) NSMutableArray *messageViews;

- (void)updateWithMessages:(NSArray *)messages;
- (void)scrollToBottom;

@end
