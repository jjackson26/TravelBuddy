//
//  MMCollectionViewDataSource.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/20/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TLIndexPathController.h"

NS_ENUM(NSInteger, MMCollectionViewUpdatePhase) {
    MMCollectionViewUpdatePhaseNone = 0,
    MMCollectionViewUpdatePhaseDeletions,
    MMCollectionViewUpdatePhaseMovements,
    MMCollectionViewUpdatePhaseInsertions
};

typedef void (^MMCollectionViewDataSourceCellConfigurationBlock)(UICollectionView *collectionView,
                                                                 UICollectionViewCell *cell,
                                                                 NSIndexPath *indexPath);
typedef UICollectionViewCell *(^MMCollectionViewDataSourceCellCreationBlock)(UICollectionView *collectionView,
                                                                             NSIndexPath *indexPath);

@class TLIndexPathItem;

@interface MMCollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, assign) enum MMCollectionViewUpdatePhase updatePhase;

@property (nonatomic, copy) MMCollectionViewDataSourceCellConfigurationBlock cellConfigurationBlock;
@property (nonatomic, copy) MMCollectionViewDataSourceCellCreationBlock cellCreationBlock;


- (instancetype)initWithDataModel:(TLIndexPathDataModel *)dataModel;

- (void)prepareForIndexPathUpdates:(TLIndexPathUpdates *)updates;
- (void)finishUpdates;

- (TLIndexPathUpdates *)updatesForCurrentPhase;

- (TLIndexPathItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)includeItemAtIndexPathInLayout:(NSIndexPath *)indexPath;

@end

