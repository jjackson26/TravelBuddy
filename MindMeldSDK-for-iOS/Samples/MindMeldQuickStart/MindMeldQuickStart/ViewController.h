//
//  ViewController.h
//  MindMeldQuickStart
//
//  Created by James Gill on 11/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MindMeldSDK/MindMeldSDK.h>

@interface ViewController : UIViewController <MMAppDelegate,
                                            UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;
@property (weak, nonatomic) IBOutlet UILabel *transcriptLabel;
@property (nonatomic, strong) MMListener *listener;
@property (nonatomic, strong) MMApp *mindMeldApp;

@end