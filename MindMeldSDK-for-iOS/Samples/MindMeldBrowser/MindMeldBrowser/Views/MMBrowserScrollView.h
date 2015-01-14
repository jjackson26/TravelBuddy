//
//  MMBrowserScrollView.h
//  MindMeld Browser
//
//  Created by Juan Rodriguez on 2/27/14.
//  Copyright (c) 2014 Regio Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMBrowser.h"
#import "MMEntitiesScrollView.h"

@interface MMBrowserScrollView : UIScrollView

@property (nonatomic, strong) MMBrowser *browser;
@property (nonatomic, strong) MMEntitiesScrollView *entitiesScrollView;

@end
