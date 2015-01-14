//
//  MMCollectionViewWaterfallLayout.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// interface
#import "MMCollectionViewWaterfallLayout.h"

// models
#import "TLIndexPathItem.h"
#import "TLIndexPathUpdates.h"

@interface CHTCollectionViewWaterfallLayout (Subclass)

@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;

@end

@interface MMCollectionViewWaterfallLayout ()

@property (nonatomic, weak) id <MMCollectionViewDelegateWaterfallLayout> mmDelegate;
@property (nonatomic, weak) id <MMCollectionViewDataSourceWaterfallLayout> dataSource;

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;
@property (nonatomic, strong) NSMutableArray *movedFromIndexPaths;
@property (nonatomic, strong) NSMutableArray *movedToIndexPaths;

@property (nonatomic, strong) TLIndexPathDataModel *originalDataModel;
@property (nonatomic, strong) TLIndexPathDataModel *deletionsDataModel;
@property (nonatomic, strong) TLIndexPathDataModel *movementsDataModel;
@property (nonatomic, strong) TLIndexPathDataModel *updatedDataModel;

@property (nonatomic, strong) NSMutableDictionary *itemAttributes;

@end

@implementation MMCollectionViewWaterfallLayout

#pragma mark - lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self MM_initializeWaterfallLayout];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self MM_initializeWaterfallLayout];
    }
    return self;
}

- (void)MM_initializeWaterfallLayout
{
    // leaving this here for now
}


#pragma mark - properties

- (id <MMCollectionViewDelegateWaterfallLayout>)mmDelegate
{
    return (id <MMCollectionViewDelegateWaterfallLayout>)self.collectionView.delegate;
}

- (id <MMCollectionViewDataSourceWaterfallLayout>)dataSource
{
    return (id <MMCollectionViewDataSourceWaterfallLayout>)self.collectionView.dataSource;
}

- (NSMutableDictionary *)itemAttributes
{
    if (!_itemAttributes) {
        _itemAttributes = [NSMutableDictionary dictionary];
    }
    return _itemAttributes;
}


#pragma mark - layout


- (void)prepareLayout
{
    [super prepareLayout];

    // TODO: figure out why the below is necessary
    NSInteger sectionIndex, itemIndex;
    NSMutableArray *sectionItems;
    NSIndexPath *indexPath;
    UICollectionViewLayoutAttributes *layoutAttributes;
    for (sectionIndex = 0; sectionIndex < self.sectionItemAttributes.count; sectionIndex++) {
        sectionItems = self.sectionItemAttributes[sectionIndex];
        for (itemIndex = 0; itemIndex < sectionItems.count; itemIndex++) {
            indexPath = [NSIndexPath indexPathForItem:itemIndex
                                            inSection:sectionIndex];
            layoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            id identifier = [self.dataSource itemIdentifierAtIndexPath:indexPath];
            if (identifier) {
                self.itemAttributes[identifier] = layoutAttributes;
            }
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];

    if (![self.mmDelegate includeItemAtIndexPathInLayout:indexPath]) {
        layoutAttributes.alpha = 0.0;
    }

    return layoutAttributes;
}

#pragma mark - animations

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];

    NSMutableArray *inserted = [NSMutableArray array];
    NSMutableArray *deleted = [NSMutableArray array];
    NSMutableArray *movedFrom = [NSMutableArray array];
    NSMutableArray *movedTo = [NSMutableArray array];

    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        switch (updateItem.updateAction) {
            case UICollectionUpdateActionInsert:
                [inserted addObject:updateItem.indexPathAfterUpdate];
                break;
            case UICollectionUpdateActionDelete:
                [deleted addObject:updateItem.indexPathBeforeUpdate];
                break;
            case UICollectionUpdateActionMove:
                [movedFrom addObject:updateItem.indexPathBeforeUpdate];
                [movedTo addObject:updateItem.indexPathAfterUpdate];
                break;
            default:
                NSLog(@"unhandled case: %@", updateItem);
                break;
        }
    }
    self.insertedIndexPaths = inserted;
    self.deletedIndexPaths = deleted;
    self.movedFromIndexPaths = movedFrom;
    self.movedToIndexPaths = movedTo;
}

@end
