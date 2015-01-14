//
//  MMViewController.m
//  MindMeldVoice
//
//  Created by J.J. Jackson on 8/26/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "MMVoiceController.h"

// controllers
#import "SVWebViewController.h"

// views
#import "MMActivityIndicatorView.h"
#import "UIAlertView+MindMeldVoice.h"

// utilities
#import "MMConstants.h"
#import <SDWebImage/SDWebImageManager.h>

typedef NS_ENUM (NSInteger, MMVoiceTransactionState) {
    MMVoiceTransactionStateIdle,
    MMVoiceTransactionStateInitial,
    MMVoiceTransactionStateRecording,
    MMVoiceTransactionStateProcessing,
};

static NSString *const kMindMeldVoiceSessionName = @"MindMeld Voice session";
static const NSTimeInterval kCellImageFadeDuration = 0.15;


@interface MMVoiceController ()

@property (nonatomic, assign) MMVoiceTransactionState voiceTransactionState;
@property (nonatomic, strong) MMListener *listener;

@property (nonatomic, strong) MMApp *mindMeldApp;
@property (nonatomic, readonly) NSArray *mindMeldDocuments;

@property (nonatomic, strong) MMActivityIndicatorView *aiView;

@property (nonatomic, copy) void (^onTextFieldDidEndEditing)(UITextField *textField);

@end

@implementation MMVoiceController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mindmeld-logo.png"]];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.headerHeightConstraint.constant = 96;
    }

    [self createTextFieldInputAccessoryView];
    [self startMindMeld];
    [self createListener];
    [self createActivityIndicator];
    [self addObservers];
}

- (void)dealloc {
    [self removeObservers];
}


#pragma mark - MindMeld API


/**
 *  This method checks whether MindMeld is ready to receive text entries.
 *  We need an active user and session before we can submit.
 */
- (BOOL)isMindMeldReady {
    return [self isMindMeldReady:NO];
}

- (BOOL)isMindMeldReady:(BOOL)suppressAlert {
    NSString *message = nil;
    BOOL result = YES;

    if (!self.mindMeldApp) {
        result = NO;
    } else if (!self.mindMeldApp.activeUser) {
        message = @"Please authenticate first";
        result = NO;
    } else if (!self.mindMeldApp.activeSession) {
        message = @"Please start a session first";
        result = NO;
    }

    if (message && !suppressAlert) {
        [UIAlertView showWarningAlert:message];
    }

    return result;
}

/**
 * This is a convenience method to get an array of the documents for the current session.
 */
- (MMDocumentList *)mindMeldDocuments {
    if ([self isMindMeldReady:YES]) {
        return self.mindMeldApp.activeSession.documents;
    }

    return nil;
}

/**
 *  (1)
 *  To set up the MindMeld SDK we create an MMApp using our application ID and call start.
 */
- (void)startMindMeld {
    self.mindMeldApp = [[MMApp alloc] initWithAppID:kMindMeldAppID];
    typeof(self) __weak weakSelf = self;
    [self.mindMeldApp start:nil
                  onSuccess:^(id ignored) {
                      /**
                       *  (2)
                       *  Now that the SDK has been initialized, we'll set the delegate and
                       *  subscribe to updates to the documents list.
                       */
                      weakSelf.mindMeldApp.delegate = weakSelf;
                      weakSelf.mindMeldApp.activeSession.documents.useBothPushAndPull = NO;
                      [weakSelf.mindMeldApp.activeSession.documents startUpdates];
                  }
                  onFailure:nil];
}

/**
 *  (6)
 *  Attempt to add a text entry to the current session.
 */
- (void)addMindMeldTextEntry:(NSString *)text {
    if (!(text && text.length > 0)) {
        return;
    }

    MMSuccessHandler successHandler = ^(NSDictionary *response) {
        NSLog(@"successfully submitted text entry: \"%@\"", text);
    };

    MMFailureHandler failureHandler = ^(NSError *error) {
        NSLog(@"error submitting text entry: %@", error);
        [UIAlertView showErrorAlert:@"Unable to submit text entry"];
    };

    NSDictionary *textEntry = @{ @"text": text, // The content of the text entry.
                                 @"type": @"speech", // The type of the text entry; this can be used to filter text entries
                                 @"weight": @"0.5" }; // The text entries will all have the same weight. If we valued certain text entries over others, we might raise or lower this accordingly.

    [self showActivityIndicator];
    [self.mindMeldApp.activeSession.textEntries postWithBody:textEntry
                                                   onSuccess:successHandler
                                                   onFailure:failureHandler];
}


