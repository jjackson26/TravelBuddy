//
//  MMBrowserView.h
//  MindMeld Browser
//
//  Created by Juan Rodriguez on 2/27/14.
//  Copyright (c) 2014 Regio Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMBrowserScrollView.h"

@interface MMBrowserView : UIView

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) MMBrowserScrollView *browserScrollView;

@end
