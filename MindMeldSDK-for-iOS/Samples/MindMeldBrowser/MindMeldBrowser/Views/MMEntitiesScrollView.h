//
//  MMEntitiesScrollView.h
//  MindMeld IM
//
//  Created by Juan on 2/20/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMEntityView.h"

/**
 *  This is the scroll view that contains the list of available entities.
 */
@interface MMEntitiesScrollView : UIScrollView

@property (nonatomic, strong) NSMutableArray *entitieViews;

- (void)updateWithEntities:(NSArray *)entities;

@end
