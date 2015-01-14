//
//  MMVoiceSearchOptionsController.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/30/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MindMeldSDK/MMListener.h>

@interface MMVoiceSearchOptionsController : UITableViewController

@property (nonatomic, weak) IBOutlet UISwitch *continuousToggle;
@property (nonatomic, weak) IBOutlet UISwitch *interimToggle;
@property (nonatomic, weak) IBOutlet UITextField *languageTextField;

@property (nonatomic, strong) MMListener *listener;

- (IBAction)toggleValueChanged:(UISwitch *)toggle;



@end
