//
//  MMConversationViewController.h
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MindMeldSDK/MindMeldSDK.h>
#import "MMConversationScrollView.h"

/**
 *  This is the view controller that opens when a user taps on a particular session in the sesion list.
 *  It contains the list of messages in the conversation as well as the docuements collection.
 */
@interface MMConversationViewController : UIViewController <MMAppDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSDictionary *session;
@property (nonatomic, strong) MMApp *mmApp;
@property (nonatomic, strong) MMConversationScrollView *scrollView;

- (void)updateSession;

@end
