//
//  MMConversationsViewController.h
//  MindMeld IM
//
//  Created by Juan Rodriguez on 2/24/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMConversationsScrollView.h"
#import <MindMeldSDK/MindMeldSDK.h>

/**
 *  This is the view controller that gets first started in the App. Its view shows
 *  all the sessions that the user is allowed to join.
 */
@interface MMConversationsViewController : UIViewController <MMSessionViewDelegate>

@property (nonatomic, strong) MMApp *mmApp;
@property (nonatomic, strong) MMConversationsScrollView *scrollView;

@end
