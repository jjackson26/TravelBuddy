//
//  ViewController.m
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/12/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import "ViewController.h"

#import <JHSidebar/JHSidebarViewController.h>
#import <MindMeldSDK/MindMeldSDK.h>


static NSString *const kMindMeldAppID = @"04d9414638edc91742257c680ed9359630c1f17a";

@interface ViewController ()

@property (nonatomic, strong) MMApp *mindMeldApp;

@property (nonatomic, copy) void (^onActiveSessionDidUpdate)();

@property (nonatomic, strong) NSMutableArray *activeTextEntryQueue;

@end

@implementation ViewController

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    [self startMindMeld];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onMenuButtonPress:(id)sender {
    // Toggle left sidebar
    [self.sidebarViewController toggleLeftSidebar];
}

#pragma mark - MindMeld API

- (void)startMindMeld
{
    self.mindMeldApp = [[MMApp alloc] initWithAppID:kMindMeldAppID];

    typeof(self) __weak weakSelf = self;
    [self.mindMeldApp start:@{ @"session": @{ @"name": [[self class] mindMeldSessionName] } }
                  onSuccess:^(id response) {
                      // if there is any operation scheduled for when the session updates, execute it now
                      if (weakSelf.onActiveSessionDidUpdate) {
                          weakSelf.onActiveSessionDidUpdate();
                      }

                      NSLog(@"successfully started MindMeldSDK");
                  }
                  onFailure:nil];
}

+ (NSString *)mindMeldSessionName
{
    NSString *dateTimeString = [NSDateFormatter localizedStringFromDate:[NSDate new]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterLongStyle];
    return [NSString stringWithFormat:@"%@: %@", [self class], dateTimeString];

}



@end
