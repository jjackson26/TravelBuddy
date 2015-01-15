//
//  ViewController.m
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/12/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import "RootViewController.h"

// controllers
#import <JHSidebar/JHSidebarViewController.h>
#import "LandingViewController.h"
#import "SearchResultsTableViewController.h"

// views
#import "MMActivityIndicatorView.h"
#import "MMMicrophoneButton.h"

// utilities
#import <MindMeldSDK/MindMeldSDK.h>
#import "UIColor+MindMeldStarterApp.h"

static NSString *const kMindMeldAppID = @"04d9414638edc91742257c680ed9359630c1f17a";

static const NSUInteger kNumTextEntries = 1;
static const NSUInteger kNumDocuments = 10;

@interface RootViewController ()

@property (nonatomic, strong) MMApp *mindMeldApp;

@property (nonatomic, copy) void (^onActiveSessionDidUpdate)();

@property (nonatomic, strong) NSMutableArray *activeTextEntryQueue;

@property (nonatomic, assign) BOOL resultsAreVisible;

@property (nonatomic, strong) LandingViewController *landingController;
@property (nonatomic, strong) SearchResultsTableViewController *searchResultsController;

@end

@implementation RootViewController

+ (void)initialize
{
    [self configureUIAppearance];
}

+ (void)configureUIAppearance
{
    // customize search bar appearance
    MMVoiceSearchBarView *searchBarAppearance = [MMVoiceSearchBarView appearanceWhenContainedIn:[self class], nil];
    searchBarAppearance.borderColor     = [UIColor mindMeldDarkBlueColor];
    searchBarAppearance.backgroundColor = [UIColor blackColor];

    // customize mic button appearance
    MMMicrophoneButton *buttonAppearance = [MMMicrophoneButton appearanceWhenContainedIn:[self class], nil];
    buttonAppearance.backgroundColor            = [UIColor mindMeldBlueColor];
    buttonAppearance.activeBackgroundColor      = [UIColor mindMeldDarkBlueColor];
    buttonAppearance.highlightedBackgroundColor = [UIColor mindMeldLightGrayColor];
    buttonAppearance.iconColor                  = [UIColor whiteColor];
    buttonAppearance.highlightedIconColor       = [UIColor mindMeldBlueColor];
    buttonAppearance.activeIconColor            = [UIColor mindMeldLightGrayColor];
    buttonAppearance.borderColor                = [UIColor mindMeldDarkGrayColor];
    buttonAppearance.activeBorderColor          = [UIColor mindMeldBlueColor];
    buttonAppearance.activeBorderGlowColor      = [UIColor whiteColor];
    buttonAppearance.volumeColor                = [UIColor mindMeldBlueColor];

    // customize activity indicator appearance
    MMActivityIndicatorView *aiViewAppearance = [MMActivityIndicatorView appearanceWhenContainedIn:[self class], nil];
    aiViewAppearance.strokeColor = [UIColor mindMeldBlueColor];
    aiViewAppearance.glowColor   = [UIColor whiteColor];
}

#pragma mark - view lifecycle

- (void)loadView
{
    [super loadView];
    [self configureSearchBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self startMindMeld];
    [self prepareSearchResults];
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

    // create a text entry queue for managing active text entries
    self.activeTextEntryQueue = [NSMutableArray array];
}

