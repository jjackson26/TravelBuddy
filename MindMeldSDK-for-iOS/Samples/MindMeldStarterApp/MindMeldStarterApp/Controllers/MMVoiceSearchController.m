//
//  MMVoiceSearchController.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// interface
#import "MMVoiceSearchController.h"
#import "MMOverlayController+SubclassHooks.h"

// views
#import "MMActivityIndicatorView.h"
#import "MMVoiceSearchBarView.h"

// controllers
#import "MMDocumentsController.h"
#import "MMVoiceSearchOptionsController.h"

// utilities
#import "UIImage+ImageEffects.h"
#import "UIView+AutoLayout.h"
#import "NSJSONSerialization+Files.h"
#import "UIColor+MindMeldStarterApp.h"

// vendor
#import <MindMeldSDK/MindMeldSDK.h>


static const NSUInteger kNumTextEntries = 3;
static const NSUInteger kDefaultNumDocuments = 20;
static const BOOL       kDefaultListenOnAppear = YES;

static const CGFloat kTopButtonEdgeInsets = 8.0;
static const CGFloat kTopButtonSpacing = 16.0;
static const CGFloat kSearchBarTopSpacing = 60.0;
static const CGFloat kSearchBarSideSpacing = 36.0;
static const CGFloat kSearchBarHeight = 60.0;

static const NSTimeInterval kActivityIndicatorTransitionDuration = 1.0;

@interface MMVoiceSearchController () <MMAppDelegate>

@property (nonatomic, strong) MMActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) MMVoiceSearchBarView *searchBarView;
@property (nonatomic, strong) UIImageView *headerGradientImageView;

@property (nonatomic, strong) UIView *documentsView;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIPopoverController *optionsPopoverController;
@property (nonatomic, strong) MMDocumentsController *documentsController;
@property (nonatomic, strong, readonly) MMVoiceSearchOptionsController *optionsController;

@property (nonatomic, strong) NSMutableArray *activeTextEntryQueue;

@property (nonatomic, copy) NSString *mindMeldAppID;
@property (nonatomic, strong) MMApp *mindMeldApp;

@property (nonatomic, copy) void (^onActiveSessionDidUpdate)();

@end

@implementation MMVoiceSearchController

#pragma mark - Lifecycle

+ (instancetype)controllerWithMindMeldAppID:(NSString *)mindMeldAppID;
{
    MMVoiceSearchController *controller = [[self alloc] initWithMindMeldAppID:mindMeldAppID];

    return controller;
}

+ (void)initialize
{
    [self configureUIAppearance];
}

/*****
 *  (1)
 *  This method configures the UI appearance for the search bar, microphone button, and activity indicator views.
 *  You can change these colors to give your own look and feel.
 *****/
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


- (instancetype)initWithMindMeldAppID:(NSString *)mindMeldAppID
{
    self = [super initWithNibName:nil
                           bundle:nil];
    if (self) {
        _mindMeldAppID = mindMeldAppID;
        [self initializeVoiceSearchController];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        [self initializeVoiceSearchController];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeVoiceSearchController];
    }
    return self;
}

- (void)initializeVoiceSearchController
{
    self.modalPresentationCapturesStatusBarAppearance = YES;
    self.numDocuments =   kDefaultNumDocuments;
    self.listenOnAppear = kDefaultListenOnAppear;
}


#pragma mark - view lifecycle

