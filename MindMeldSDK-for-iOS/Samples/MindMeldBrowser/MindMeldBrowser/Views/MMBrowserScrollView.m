//
//  MMBrowserScrollView.m
//  MindMeld Browser
//
//  Created by Juan Rodriguez on 2/27/14.
//  Copyright (c) 2014 Regio Systems. All rights reserved.
//

#import "MMBrowserScrollView.h"

@implementation MMBrowserScrollView

@synthesize entitiesScrollView = _entitiesScrollView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // Set the size of the content view and paging
        self.contentSize = CGSizeMake(2*frame.size.width, self.frame.size.height);
        self.pagingEnabled = YES;
        
        // Add the browser
        MMBrowser *br = [[MMBrowser alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:br];
        self.browser = br;
        
        // Add the entities scroll view
        MMEntitiesScrollView *esv = [[MMEntitiesScrollView alloc] initWithFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)];
        [self addSubview:esv];
        self.entitiesScrollView = esv;
    }
    return self;
}

@end
