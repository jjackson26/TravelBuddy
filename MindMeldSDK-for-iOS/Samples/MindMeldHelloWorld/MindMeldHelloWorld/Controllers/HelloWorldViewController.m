//
//  HelloWorldViewController.m
//  MindMeldHelloWorld
//
//  Created by Juan Rodriguez on 11/6/13.
//  Copyright (c) 2013 Expect Labs. All rights reserved.
//

#import "HelloWorldViewController.h"
#import "MMConstants.h"

@implementation HelloWorldViewController

- (void)loadView {
    HelloWorldView *helloWorldView = [[HelloWorldView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    self.view = self.helloWorldView =  helloWorldView;
}

- (void)viewDidLoad {
    // Here we create the MMApp object, all we need id the App ID. This ID is given to you when you sign up for using our API in the MindMeld Developer Center.
    MMApp *app = [[MMApp alloc] initWithAppID:kMindMeldAppID];
    
    // We'll use this view controller as the delegate of the MMApp object.
    app.delegate = self;
    
    // We'll store the MMApp object here, since we need it for making other calls later to the MindMeld API.
    self.mmApp = app;
    
    ////
    //1)
    ////
    // Here we set the active user. We set the MindMeld token that you can get from the GET /tokens method and also the user id for
    // that token. If you use an Admin token, you can specify any user id in your app.
    self.mmApp.token = kMindMeldUserToken;
    self.mmApp.activeUserID = kMindMeldUserID;
}

#pragma mark - Auxiliary methods for this class

////
//3)
////
// We use this method for posting a new session to the active user
- (void)postNewSession {
    typeof(self) __weak weakSelf = self;
    MMSuccessHandler successHandler = ^(NSDictionary *response) {
        ////
        //4)
        ////
        // Here the session has been created. We now set this as the active session, so we start posting text entries to it, and look at it's content.
        // After the active session is set, it's session id will be used on all API calls that need a session id.
        // The code continues on the activeSessionDidUpdate: callback method.
        [weakSelf.mmApp setActiveSessionID:response[@"sessionid"]];
    };
    MMFailureHandler failureHandler = ^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    };
    //We need to provide a session name and a privacy mode. We add that information into the body dictionary.
    NSDictionary *newSession = @{ @"name": @"My Awesome session", @"privacymode": @"friendsonly" };
    [self.mmApp.activeUser.sessions postWithBody:newSession
                                       onSuccess:successHandler
                                       onFailure:failureHandler];
}

////
//6)
////
// We use this method for posting a new text entry to the active session
- (void)postNewTextEntry {
    // Now we post a text entry to our session. You can see text entries need the fields: text, type and weight.
    MMSuccessHandler successHandler = ^(NSDictionary *response) {
        // We won't do anything here.
    };
    MMFailureHandler failureHandler = ^(NSError *error) {
        // We won't do anything here.
    };
    NSDictionary *newTextEntry = @{ @"text": @"Barack Obama visited San Francisco",
                                    @"type": @"speech",
                                    @"weight": @"1.0" };
    [self.mmApp.activeSession.textEntries postWithBody:newTextEntry
                                             onSuccess:successHandler
                                             onFailure:failureHandler];
}

// Publish custom push event
- (void)publishCustomPushEvent {
    [self.mmApp.activeSession publishEvent:@"myPushUpdate"
                                   payload:@{ @"message": @"This is my custom message" }];
}

#pragma mark - Delegate methods for the MMAppDelegate protocol

// Active User callbacks
////
//2)
////
// The active user has been set, we can now make API calls related to this user and start using the MindMeld API. We will beging by creating a new
// session, where we can later post text entries in order to get entities and related documents.
- (void)activeUserDidUpdate:(MMUser *)user {
    NSLog(@"HelloWorldViewController:activeUserDidUpdate: %@", [user json]);
    
    // We now post a new session to this user.
    [self postNewSession];
}

- (void)activeUser:(MMUser *)user didFailUpdateWithError:(NSError *)error {
    NSLog(@"HelloWorldViewController:activeUser:didFailUpdateWithError %@", [error description]);
}

// Active Session callbackks
////
//5)
////
// The active session has been updated, and we can now make API calls related to this session. Here we are going to start by posting a new text entry. Once the
// text entry is processed by the MindMeld API, new entities and documents will be generated. We will rely on push events to tell us when the entities and
// documents are ready. So we need to start push events on the entities and documents before posting our text entry.
- (void)activeSessionDidUpdate:(MMSession *)session {
    NSLog(@"HelloWorldViewController:activeSessionDidUpdate: %@", [session json]);
    
    // We begin by starting push events on entities and documents collections (notice we set useBothPushAndPull to no, so we don't do polling).
    self.mmApp.activeSession.entities.useBothPushAndPull = NO;
    [self.mmApp.activeSession.entities startUpdates];
    self.mmApp.activeSession.documents.useBothPushAndPull = NO;
    [self.mmApp.activeSession.documents startUpdates];
    
    // Since the connection to the push server can take a few seconds, we set a timer to post the new text entry after a few seconds.
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(postNewTextEntry) userInfo:nil repeats:NO];
}