- (void)loadView
{
    [super loadView];
    [self createSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // add constraints so the views are laid out as we desire
    [self createConstraints];

    // Initialize the MindMeld App so we can start using the API.
    [self startMindMeld];
}


#pragma mark - MindMeld

/*****
 *  (2)
 *  To set up the MindMeld SDK we create an MMApp using our application ID and call start with our session name.
 *****/
- (void)startMindMeld
{
    self.mindMeldApp = [[MMApp alloc] initWithAppID:self.mindMeldAppID];

    typeof(self) __weak weakSelf = self;
    [self.mindMeldApp start:@{ @"session": @{ @"name": [MMVoiceSearchController mindMeldSessionName] } }
                  onSuccess:^(id ignored) {
                      // if there is any operation scheduled for when the session updates, execute it now
                      if (weakSelf.onActiveSessionDidUpdate) {
                          weakSelf.onActiveSessionDidUpdate();
                      }

                      NSLog(@"successfully started MindMeldSDK");
                  }
                  onFailure:^(NSError *error) {
                      NSLog(@"Error starting MindMeld App: %@", error.localizedDescription);
                  }];

    // create a text entry queue for managing active text entries
    self.activeTextEntryQueue = [NSMutableArray array];
}

/**
 *  @return a session name  based on the name of this class and the date and time.
 */
+ (NSString *)mindMeldSessionName
{
    NSString *dateTimeString = [NSDateFormatter localizedStringFromDate:[NSDate new]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterLongStyle];
    return [NSString stringWithFormat:@"%@: %@", [self class], dateTimeString];
}

/*****
 *  (3) 
 *  A new search begins when a user presses the microphone to start a voice search, or when a user manually 
 *  submits a typed query. When this happens, we clear the context for our current documents.
 *****/
- (void)beginNewSearch
{
    // when a new search is started, clear search context
    [self.activeTextEntryQueue removeAllObjects];
}

/**
 *  (4)
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
    [self showActivity];

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


/*****
 *  (5)
 *  This method retrieves documents relevant to the users search. When the documents are retrieved they 
 *  are passed to the documents controller for presentation, and the activity indicator is hidden.
 *****/
- (void)getDocuments
{
    typeof(self) __weak weakSelf = self;
    MMSuccessHandler successHandler = ^(id response) {
        NSLog(@"got documents");
        /*****
         *  (6)
         *  Pass the documents to the documents controller so they are displayed.
         *****/
        weakSelf.documentsController.documents = response;
        [weakSelf hideActivity];
    };
    MMFailureHandler failureHandler = ^(NSError *error) {
        NSLog(@"unable to get documents: %@", error);
    };

    // We only want documents relavant to active text entries
    NSDictionary *params = @{ @"textentryids" : [NSArray arrayWithArray:self.activeTextEntryQueue],
                              @"limit": [NSString stringWithFormat:@"%lu", (unsigned long)self.numDocuments] };

    [self.mindMeldApp.activeSession.documents getWithParams:params
                                                  onSuccess:successHandler
                                                  onFailure:failureHandler];
}

#pragma mark - view creation

/**
 *  This method creates all of the subviews for this controller.
 */
- (void)createSubviews
{
    // The documents controller will display search results.
    [self createDocumentsController];

    // This gradients is a visual touch to help separate the documents from the search bar and controls at
    // the top of this view.
    UIImage *gradientImage = [UIImage imageNamed:@"searchBarGradient"];
    self.headerGradientImageView = [[UIImageView alloc] initWithImage:[gradientImage resizableImageWithCapInsets:UIEdgeInsetsMake(gradientImage.size.height, 0, 0, 0)]];
    self.headerGradientImageView.userInteractionEnabled = NO;
    self.headerGradientImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.headerGradientImageView];

    // The search bar is the interface for performing voice and typed searches.
    [self createSearchBar];

    // This is a custom activity indicator which communicates to the user that search results are being fetched
    self.activityIndicatorView = [MMActivityIndicatorView autoLayoutView];
    self.activityIndicatorView.userInteractionEnabled = NO;
    self.activityIndicatorView.alpha = 0;
    [self.contentView addSubview:self.activityIndicatorView];

    // The options button will bring up a controller which allows the user to change search settings.
    self.optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.optionsButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.optionsButton.contentEdgeInsets = UIEdgeInsetsMake(kTopButtonEdgeInsets, kTopButtonEdgeInsets, kTopButtonEdgeInsets, kTopButtonEdgeInsets);
    [self.optionsButton setImage:[UIImage imageNamed:@"options"]
                        forState:UIControlStateNormal];
    self.optionsButton.imageView.contentMode = UIViewContentModeCenter;
    [self.optionsButton addTarget:self
                           action:@selector(displayOptions)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.optionsButton];

    // This button allows the user to leave without selecting a document
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.closeButton.contentEdgeInsets = UIEdgeInsetsMake(kTopButtonEdgeInsets, kTopButtonEdgeInsets, kTopButtonEdgeInsets, kTopButtonEdgeInsets);
    [self.closeButton setImage:[UIImage imageNamed:@"close"]
                      forState:UIControlStateNormal];
    self.closeButton.imageView.contentMode = UIViewContentModeCenter;
    [self.closeButton addTarget:self
                         action:@selector(dismiss)
               forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.closeButton];
}

//
/**
 *  This method creates the documents controller, an extension of UICollectionViewController that presents
 *  the documents in a waterfall layout.
 */
- (void)createDocumentsController
{
    self.documentsController = [MMDocumentsController controller];

    // We must set the documents selected callbacks
    typeof(self) __weak weakSelf = self;
    self.documentsController.onDocumentSelected = ^(id documentJSON) {
        if (weakSelf.onDocumentSelected) {
            weakSelf.onDocumentSelected(documentJSON);
        }
    };
    self.documentsController.onDocumentDeselected = ^(id documentJSON) {
        if (weakSelf.onDocumentDeselected) {
            weakSelf.onDocumentDeselected(documentJSON);
        }
    };

    self.documentsView = self.documentsController.view;
    self.documentsView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addChildViewController:self.documentsController];

    [self.contentView addSubview:self.documentsView];
    UIEdgeInsets collectionInsets = UIEdgeInsetsMake(kSearchBarHeight + kSearchBarTopSpacing + 35, 0, 48.0, 0);
    self.documentsController.contentInset = collectionInsets;

    [self.documentsController didMoveToParentViewController:self];
}

