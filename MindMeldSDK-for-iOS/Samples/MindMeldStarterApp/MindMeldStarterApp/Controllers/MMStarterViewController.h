//
//  MMStarterViewController.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  MMStarterViewController is a simple controller with a background mocking an application that would
 *  host the voice search controller.
 *
 *  It has microphone and search buttons to initiate search.
 */
@interface MMStarterViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *microphoneButton;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;

- (IBAction)pressedMicrophoneButton;
- (IBAction)pressedSearchButton;

@end

@interface MMTooltipViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *label;

@end