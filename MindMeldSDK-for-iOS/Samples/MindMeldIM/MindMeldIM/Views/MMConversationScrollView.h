//
//  MMConversationScrollView.h
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMMessagingView.h"
#import "MMDocumentsScrollView.h"

/**
 *  This is the scroll view that contains the list of available conversations for the user.
 */
@interface MMConversationScrollView : UIScrollView

@property (nonatomic, strong) MMMessagingView *messagingView;
@property (nonatomic, strong) MMDocumentsScrollView *documentsScrollView;

@end