/**
 *  The search bar is the interface for performing voice and typed searches. It has a microphone button to
 *  start voice recognition, a text field to display transcribed voice and for typing searches manually,
 *  and a search button for initiate searches.
 */
- (void)createSearchBar
{
    self.searchBarView = [MMVoiceSearchBarView autoLayoutView];
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

    [self.contentView addSubview:self.searchBarView];
}

/**
 *  This method adds constraints to layout the subviews as desired.
 */
- (void)createConstraints
{
    NSDictionary *views = @{ @"searchShadow": self.headerGradientImageView,
                             @"searchBar": self.searchBarView,
                             @"documents": self.documentsView,
                             @"optionsButton": self.optionsButton,
                             @"closeButton": self.closeButton };

    NSDictionary *metrics = @{ @"topButtonSpacing": @(kTopButtonSpacing),
                               @"searchBarHeight": @(kSearchBarHeight),
                               @"searchBarTopSpacing": @(kSearchBarTopSpacing),
                               @"searchBarSideSpacing": @(kSearchBarSideSpacing) };

    [self.searchBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[searchBar(==searchBarHeight)]"
                                                                               options:0
                                                                               metrics:metrics
                                                                                 views:views]];

    NSArray *visualFormats = @[ @"H:|[documents]|",
                                @"H:|[searchShadow]|",
                                @"H:|-(searchBarSideSpacing)-[searchBar]-(searchBarSideSpacing)-|",
                                @"H:|-[optionsButton]",
                                @"H:[closeButton]-|",
                                @"V:|[documents]|",
                                @"V:|[searchShadow]",
                                @"V:|-(searchBarTopSpacing)-[searchBar]",
                                @"V:|-(topButtonSpacing)-[optionsButton]",
                                @"V:|-(topButtonSpacing)-[closeButton]" ];

    [UIView addConstraintsForVisualFormats:visualFormats
                                     views:views
                                   metrics:metrics];

    [self.activityIndicatorView addConstraintsToCenterInSuperview];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - entrance animation

// The following methods handle the appearance and disappearance of the voice search controller

- (void)prepareForContentTransition:(BOOL)entering
{
    [super prepareForContentTransition:entering];

    CGAffineTransform transform = entering ? CGAffineTransformMakeTranslation(0, 30) : CGAffineTransformIdentity;
    self.optionsButton.transform = self.closeButton.transform = transform;
}

- (void)contentTransition:(BOOL)entering
{
    [super contentTransition:entering];

    self.optionsButton.transform = self.closeButton.transform = CGAffineTransformIdentity;
}

- (void)finishContentTransition:(BOOL)entering
{
    [super finishContentTransition:entering];

    if (entering) {
        if (self.listenOnAppear) {
            [self.searchBarView startListening];
        } else {
            [self.searchBarView becomeFirstResponder];
        }
    }
}


#pragma mark - Activity Indicator

// The following methods handle the appearance and disappearance of the activity indicator

- (void)showActivity
{
    typeof(self) __weak weakSelf = self;
    void (^animations)() = ^{
        weakSelf.activityIndicatorView.alpha = 1.0;
        weakSelf.documentsView.alpha = 0.4;
    };

    [self.activityIndicatorView startAnimating];
    [UIView animateWithDuration:kActivityIndicatorTransitionDuration
                     animations:animations];
}

- (void)hideActivity
{
    [self.activityIndicatorView stopAnimating];

    self.activityIndicatorView.alpha = 0.0;
    typeof(self) __weak weakSelf = self;
    void (^animations)() = ^{
        weakSelf.documentsView.alpha = 1.0;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        [weakSelf.activityIndicatorView cancelAnimation];
    };
    [UIView animateWithDuration:kActivityIndicatorTransitionDuration
                     animations:animations
                     completion:completion];
}


#pragma mark - Options

- (void)setShowOptionsButton:(BOOL)showOptionsButton
{
    _showOptionsButton = showOptionsButton;
    self.optionsButton.hidden = !showOptionsButton;
}

- (UIPopoverController *)optionsPopoverController
{
    if (!_optionsPopoverController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MMVoiceSearchOptionsController"
                                                             bundle:[NSBundle mainBundle]];

        MMVoiceSearchOptionsController *controller = [storyboard instantiateViewControllerWithIdentifier:@"MMVoiceSearchOptionsController"];

        _optionsPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    }

    return _optionsPopoverController;
}

- (MMVoiceSearchOptionsController *)optionsController
{
    return (MMVoiceSearchOptionsController *)self.optionsPopoverController.contentViewController;
}

- (void)displayOptions
{
    self.optionsController.listener = self.searchBarView.listener;
    [self.optionsPopoverController presentPopoverFromRect:self.optionsButton.frame
                                                   inView:self.contentView
                                 permittedArrowDirections:UIPopoverArrowDirectionUp
                                                 animated:YES];
}


@end
