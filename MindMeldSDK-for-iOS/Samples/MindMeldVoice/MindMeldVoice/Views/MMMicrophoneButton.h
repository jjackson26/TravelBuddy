//
//  MMMicrophoneButton.h
//  MindMeldVoice
//
//  Created by J.J. Jackson on 17/09/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMMicrophoneButton : UIButton

@property (nonatomic, assign) CGFloat volumeLevel;
@property (nonatomic, assign) BOOL recording;

@property (nonatomic, strong) UIColor *iconColor;
@property (nonatomic, strong) UIColor *recordingBackgroundColor;
@property (nonatomic, strong) UIColor *accentColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *volumeColor;

@end
