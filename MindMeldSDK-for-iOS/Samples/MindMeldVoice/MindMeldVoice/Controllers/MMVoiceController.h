//
//  MMViewController.h
//  MindMeldVoice
//
//  Created by J.J. Jackson on 8/26/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MindMeldSDK/MindMeldSDK.h>
#import <MindMeldSDK/MMListener.h>

#import "MMMicrophoneButton.h"

/**
 * This is the main controller for MindMeld Voice. This controller handles
 * the MindMeld SDK and the automatic speech recognition (ASR) library. For ASR, we are
 * using the Google Speech API. The app consists of a simple interface with
 * a button to start the speech recognition, a text field which contains the
 * speech-to-text result, and a table view which lists documents related to
 * the speech identified.
 */

@interface MMVoiceController : UIViewController <MMAppDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MMMicrophoneButton *speakButton;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;

- (IBAction)pressedSpeakButton:(id)sender;

@end
