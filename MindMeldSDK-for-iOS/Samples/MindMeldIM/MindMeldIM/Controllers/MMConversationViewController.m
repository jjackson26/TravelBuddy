//
//  MMConversationViewController.m
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMConversationViewController.h"
#import "MMConversationScrollView.h"
#import "MMMessagesScrollView.h"

@implementation MMConversationViewController

// This is the load view method. Here we'll create the view for this view controller and connect all the UI actions and hooks for this view.
- (void)loadView {
    // Initialize the view
    MMConversationScrollView *scrollView = [[MMConversationScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = self.scrollView = scrollView;

    // Set the parameters for the view
    self.scrollView.messagingView.scrollView.userid = [self.mmApp.activeUser json][@"userid"];
    
    // Connect the actions
    [self.scrollView.messagingView.sendButton addTarget:self action:@selector(sendButtonTapped:)
                                       forControlEvents:UIControlEventTouchUpInside];
    self.scrollView.delegate = self;
    
    // Add the notifications for the keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self
                                                                          action:@selector(closeButtonTapped:)];
    self.navigationItem.rightBarButtonItem = closeBarButtonItem;
}

////
//1)
////
- (void)updateSession {
    // Set the active session on the MindMeld iOS SDK.
    self.mmApp.activeSessionID = (self.session)[@"sessionid"];
}

#pragma mark - UI actions

////
//10)
////
// This method is called when the "close" button is tapped.
- (void)closeButtonTapped:(id)button {
    // Close this view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

////
//5)
////
// This method is called when the send button is tapped.
- (void)sendButtonTapped:(id)button {
    NSString *text = self.scrollView.messagingView.messageTextField.text;
    if (!text || !text.length) {
        return;
    }

    ////
    //6)
    ////
    // Create a new text entry and post it
    void (^successblock)(id) = ^(NSDictionary *response) {
        // Clean the message text.
        self.scrollView.messagingView.messageTextField.text = @"";
    };
    NSDictionary *textEntry = @{ @"text": text,
                                 @"type": @"text",
                                 @"weight": @"1.0" };
    [self.mmApp.activeSession.textEntries postWithBody:textEntry
                                             onSuccess:successblock
                                             onFailure:nil];
}

#pragma mark - UI Events delegate
// This method is called when the keyboard shows in the screen. Here we just want to move up the views a little, so that we can see what we type.
- (void)keyboardDidShow:(NSNotification *)notification {
    [self animateKeyboard:notification
                 comingIn:YES];
}

// This method is called when the keyboard hides. Here we want to move the views to their original location.
- (void)keyboardDidHide:(NSNotification *)notification {
    [self animateKeyboard:notification
                 comingIn:NO];
}

- (void)animateKeyboard:(NSNotification *)notification
               comingIn:(BOOL)comingIn {
    // Get the properties of the keyboard.
    CGSize keyboardSize = [[notification userInfo][UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    // Get the new frames for the views
    CGRect scrollViewFrame = self.scrollView.messagingView.scrollView.frame;
    CGRect footerViewFrame = self.scrollView.messagingView.footerView.frame;
    CGFloat shiftBy = keyboardSize.height;

    if (comingIn) {
        shiftBy *= -1;
    }

    scrollViewFrame.size.height += shiftBy;
    footerViewFrame.origin.y += shiftBy;

    // Move the views with an animation
    MMMessagingView *messagingView = self.scrollView.messagingView;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:options
                     animations:^{
                         messagingView.scrollView.frame = scrollViewFrame;
                         messagingView.footerView.frame = footerViewFrame;
                         [messagingView.scrollView scrollToBottom];
                     }
                     completion:nil];
}

// When we scroll to the documents view, we want to hide the keyboard.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.scrollView.messagingView.messageTextField resignFirstResponder];
}

#pragma mark - MMApp delegate methods


////
//2)
////
// This method is called when the active session has updated it's data.
- (void)activeSessionDidUpdate:(MMSession *)session {
    // Start the updates in the text entries and documents.
    self.mmApp.activeSession.textEntries.useBothPushAndPull = NO;
    [self.mmApp.activeSession.textEntries startUpdates];
    [self.mmApp.activeSession.textEntries reloadData];
    self.mmApp.activeSession.documents.useBothPushAndPull = NO;
    [self.mmApp.activeSession.documents startUpdates];
    
    // Set the name of the session
    self.navigationItem.title = [session json][@"name"];
}

////
//3)
////
// This method is called when the text entries has been updated.
- (void)textEntryListDidUpdate:(MMTextEntryList *)textEntries {
    // Here we need to update the view with the new text entries or "messages".
    [self.scrollView.messagingView.scrollView updateWithMessages:[textEntries json]];
}

////
//4)
////
// This method is called when the documents have been upadted.
- (void)documentListDidUpdate:(MMDocumentList *)documents {
    // Here we need to update the view with the new list of documents.
    [self.scrollView.documentsScrollView updateWithDocuments:[documents json]];
}

@end
