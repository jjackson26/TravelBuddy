//
//  MMCollectionViewDataSource.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/20/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// interface
#import "MMCollectionViewDataSource.h"

// models
#import "TLIndexPathItem.h"
#import "TLIndexPathDataModel.h"

@interface MMCollectionViewDataSource ()

@property (nonatomic, strong) TLIndexPathUpdates *currentUpdates;
@property (nonatomic, readonly) TLIndexPathDataModel *currentDataModel;

@property (nonatomic, strong) TLIndexPathDataModel *originalDataModel;
@property (nonatomic, strong) TLIndexPathDataModel *deletingDataModel;
@property (nonatomic, strong) TLIndexPathDataModel *movingDataModel;
@property (nonatomic, strong) TLIndexPathDataModel *updatedDataModel;

@end

@implementation MMCollectionViewDataSource


#pragma mark - Lifecycle

- (instancetype)initWithDataModel:(TLIndexPathDataModel *)dataModel;
{
    self = [super init];
    if (self) {
        self.originalDataModel = dataModel;
    }
    return self;
}


#pragma mark - interface

- (void)prepareForIndexPathUpdates:(TLIndexPathUpdates *)updates
{
    self.currentUpdates = updates;
    self.updatedDataModel = self.currentUpdates.updatedDataModel;

    NSMutableArray *items;
    if (updates.movedItems.count == 0) {
        self.deletingDataModel = [[TLIndexPathDataModel alloc] initWithItems:@[]];
        self.movingDataModel = self.deletingDataModel;
    } else {
        items = [NSMutableArray arrayWithArray:self.originalDataModel.items];
        [items addObjectsFromArray:self.currentUpdates.insertedItems];
        self.deletingDataModel = [[TLIndexPathDataModel alloc] initWithItems:items];

        items = [NSMutableArray arrayWithArray:self.updatedDataModel.items];
        [items addObjectsFromArray:self.currentUpdates.deletedItems];
        self.movingDataModel = [[TLIndexPathDataModel alloc] initWithItems:items];
    }
}

- (void)finishUpdates
{
    self.originalDataModel = self.updatedDataModel;
    self.updatedDataModel = self.deletingDataModel = self.movingDataModel = nil;
    self.updatePhase = MMCollectionViewUpdatePhaseNone;
    self.currentUpdates = nil;
}

- (TLIndexPathItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.currentDataModel itemAtIndexPath:indexPath];
}

- (TLIndexPathUpdates *)updatesForCurrentPhase
{
    return [[TLIndexPathUpdates alloc] initWithOldDataModel:self.fromDataModel
                                           updatedDataModel:self.toDataModel];
}

#pragma mark - properties

- (TLIndexPathDataModel *)currentDataModel
{
    switch (self.updatePhase) {
        case MMCollectionViewUpdatePhaseNone:
            return self.originalDataModel;
        case MMCollectionViewUpdatePhaseDeletions:
            return self.deletingDataModel;
        case MMCollectionViewUpdatePhaseMovements:
            return self.movingDataModel;
        case MMCollectionViewUpdatePhaseInsertions:
            return self.updatedDataModel;
        default:
            return self.originalDataModel;
    }
}

- (TLIndexPathDataModel *)fromDataModel
{
    switch (self.updatePhase) {
        case MMCollectionViewUpdatePhaseNone:
        case MMCollectionViewUpdatePhaseDeletions:
            return self.originalDataModel;
        case MMCollectionViewUpdatePhaseMovements:
            return self.deletingDataModel;
        case MMCollectionViewUpdatePhaseInsertions:
            return self.movingDataModel;
        default:
            return self.originalDataModel;
    }
}

- (TLIndexPathDataModel *)toDataModel
{
    return self.currentDataModel;
}


#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.currentDataModel.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.currentDataModel numberOfRowsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellCreationBlock) {
        UICollectionViewCell *cell = self.cellCreationBlock(collectionView, indexPath);
        if (self.cellConfigurationBlock) {
            self.cellConfigurationBlock(collectionView, cell, indexPath);
        }
        return cell;
    }
    return nil;
}

#pragma mark - MMCollectionViewDelegateWaterfallLayout

- (BOOL)includeItemAtIndexPathInLayout:(NSIndexPath *)indexPath
{
    TLIndexPathItem *item = [self itemAtIndexPath:indexPath];
    switch (self.updatePhase) {
        case MMCollectionViewUpdatePhaseNone:
            return YES;
        case MMCollectionViewUpdatePhaseDeletions:
        case MMCollectionViewUpdatePhaseMovements: // inserted and deleted items should not be shown
            return !([self.currentUpdates.deletedItems containsObject:item] ||
                     [self.currentUpdates.insertedItems containsObject:item]);
        case MMCollectionViewUpdatePhaseInsertions: // deleted items should not be shown
            return ![self.currentUpdates.deletedItems containsObject:item];
        default:
            return YES;
            break;
    }
}

@end
