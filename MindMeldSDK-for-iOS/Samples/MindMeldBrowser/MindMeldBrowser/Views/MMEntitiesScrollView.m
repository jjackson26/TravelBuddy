//
//  MMEntitiesScrollView.m
//  MindMeld IM
//
//  Created by Juan on 2/20/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMEntitiesScrollView.h"

static const CGFloat kItemPadding = 10;

@implementation MMEntitiesScrollView

@synthesize entitieViews = _entitieViews;

// Here we just start this view, and all the subviews contained inside.
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialize the entities array
        NSMutableArray *entities = [NSMutableArray array];
        self.entitieViews = entities;
    }
    return self;
}

// This scroll view is responsible for updating it's subviews. In particular, it needs to
// update the entities it displays. This is the method that takes an array of entities
// and creates a view for each one of them.
- (void)updateWithEntities:(NSArray *)entities {
    // First remove all the entities
    [self.entitieViews removeAllObjects];
    
    // Now create a view for each entity
    for (NSDictionary *nextEntity in entities) {
        CGSize size = [MMEntityView calculateSize];
        MMEntityView *entityView = [[MMEntityView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [entityView updateWithDict:nextEntity];
        [self.entitieViews addObject:entityView];
    }

    // Now arrange the messages
    [self arrangeEntities];
}

// This methods takes all the views inside the scroll view and arranges them by order.
- (void)arrangeEntities {
    int index = 0;
    CGFloat y = 0;
    CGFloat w = 0;
    CGFloat h = 0;
    for (MMEntityView *entityView in self.entitieViews) {
        w = entityView.frame.size.width;
        h = entityView.frame.size.height;
        y = kItemPadding + (kItemPadding + entityView.frame.size.height)*index;
        entityView.frame = CGRectMake((self.frame.size.width - w) * 0.5, y, w, h);
        [self addSubview:entityView];

        index++;
    }

    // Set the content size of the scroll
    self.contentSize = CGSizeMake(self.frame.size.width, kItemPadding + (kItemPadding + h)*index);
}


@end
