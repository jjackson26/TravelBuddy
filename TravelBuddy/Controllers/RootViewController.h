//
//  ViewController.h
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/12/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MindMeldSDK/MindMeldSDK.h>

#import "MMVoiceSearchBarView.h"

@interface RootViewController : UIViewController <UITableViewDataSource>

- (IBAction)onMenuButtonPress:(id)sender;

@property (weak, nonatomic) IBOutlet MMVoiceSearchBarView *searchBarView;

@property (weak, nonatomic) IBOutlet UIView *landingContainerView;
@property (weak, nonatomic) IBOutlet UIView *searchResultsContainerView;


@end