#pragma mark - MMAppDelegate

/**
 *  (7)
 *  After updating the document list, we refresh the table view so the user can see the documents.
 */
- (void)documentListDidUpdate:(MMDocumentList *)documents {
    [self hideActivityIndicator];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationFade];
}

-   (void)documentList:(MMDocumentList *)documents
didFailUpdateWithError:(NSError *)error {
    [UIAlertView showErrorAlert:@"Failed to update document list"];
}


#pragma mark - Speak Button

/**
 *  (3)
 *  When the user wants to begin or finish speaking, they press the speak button.
 */
- (void)pressedSpeakButton:(id)sender {
    NSLog(@"%@ pressedSpeakButton:", [self class]);

    [self.textField resignFirstResponder];

    switch (self.voiceTransactionState) {
        case MMVoiceTransactionStateIdle:
            self.voiceTransactionState = MMVoiceTransactionStateInitial;
            [self startRecording];
            break;
        case MMVoiceTransactionStateRecording:
            self.speakButton.enabled = NO;
            [self stopRecording];
            break;
        default:
            break;
    }
}


#pragma mark - Listener

/**
 *  Here we create a listener and set its configuration and callbacks.
 */
- (void)createListener {
    self.listener = [MMListener listener];
    self.listener.continuous = YES; // continuous speech recognition
    self.listener.interimResults = YES;

    /**
     *  (4)
     *  In onBeganRecording, onFinishedRecording, onFinished and onVolumeChanged we are just changing
     *  the state so we can update the UI.
     */
    typeof(self) __weak weakSelf = self;
    self.listener.onBeganRecording = ^(MMListener *listener) {
        NSLog(@"listener began recording:");
        weakSelf.voiceTransactionState = MMVoiceTransactionStateRecording;
    };

    self.listener.onFinishedRecording = ^(MMListener *listener) {
        NSLog(@"listener finished recording:");
        weakSelf.voiceTransactionState = MMVoiceTransactionStateProcessing;
    };

    self.listener.onFinished = ^(MMListener *listener) {
        NSLog(@"listener finished:");
        weakSelf.voiceTransactionState = MMVoiceTransactionStateIdle;
    };

    self.listener.onVolumeChanged = ^(MMListener *listener, Float32 avgVolumeLevel, Float32 peakVolumeLevel) {
        weakSelf.speakButton.volumeLevel = avgVolumeLevel;
    };

    /**
     *  (5)
     *  After recording and processing the user's speech, we'll receive the parsed text from the listener.
     *  We need to add a text entry so that we can get related documents.
     */
    self.listener.onResult = ^(MMListener *listener, MMListenerResult *newResult) {
        if (newResult.transcript.length) {
            // use different text colors to indicate interim and final results
            NSDictionary *finalStringAttributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
            NSDictionary *interimStringAttributes = @{ NSForegroundColorAttributeName: [UIColor darkGrayColor] };
            NSMutableAttributedString *text = [NSMutableAttributedString new];
            for (MMListenerResult *result in listener.results) {
                NSDictionary *textAttributes = result.final ? finalStringAttributes : interimStringAttributes;
                NSAttributedString *textSegment = [[NSAttributedString alloc] initWithString:result.transcript
                                                                                  attributes:textAttributes];
                [text appendAttributedString:textSegment];
            }

            weakSelf.label.attributedText = text;

            if (newResult.final) {
                [weakSelf addMindMeldTextEntry:weakSelf.label.text];
            }
        }
    };

    // Here we handle any errors that may be ocurring
    self.listener.onError = ^(MMListener *listener, NSError *error) {
        NSLog(@"listener error: %@", error);
        weakSelf.voiceTransactionState = MMVoiceTransactionStateIdle;
        [UIAlertView showErrorAlert:error.localizedDescription];
    };
}

- (void)setVoiceTransactionState:(MMVoiceTransactionState)voiceTransactionState {
    _voiceTransactionState = voiceTransactionState;

    switch (voiceTransactionState) {
        case MMVoiceTransactionStateRecording:
            self.speakButton.recording = YES;
            break;
        case MMVoiceTransactionStateIdle:
        case MMVoiceTransactionStateInitial:
        case MMVoiceTransactionStateProcessing:
        default:
            self.speakButton.recording = NO;
            break;
    }

    if (voiceTransactionState <= MMVoiceTransactionStateInitial) {
        self.speakButton.enabled = YES;
    }
}


