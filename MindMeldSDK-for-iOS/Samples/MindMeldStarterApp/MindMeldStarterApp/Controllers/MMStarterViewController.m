//
//  MMStarterViewController.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// interface
#import "MMStarterViewController.h"

// controllers
#import "MMVoiceSearchController.h"

// utilities
#import "UIView+Screenshot.h"
#import "MMConstants.h"

@interface MMStarterViewController ()

@property (nonatomic, assign) BOOL viewHasAppeared;

@property (nonatomic, assign) BOOL shouldShowPopover;
@property (nonatomic, strong) UIPopoverController *tooltipPopoverController;

@property (nonatomic, strong) UIImage *screenshotImage;

@end

@implementation MMStarterViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.screenshotImage = self.view.screenshot;
    if (!self.viewHasAppeared) {
        self.viewHasAppeared = YES;
        [self schedulePopoverPresentation];
    }
}


#pragma mark - voice search controller

/*****
 *  (1)
 *  This method creates a voice search controller and presents it modally over the current screen.
 *****/
- (void)presentVoiceSearchController:(BOOL)shouldListen
{
    // Here we dismiss the popover telling the user about voice search.
    // This would be removed from a production app.
    if (self.tooltipPopoverController.popoverVisible) {
        [self dismissPopover];
    }
    self.shouldShowPopover = NO;

    // Specify your MindMeld app ID here.
    typeof(self) __weak weakSelf = self;
    MMVoiceSearchController *controller = [MMVoiceSearchController controllerWithMindMeldAppID:kMindMeldAppID];

    // Determines whether
    controller.listenOnAppear = shouldListen;

    // Display the popover telling the user about voice search again when the search controller is dismissed.
    // This would be removed from a production app.
    controller.onDismissed = ^{
        [weakSelf schedulePopoverPresentation];
    };
    controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    controller.underlyingImage = self.screenshotImage;

    [self presentViewController:controller
                       animated:NO
                     completion:nil];
}

- (IBAction)pressedMicrophoneButton
{
    [self presentVoiceSearchController:YES];
}

- (IBAction)pressedSearchButton
{
    [self presentVoiceSearchController:NO];
}


#pragma mark - popover

- (void)schedulePopoverPresentation
{
    self.shouldShowPopover = YES;

    typeof(self) __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.shouldShowPopover) {
            [weakSelf presentPopover];
        }
    });
}

- (void)presentPopover
{
    if (!self.tooltipPopoverController) {
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"tooltip"];
        self.tooltipPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        self.tooltipPopoverController.passthroughViews = @[ self.microphoneButton, self.searchButton ];
    }

    [self.tooltipPopoverController presentPopoverFromRect:self.microphoneButton.frame inView:self.view
                                 permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)dismissPopover
{
    [self.tooltipPopoverController dismissPopoverAnimated:YES];
}


@end

@implementation MMTooltipViewController

- (CGSize)preferredContentSize
{
    return CGSizeMake(176, 60);
}

@end

