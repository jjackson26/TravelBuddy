//
//  MMActivityIndicatorView.h
//  MindMeldVoice
//
//  Created by J.J. Jackson on 3/1/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMActivityIndicatorView : UIView

- (void)showInView:(UIView *)view
          animated:(BOOL)animated;
- (void)hide:(BOOL)animated;

@end
