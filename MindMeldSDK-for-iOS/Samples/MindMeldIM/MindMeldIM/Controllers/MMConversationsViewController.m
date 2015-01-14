//
//  MMConversationsViewController.m
//  MindMeld IM
//
//  Created by Juan Rodriguez on 2/24/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMConversationsViewController.h"
#import "MMConversationViewController.h"
#import "MMConstants.h"

@interface MMConversationsViewController ()

@property (nonatomic, readonly) NSArray *mindMeldSessions;

@end

@implementation MMConversationsViewController

// In this init method for this view controller, we will initialize the MindMeld iOS SDK, and get a user token from the API.
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Start SDK
        [self createMindMeld];
        [self authenticateMindMeld];
    }
    return self;
}

- (void)createMindMeld {
    // Here we create the MMApp object, all we need id the App ID. This ID is given to you when you sign up for using our API in the MindMeld Developer Center.
    MMApp *mmApp = [[MMApp alloc] initWithAppID:kMindMeldAppID];

    // We'll use this view controller as the delegate of the MMApp object.
    mmApp.delegate = self;

    // We'll store the MMApp object here, since we need it for making other calls later to the MindMeld API.
    _mmApp = mmApp;
}

- (void)authenticateMindMeld {
    ////
    //1)
    ////
    /*
     * Now get a token from the MindMeld API. The token is needed for making all API calls. After the token is generated
     * and retrieved, the MMApp object will store it and will use it for all API calls, this happens under the hood.
     *
     * Here you can create an Admin Token, which means all API calls will be done on behalf of the admin of the App,
     * or you can create a user token, which means all calls will be made on behalf of the user.
     *
     * You can visit the MindMeld documentation to see what credentials you can use to authenticate a user. Here we
     * are using facebook credentials. For facebook, you need the user id and the user token. The simplest way to get
     * these credentials is by visiting the Facebook Graph API Explorer: : https://developers.facebook.com/tools/explorer/
     * If you want to authenticate end users, the best option is to use the Facebook iOS SDK, which can be used for
     * logging to facebook, and easily retrieving user facebook tokens and ids.
     */
    NSDictionary *userCredentials = @{ @"facebook": @{ @"userid": kFacebookUserID,
                                                       @"token": kFacebookUserToken } };

    typeof(self) __weak weakSelf = self;
    MMSuccessHandler successHandler = ^(NSDictionary *response) {
        ////
        //2)
        ////
        /*
         * On success, we set the active user to be the user we just authenticated. This means all endpoints that
         * contain a userid will be called with this user id. After the active user is set, the callback method
         * activeUserDidUpdate: will be called, so the code continues there.
         */
        NSLog(@"User is: %@", response);
        weakSelf.mmApp.activeUserID = response[@"data"][@"user"][@"userid"];
    };
    MMFailureHandler failureHandler = ^(NSError *error) {
        NSLog(@"User did not authenticate: %@", [error description]);
    };
    [self.mmApp getToken:userCredentials
               onSuccess:successHandler
               onFailure:failureHandler];

}

- (void)loadView {
    MMConversationsScrollView *scrollView = [[MMConversationsScrollView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    scrollView.sessionViewDelegate = self;
    self.view = self.scrollView = scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"MindMeld IM";
}

#pragma mark - MMApp delegate methods

////
//3)
////
// When the active user is updated, we ask for the sessions of this user to be reloaded.
- (void)activeUserDidUpdate:(MMUser *)user {
    MMConversationsScrollView *scrollView = self.scrollView;
    MMSuccessHandler successHandler = ^(NSArray *response) {
        // When the sessions update, we also update the UI.
        [scrollView updateWithSessions:response];
    };
    MMFailureHandler failureHandler = ^(NSError *error) {
        NSLog(@"Error is: %@", error.localizedDescription);
    };
    [self.mmApp.activeUser.sessions getWithParams:nil
                                        onSuccess:successHandler
                                        onFailure:failureHandler];
}

#pragma mark - MMSessionView delegate methods

////
//4)
////
// This method is called when a session view is tapped, here we open up an MMConversationViewController with
// the session that has been tapped.
- (void)sessionViewTapped:(MMSessionView *)sessionView {
    // Start a MMConversationViewController.
    MMConversationViewController *conversationViewController = [[MMConversationViewController alloc] init];
    conversationViewController.mmApp = self.mmApp;
    conversationViewController.mmApp.delegate = conversationViewController;
    conversationViewController.session = sessionView.json;
    conversationViewController.automaticallyAdjustsScrollViewInsets = NO;
    [conversationViewController updateSession];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:conversationViewController];
    navigationController.view.backgroundColor = [UIColor whiteColor];
    // Present the new view controller.
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

@end
