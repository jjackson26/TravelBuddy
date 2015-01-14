//
//  MMMicrophoneButton.h
//  MindMeldVoice
//
//  Created by J.J. Jackson on 17/09/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ENUM(NSUInteger, MMMicrophoneButtonState) {
    MMMicrophoneButtonStateIdle,
    MMMicrophoneButtonStatePending,
    MMMicrophoneButtonStateRecording,
    MMMicrophoneButtonStateProcessing
};

/**
 *  The microphone button is a special button that indicates the state of recording audio.
 *  While recording, a volume indicator will give feedback indicating the audio being recorded.
 *  While processing audio, a ring will rotate along the border of the button.
 */
@interface MMMicrophoneButton : UIControl

@property (nonatomic, assign) enum MMMicrophoneButtonState microphoneState;
@property (nonatomic, assign) CGFloat volumeLevel;

/**
 *  The button's default background color.
 */
@property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

/**
 *  The button's background color while recording.
 */
@property (nonatomic, strong) UIColor *activeBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 *  The button's background color while highlighted.
 */
@property (nonatomic, strong) UIColor *highlightedBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 *  The button's default icon color.
 */
@property (nonatomic, strong) UIColor *iconColor UI_APPEARANCE_SELECTOR;

/**
 *  The button's icon color while recording.
 */
@property (nonatomic, strong) UIColor *activeIconColor UI_APPEARANCE_SELECTOR;

/**
 *  The button's icon color while highlighted.
 */
@property (nonatomic, strong) UIColor *highlightedIconColor UI_APPEARANCE_SELECTOR;

/**
 *  The button's default border color.
 */
@property (nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;

/**
 *  The button's border color while highlighted.
 */
@property (nonatomic, strong) UIColor *highlightedBorderColor UI_APPEARANCE_SELECTOR;

/**
 *  The color of the button's animated recording indicator.
 */
@property (nonatomic, strong) UIColor *activeBorderColor UI_APPEARANCE_SELECTOR;

/**
 *  The color of the glow of the button's animated recording indicator.
 */
@property (nonatomic, strong) UIColor *activeBorderGlowColor UI_APPEARANCE_SELECTOR;

/**
 *  The color of the button's volume indicator.
 */
@property (nonatomic, strong) UIColor *volumeColor UI_APPEARANCE_SELECTOR;

- (void)sendAction:(SEL)action
                to:(id)target
          forEvent:(UIEvent *)event;


@end
