//
//  UIAlertView+MindMeldVoice.h
//  MindMeldVoice
//
//  Created by J.J. Jackson on 3/1/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (MindMeldVoice)

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message;
+ (void)showErrorAlert:(NSString *)message;
+ (void)showWarningAlert:(NSString *)message;

@end