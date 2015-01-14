//
//  MMBrowserViewController.h
//  MindMeld Browser
//
//  Created by Juan Rodriguez on 2/27/14.
//  Copyright (c) 2014 Regio Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMBrowserView.h"
#import <MindMeldSDK/MindMeldSDK.h>

@interface MMBrowserViewController : UIViewController <MMAppDelegate>

@property (nonatomic, strong) MMApp *mmApp;
@property (nonatomic, strong) MMBrowserView *browserView;

@end
