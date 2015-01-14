//
//  ViewController.h
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/12/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MindMeldSDK/MindMeldSDK.h>

@interface ViewController : UIViewController <MMAppDelegate, UITableViewDataSource>

- (IBAction)onMenuButtonPress:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;
@property (weak, nonatomic) IBOutlet UILabel *transcriptLabel;
@property (nonatomic, strong) MMListener *listener;
@property (nonatomic, strong) MMApp *mindMeldApp;

@end