/**
 * To start recording we create a speech recognizer object. You can tweak the parameters for a different use cases.
 */
- (void)startRecording {
    self.label.text = self.textField.text = @"";
    [self.listener startListening];
}

// We allow the user to manually stop recording
- (void)stopRecording {
    [self.listener stopListening];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.listener.listening) {
        return NO;
    }

    // hide the label while we edit the text using the textfield
    self.label.hidden = YES;
    self.textField.attributedText = self.label.attributedText;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    typeof(self) __weak weakSelf = self;
    self.onTextFieldDidEndEditing = ^(UITextField *textField) {
        NSString *text = textField.text;
        [weakSelf addMindMeldTextEntry:text];
    };

    [textField resignFirstResponder];
    return YES;
}

- (void)cancelEditing {
    typeof(self) __weak weakSelf = self;
    self.onTextFieldDidEndEditing = ^(UITextField *textField) {
        weakSelf.textField.attributedText = weakSelf.label.attributedText;
    };

    [self.textField resignFirstResponder];
}

/**
 * The user can also opt to input their text entry with the keyboard.
 */
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.onTextFieldDidEndEditing) {
        self.onTextFieldDidEndEditing(textField);
    }

    self.label.attributedText = textField.attributedText;
    self.label.hidden = NO;
    textField.text = @"";
}

- (void)createTextFieldInputAccessoryView {
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(cancelEditing)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barTintColor = toolbar.backgroundColor = [UIColor whiteColor];
    toolbar.items = @[ spacer, barButton ];
    self.textField.inputAccessoryView = toolbar;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.mindMeldDocuments.count;
}

/**
 *  (8)
 *  We use the title and image of document to represent it visually in the table view.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kDocumentCellID = @"documentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDocumentCellID];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kDocumentCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSDictionary *document = self.mindMeldDocuments[indexPath.row];
    NSString *title = document[@"title"]; // the document's title
    NSString *iconURLString = document[@"image"][@"url"]; // the url or an image representing the document

    if (iconURLString) {
    } else {
        iconURLString = document[@"source"][@"icon"]; // the icon of the source website for the document
    }

    cell.textLabel.text = title;

    NSURL *imageURL = [NSURL URLWithString:iconURLString];
    UIImage *image = nil;

    // Look for the image in the cache
    if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:imageURL]) {
        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:imageURL];
        image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
        if (!image) {
            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
        }
    }

    void (^setCellImage)(UITableViewCell *, UIImage *) = ^(UITableViewCell *cell, UIImage *image) {
        cell.imageView.image = image;
        [cell layoutSubviews];
    };
    if (image) {
        // image the image was cached, apply it now
        setCellImage(cell, image);
    } else {
        //
        setCellImage(cell, [UIImage imageNamed:@"default-icon"]);

        SDWebImageCompletionWithFinishedBlock completion = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [UIView transitionWithView:cell.imageView
                              duration:kCellImageFadeDuration
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{ setCellImage(cell, image); }
                            completion:nil];
        };

        [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL
                                                        options:0
                                                       progress:nil
                                                      completed:completion];
    }
    return cell;
}


#pragma mark - UITableViewDelegate

/**
 *  (9)
 *  When a user selects a document, we open that document in web view controller.
 */
-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *document = self.mindMeldDocuments[indexPath.row];
    NSString *urlString = document[@"originurl"];

    SVWebViewController *controller = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
    [self.navigationController pushViewController:controller
                                         animated:YES];
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}


#pragma mark - Activity Indicator

- (CGRect)activityIndicatorFrame {
    CGRect frame = self.tableView.frame;
    return frame;
}

- (void)createActivityIndicator {
    self.aiView = [[MMActivityIndicatorView alloc] initWithFrame:self.activityIndicatorFrame];
}

- (void)showActivityIndicator {
    self.aiView.frame = self.activityIndicatorFrame;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.aiView showInView:self.view
                   animated:YES];
}

- (void)hideActivityIndicator {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.aiView hide:YES];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    // Set the listener in the Listener config controller
    [segue.destinationViewController setListener:self.listener];
}


#pragma mark - observers

- (void)addObservers {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self
                           selector:@selector(appDidEnterBackground)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
}

- (void)removeObservers {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter removeObserver:self
                                  name:UIApplicationDidEnterBackgroundNotification
                                object:nil];
}

- (void)appDidEnterBackground {
    // MMListener does not support listening while in the background
    if (self.voiceTransactionState != MMVoiceTransactionStateIdle) {
        [self.listener stopListening];
    }
}

@end