- (void)activeSession:(MMSession *)session didFailUpdateWithError:(NSError *)error {
    NSLog(@"HelloWorldViewController:activeSession:didFailUpdateWithError %@", [error description]);
}

// Session list callbacks
- (void)sessionListDidUpdate:(MMSessionList *)sessions {
    NSLog(@"HelloWorldViewController:sessionListDidUpdate: %@", [sessions json]);
}

- (void)sessionList:(MMSessionList *)sessions didFailUpdateWithError:(NSError *)error {
    NSLog(@"HelloWordViewController:sessionList:didFailUpdateWithError %@", [error description]);
}

// Text entry list callbacks
- (void)textEntryListDidUpdate:(MMTextEntryList *)textEntries {
    NSLog(@"HelloWorldViewController:textEntryListDidUpdate: %@", [textEntries json]);
}

- (void)textEntryList:(MMTextEntryList *)textentries didFailUpdateWithError:(NSError *)error {
    NSLog(@"HelloWorldViewController:textEntryList:didFailUpdateWithError %@", [error description]);
}

// Entity list callbacks
////
//7)
////
// Entities will update when we receive the push update on that collection. We'll just print them to the screen.
- (void)entityListDidUpdate:(id)entities {
    NSLog(@"HelloWorldViewController:entityListDidUpdate: %@", [entities json]);
}

- (void)entityList:(MMEntityList *)entities didFailUpdateWithError:(NSError *)error {
    NSLog(@"HelloWorldViewController:entityList:didFailUpdateWithError %@", [error description]);
}

// Document list callbacks
////
//8)
////
// Documents have been updated, we'll just print them on the console.
// The last thing we'll do, is to subscribe to a custom push event on the session channel, and send a message on that event. We'll do that on this method.
- (void)documentListDidUpdate:(MMDocumentList *)documents {
    NSLog(@"HelloWorldViewController:documentListDidUpdate: %@", [documents json]);
    
    // Here we declare out handler for the push event, and subscribe to it
    void (^handleEvent)(id) = ^(NSDictionary *response) {
        ////
        //10)
        ////
        // Here we have received the event
        NSLog(@"Received myPushUpdate message with payload: %@", response);
    };
    ////
    //9)
    ////
    // We subscribe to the event we'll post and we post it after a few seconds.
    [self.mmApp.activeSession subscribeToEvent:@"myPushUpdate" onEvent:handleEvent];
    
    // Now we'll publish now a push event
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(publishCustomPushEvent) userInfo:nil repeats:NO];
}

- (void)documentList:(MMDocumentList *)documents didFailUpdateWithError:(NSError *)error {
    NSLog(@"HelloWorldViewController:documentList:didFailUpdateWithError %@", [error description]);
}

// Live user list callbacks
- (void)liveUserListDidUpdate:(id)liveusers {
    NSLog(@"HelloWorldViewController:liveUserListDidUpdate: %@", [liveusers json]);
}

- (void)liveUserList:(MMLiveUserList *)liveusers didFailUpdateWithError:(NSError *)error {
    NSLog(@"HelloWorldViewController:liveUserList:didFailUpdateWithError %@", [error description]);
}

// Invited user list callbacks
- (void)invitedUserListDidUpdate:(MMLiveUserList *)invitedusers {
     NSLog(@"HelloWorldViewController:invitedUserListDidUpdate: %@", [invitedusers json]);
}

- (void)invitedUserList:(MMInvitedUserList *)invitedusers didFailUpdateWithError:(NSError *)error {
    NSLog(@"HelloWorldViewController:invitedUserList:didFailUpdateWithError %@", [error description]);
}

@end
