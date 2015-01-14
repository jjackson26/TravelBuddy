//
//  MMVoiceSearchController.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "MMOverlayController.h"

#import <MindMeldSDK/MMBlockTypes.h>

// views
#import "MMActivityIndicatorView.h"
#import "MMVoiceSearchBarView.h"


/**
 *  The MMVoiceSearchController is an overlay controller for voice search. It contains a voice search bar which
 *  allows a user to use voice or keyboard to make search queries, and a results box which displays the results
 *  in a waterfall layout.
 */
@interface MMVoiceSearchController : MMOverlayController

@property (nonatomic, strong, readonly) MMActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong, readonly) MMVoiceSearchBarView *searchBarView;

/**
 *  This property determines whether or not the options button is avaiable.
 */
@property (nonatomic, assign) BOOL showOptionsButton;

/**
 *  Determines whether the listener should start recording as soon as this controller appears.
 */
@property (nonatomic, assign) BOOL listenOnAppear;

/**
 *  Determines the maximum number of documents to fetch and display.
 */
@property (nonatomic, assign) NSUInteger numDocuments;

/**
 *  The callback which will be invoked when a document is selected.
 */
@property (nonatomic, copy) MMSuccessHandler onDocumentSelected;

/**
 *  The callback which will be invoked when a document is deselected
 */
@property (nonatomic, copy) MMSuccessHandler onDocumentDeselected;

/**
 *  This is the app ID of the MindMeld App for which you would like to present documents
 */
@property (nonatomic, copy, readonly) NSString *mindMeldAppID;

+ (instancetype)controllerWithMindMeldAppID:(NSString *)mindMeldAppID;

- (instancetype)initWithMindMeldAppID:(NSString *)mindMeldAppID;

@end
