//
//  HelloWorldViewController.h
//  MindMeldHelloWorld
//
//  Created by Juan Rodriguez on 11/6/13.
//  Copyright (c) 2013 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelloWorldView.h"
#import <MindMeldSDK/MindMeldSDK.h>

@interface HelloWorldViewController : UIViewController <MMAppDelegate>

@property (nonatomic, strong) HelloWorldView *helloWorldView;
@property (nonatomic, strong) MMApp *mmApp;

@end