// configure search bar
- (void)configureSearchBar
{
    self.searchBarView.listener.interimResults = YES;
    typeof(self) __weak weakSelf = self;
    self.searchBarView.onListenerStarted = ^(MMListener *listener) {
        [weakSelf beginNewSearch];
    };

    self.searchBarView.onListenerResult = ^(MMListener *listener, MMListenerResult *result) {
        if (result.transcript.length && result.final) {
            [weakSelf addMindMeldTextEntry:result.transcript type:@"voice"]; // post all final text entries
        }
    };

    self.searchBarView.onListenerError = ^(MMListener *listener, NSError *error) {
        if ([error.domain isEqualToString:MMMindMeldSDKListenerErrorDomain] &&
            error.code == MMMindMeldSDKListenerMicrophoneAccessError) {
            [[[UIAlertView alloc] initWithTitle:@"Whoops"
                                        message:@"Access to the microphone has been denied. Please enable it in Settings > Privacy > Microphone."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    };

    self.searchBarView.onTextSubmitted = ^(NSString *text) {
        [weakSelf beginNewSearch];
        [weakSelf addMindMeldTextEntry:text type:@"text"];
    };
}

+ (NSString *)mindMeldSessionName
{
    NSString *dateTimeString = [NSDateFormatter localizedStringFromDate:[NSDate new]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterLongStyle];
    return [NSString stringWithFormat:@"%@: %@", [self class], dateTimeString];

}

- (void)beginNewSearch
{
    // when a new search is started, clear search context
    [self.activeTextEntryQueue removeAllObjects];
}

/**
 *  A text entry is added when a user's speech is interpreted or when a user manually submits a typed query.
 *  The text entry is added to To add a text entry to the active session. After the text entry is added
 *  documents will be updated.
 *
 *  Note: If there is no active session, the text entry will be added when session becomes active.
 */
- (void)addMindMeldTextEntry:(NSString *)text
                        type:(NSString *)type
{
    // If there is no text, or it is the empty string, don't add the text entry
    if (!(text && text.length > 0)) {
        return;
    }

    // If the session is not yet set then schedule adding the text entry when it is updated
    // This can happen if a user performs a search very quickly after this controller's view is loaded
    if (!self.mindMeldApp.activeSession) {
        typeof(self) __weak weakSelf = self;
        self.onActiveSessionDidUpdate = ^{
            [weakSelf addMindMeldTextEntry:text type:type];
            weakSelf.onActiveSessionDidUpdate = nil;
        };
        return;
    }

    // show the activity indicator to inform the user a process is in action
//    [self showActivity];

    typeof(self) __weak weakSelf = self;
    MMSuccessHandler successHandler = ^(NSDictionary *response) {
        [weakSelf addActiveTextEntry:response];
        [weakSelf getDocuments];
        NSLog(@"successfully submitted text entry: \"%@\"", text);
    };

    MMFailureHandler failureHandler = ^(NSError *error) {
        NSLog(@"error submitting text entry: %@", error);
    };

    NSDictionary *textEntry = @{ @"text": text, // The content of the text entry.
                                 @"type": type, // The type of the text entry; this can be used to filter text entries
                                 @"weight": @"1.0" }; // The text entries will all have the same weight. If we valued certain text entries over others, we might raise or lower this accordingly.

    [self.mindMeldApp.activeSession.textEntries postWithBody:textEntry
                                                   onSuccess:successHandler
                                                   onFailure:failureHandler];
}

/**
 *  Adds a text entry to the queue of active text entries. If there are too many, the oldest text
 *  entry will be removed, so documents remain relevant to the most recent part of the query.
 *
 *  @param response The body of the text entry returned from the API
 */
- (void)addActiveTextEntry:(id)response
{
    [self.activeTextEntryQueue insertObject:response[@"textentryid"]
                                    atIndex:0];

    if (self.activeTextEntryQueue.count > kNumTextEntries) {
        [self.activeTextEntryQueue removeLastObject];
    }
}

/**
 * This method retrieves documents relevant to the users search. When the documents are retrieved they
 * are passed to the documents controller for presentation, and the activity indicator is hidden.
 */
- (void)getDocuments
{
    typeof(self) __weak weakSelf = self;
    MMSuccessHandler successHandler = ^(id response) {
        NSLog(@"got documents");
        // Reload the results table so the documents are displayed.
        if (!weakSelf.resultsAreVisible) {
            [weakSelf moveSearchResultsOnscreen:YES
                                       animated:YES
                                     completion:^(BOOL finished) {
                                         weakSelf.searchResultsController.documents = response;
                                     }];
        } else {
            weakSelf.searchResultsController.documents = response;
        }
//        [weakSelf hideActivity];
    };
    MMFailureHandler failureHandler = ^(NSError *error) {
        NSLog(@"unable to get documents: %@", error);
    };

    // We only want documents relavant to active text entries
    NSDictionary *params = @{ @"textentryids" : [NSArray arrayWithArray:self.activeTextEntryQueue],
                              @"limit": [NSString stringWithFormat:@"%lu", (unsigned long)kNumDocuments] };

    [self.mindMeldApp.activeSession.documents getWithParams:params
                                                  onSuccess:successHandler
                                                  onFailure:failureHandler];
}


#pragma mark - Search Results

- (void)prepareSearchResults
{
    [self moveSearchResultsOnscreen:NO animated:NO completion:nil];
}


- (void)moveSearchResultsOnscreen:(BOOL)onscreen
                         animated:(BOOL)animated
                       completion:(void (^)(BOOL))completion
{
    if (onscreen) {
        self.searchResultsContainerView.hidden = NO;
    }

    typeof(self) __weak weakSelf = self;
    void (^animations)() = ^{
        weakSelf.searchResultsContainerView.alpha = onscreen ? 1.0 : 0;
    };

    
    void (^innerCompletion)(BOOL) = ^(BOOL finished) {
        if (!onscreen) {
            weakSelf.searchResultsContainerView.hidden = YES;
        }

        weakSelf.resultsAreVisible = onscreen;
        if (completion) {
            completion(finished);
        }
    };

    if (animated) {
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:animations
                         completion:innerCompletion];
    } else {
        animations();
        innerCompletion(YES);
    }
}


#pragma mark - Segues

static NSString *const kSegueIdentifierLanding = @"segueLanding";
static NSString *const kSegueIdentifierSearchResults = @"segueSearchResults";

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];

    if ([kSegueIdentifierLanding isEqualToString:segue.identifier]) {
        self.landingController = segue.destinationViewController;
    } else if ([kSegueIdentifierSearchResults isEqualToString:segue.identifier]) {
        self.searchResultsController = segue.destinationViewController;
    }
}


@end
