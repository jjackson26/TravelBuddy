//
//  UIAlertView+MindMeldVoice.m
//  MindMeldVoice
//
//  Created by J.J. Jackson on 3/1/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "UIAlertView+MindMeldVoice.h"

@implementation UIAlertView (MindMeldVoice)

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message;
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

+ (void)showErrorAlert:(NSString *)message
{
    [self showAlertWithTitle:@"Error"
                     message:message];
}

+ (void)showWarningAlert:(NSString *)message
{
    [self showAlertWithTitle:@"Warning"
                     message:message];
}


@end
