//
//  MMBrowserViewController.m
//  MindMeld Browser
//
//  Created by Juan Rodriguez on 2/27/14.
//  Copyright (c) 2014 Regio Systems. All rights reserved.
//

#import "MMBrowserViewController.h"

#import "MMConstants.h"

@implementation MMBrowserViewController

// In this init method for this view controller, we will initialize the MindMeld iOS SDK, and get a user token from the API.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Start SDK
        // Here we create the MMApp object, all we need id the App ID. This ID is given to you when you sign up for using our API in the MindMeld Developer Center.
        MMApp *mmApp = [[MMApp alloc] initWithAppID:kMindMeldAppID];
        
        // We'll use this view controller as the delegate of the MMApp object.
        mmApp.delegate = self;
        
        // We'll store the MMApp object here, since we need it for making other calls later to the MindMeld API.
        self.mmApp = mmApp;

        ////
        //1)
        ////
        // Here we set the active user. We set the MindMeld token that you can get from the GET /tokens method and also the user id for
        // that token. If you use an Admin token, you can specify any user id in your app.
        self.mmApp.token = kMindMeldUserToken;
        self.mmApp.activeUserID = kMindMeldUserID;
    }
    return self;
}

- (void)loadView {
    // Set the view
    MMBrowserView *bv = [[MMBrowserView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = bv;
    self.browserView = bv;
    
    // Connect the ui actions
    [self.browserView.browserScrollView.browser.goButton addTarget:self
                                                            action:@selector(goButtonTapped:)
                                                  forControlEvents:UIControlEventTouchUpInside];
    [self.browserView.browserScrollView.browser.entitiesButton addTarget:self
                                                                  action:@selector(entitiesButtonTapped:)
                                                        forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UI Actions

////
//4)
////
// This method is called when the user taps on the "Go" button after entering a url
- (void)goButtonTapped:(id)button {
    // Get the url
    NSString *rawUrlString = self.browserView.browserScrollView.browser.urlField.text;
    
    // Make sure the url starts with 'http', otherwise add it and create the url
    NSURL *url;
    if ([rawUrlString hasPrefix:@"http://"]) {
        url = [NSURL URLWithString:rawUrlString];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", rawUrlString]];
    }
    
    // Now make the reques for the webview
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.browserView.browserScrollView.browser.webView loadRequest:request];
    
    // Dismiss the keyboard
    [self.browserView.browserScrollView.browser.urlField resignFirstResponder];
}

////
//5)
////
- (void)entitiesButtonTapped:(id)button {
    // Show the activity indicator
    [self.browserView.browserScrollView.browser showActivityIndicator];
    
    // Get the text from the article in the background.
    typeof(self) __weak weakSelf = self;
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ////
        //6)
        ////
        // We start by crawling the article the user is reading
        NSString *url = self.browserView.browserScrollView.browser.webView.request.URL.absoluteString;
        NSString *apiUrl = [NSString stringWithFormat:@"%@?token=%@&url=%@&fields=text", kDiffBotAPI, kDiffBotToken, url];
        NSData *response = [NSData dataWithContentsOfURL:[NSURL URLWithString:apiUrl]
                                                 options:0
                                                   error:NULL];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response
                                                             options:NSJSONReadingMutableContainers
                                                               error:NULL];

        // Go back to the main thread
        dispatch_async( dispatch_get_main_queue(), ^{
            NSLog(@"Response is: %@", json);

            // Now post the article to the API
            [weakSelf postArticleToAPI:json];

            // After the articles have been posted, we fetch entities. We'll wait 2 seconds so all processing in the backend is finished.
            [NSTimer scheduledTimerWithTimeInterval:2.0
                                             target:weakSelf
                                           selector:@selector(fetchEntities)
                                           userInfo:nil
                                            repeats:NO];
        });
    });
}

#pragma mark - Utility methods

////
//7)
////
// This method takes a json dictionary that contains a webpage. This dictionary should contain a field
// called "text", which includes the text that will be posted to the MindMeld API.
- (void)postArticleToAPI:(NSDictionary *)dict {
    if ([dict objectForKey:@"error"]) {
        NSString *message = [NSString stringWithFormat:@"The webpage you are viewing could not be scraped: %@", dict[@"error"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        // Hide the activity indicator
        [self.browserView.browserScrollView.browser hideActivityIndicator];

        return;
    }

    // First get the raw text
    NSString *rawText = dict[@"text"];
    
    // Now remove the line breaks from the text
    NSString *finalText = [rawText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    // If there is no text to post, then show an alert and cancel the post
    if ([finalText isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Text Found"
                                                        message:@"The webpage you are viewing could not be scraped."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        // Hide the activity indicator
        [self.browserView.browserScrollView.browser hideActivityIndicator];
        
        return;
    }
    
    // Now post the text entry
    typeof(self) __weak weakSelf = self;
    MMSuccessHandler successHandler = ^(NSDictionary *response) {
        // We do nothing here
    };
    MMFailureHandler failureHandler = ^(NSError *error) {
        // Hide the activity indicator
        [weakSelf.browserView.browserScrollView.browser hideActivityIndicator];
    };
    NSDictionary *textEntry = @{ @"text": finalText,
                                 @"type": @"text",
                                 @"weight": @"1.0" };
    [self.mmApp.activeSession.textEntries postWithBody:textEntry
                                             onSuccess:successHandler
                                             onFailure:failureHandler];
}

////
//8)
////
- (void)fetchEntities {
    typeof(self) __weak weakSelf = self;
    MMSuccessHandler successHandler = ^(NSArray *response) {
        NSLog(@"Response: %@", response);
        ////
        //9)
        ////

        // Hide the activity indicator
        [weakSelf.browserView.browserScrollView.browser hideActivityIndicator];
        
        // Update the UI with the new data
        [weakSelf.browserView.browserScrollView.entitiesScrollView updateWithEntities:response];
        
        // Also scroll to the entities page
        CGRect frame = weakSelf.browserView.frame;
        [weakSelf.browserView.browserScrollView scrollRectToVisible:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)
                                                           animated:YES];
    };
    MMFailureHandler failureHandler = ^(NSError *error) {
        // Hide the activity indicator
        [weakSelf.browserView.browserScrollView.browser hideActivityIndicator];
    };
    // We set the limit to 50 entities, in case the article is big.
    NSDictionary *params = @{ @"limit": @"50" };
    [self.mmApp.activeSession.entities getWithParams:params
                                           onSuccess:successHandler
                                           onFailure:failureHandler];
}

#pragma mark - MMApp delegate methods

////
//2)
////
// This method is called when the active user has been set. Here we create a new session and set it as the
// active session.
- (void)activeUserDidUpdate:(MMUser *)user {
    typeof(self) __weak weakSelf = self;
    MMSuccessHandler successHandler = ^(NSDictionary *response) {
        ////
        //3)
        ////
        // Set the new session as the active session.
        [weakSelf.mmApp setActiveSessionID:response[@"sessionid"]];
    };
    MMFailureHandler failureHandler = ^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    };
    //We need to provide a session name and a privacy mode. We add that information into the body dictionary.
    NSDictionary *newSession = @{ @"name": @"MindMeld Browser Session",
                                  @"privacymode": @"inviteonly" };
    [self.mmApp.activeUser.sessions postWithBody:newSession
                                       onSuccess:successHandler
                                       onFailure:failureHandler];
}

@end
