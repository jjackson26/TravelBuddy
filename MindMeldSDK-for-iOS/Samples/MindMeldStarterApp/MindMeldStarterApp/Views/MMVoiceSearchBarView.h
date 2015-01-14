//
//  MMVoiceSearchView.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMicrophoneButton.h"

#import <MindMeldSDK/MMListener.h>

@interface MMVoiceSearchBarView : UIView

@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) MMMicrophoneButton *microphoneButton;

/**
 *  The search bar's background color.
 */
@property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

/**
 *  The search bar's background color.
 */
@property (nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;

/**
 *  The text displayed by the search bar.
 */
@property (nonatomic, copy) NSString *text;

/**
 *  The styled text displayed by the search bar.
 */
@property (nonatomic, copy) NSAttributedString *attributedText;

/**
 *  The string that is displayed when there is no other text in the search bar.
 */
@property (nonatomic, copy) NSString *placeholder;

/**
 *  The styled string that is displayed when there is no other text in the search bar.
 */
@property (nonatomic, copy) NSAttributedString *attributedPlaceholder;

/**
 *  A Boolean value indicating whether the text field is currently in edit mode. (read-only)
 */
@property (nonatomic, assign, readonly, getter=isEditing) BOOL editing;

// listener specifics the following properties.

@property (nonatomic, readonly) MMListener *listener;

// The following properties are handlers that are invoked the by search bar's listener. See MMListener for more information

@property (nonatomic, copy) MMListenerEventHandler onListenerStarted;
@property (nonatomic, copy) MMListenerEventHandler onListenerBeganRecording;
@property (nonatomic, copy) MMListenerEventHandler onListenerFinishedRecording;
@property (nonatomic, copy) MMListenerEventHandler onListenerFinished;
@property (nonatomic, copy) MMListenerErrorHandler onListenerError;
@property (nonatomic, copy) MMListenerVolumeChangeHandler onListenerVolumeChanged;
@property (nonatomic, copy) MMListenerResultHandler onListenerResult;

/**
 *  This block is called when the user submits text manually using either the search button or a return key.
 */
@property (nonatomic, copy) void (^onTextSubmitted)(NSString *text);

- (void)startListening;
- (void)stopListening;

@end
