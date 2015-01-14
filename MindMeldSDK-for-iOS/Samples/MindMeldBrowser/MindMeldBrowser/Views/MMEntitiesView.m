//
//  MMEntitiesView.m
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMEntitiesView.h"

@implementation MMEntitiesView

@synthesize entitesScrollView = _entitesScrollView;


// Here we just start this view, and all the subviews contained inside.
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Create the messages scroll view
        CGRect r = CGRectMake(0, 0, frame.size.width, frame.size.height);
        MMEntitiesScrollView *esv = [[MMEntitiesScrollView alloc] initWithFrame:r];
        [self addSubview:esv];
        self.entitesScrollView = esv;
    }
    return self;
}

@end
