//
//  MMConversationsScrollView.h
//  MindMeld IM
//
//  Created by Juan Rodriguez on 2/24/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSessionView.h"

/**
 *  This is the scrollview where the conversations are listed.
 */
@interface MMConversationsScrollView : UIScrollView

@property (nonatomic, strong) id <MMSessionViewDelegate> sessionViewDelegate;

- (void)updateWithSessions:(NSArray *)sessions;

@end
