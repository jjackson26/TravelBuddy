//
//  MMDocumentsController.m
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/6/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// interface
#import "MMDocumentsController.h"

// models
#import "MMCollectionViewDataSource.h"
#import "TLIndexPathItem.h"

// views
#import "MMDocumentCollectionViewCell.h"
#import "MMBasicDocumentCollectionViewCell.h"

// utilities
#import <SDWebImage/SDWebImageManager.h>

static const NSUInteger kNumColumns = 4;
static const CGFloat kEdgeInset = 48.0;
static const CGFloat kInteritemSpacing = 32.0;
static const CGFloat kDefaultLayerSpeed = 0.5;

static const NSUInteger kItemSizeCacheCountLimit = 100;

static NSString *const kCellReuseIdentifier = @"BasicCell";

@interface TLIndexPathItem (MMDocument)

+ (instancetype)indexPathItemWithDocument:(id)json
                           cellIdentifier:(NSString *)cellIdentifier;

@end

@interface MMDocumentsController ()

@property (nonatomic, strong) MMBasicDocumentCollectionViewCell *sizingCell;

@property (nonatomic, strong) MMCollectionViewWaterfallLayout *waterfallLayout;
@property (nonatomic, strong) MMCollectionViewDataSource *dataSource;

/**
 *  This cache is used to speed up the layout calculation process. Calculating the display size of documents
 *  is expensive due to the dynamic data. This improves scroll performance.
 */
@property (nonatomic, strong) NSCache *itemSizeCache;

@property (nonatomic, copy) void (^onCollectionViewUpdatesCompleted)();

@end

@implementation MMDocumentsController

#pragma mark - lifecycle

+ (instancetype)controller
{
    MMDocumentsController *controller = [[self alloc] init];
    return controller;
}

+ (MMCollectionViewWaterfallLayout *)waterfallLayout
{
    MMCollectionViewWaterfallLayout *waterfallLayout = [[MMCollectionViewWaterfallLayout alloc] init];
    waterfallLayout.columnCount = kNumColumns;
    waterfallLayout.sectionInset = UIEdgeInsetsMake(0, kEdgeInset, 0, kEdgeInset);
    waterfallLayout.minimumColumnSpacing = kInteritemSpacing;
    waterfallLayout.minimumInteritemSpacing = kInteritemSpacing;
    return  waterfallLayout;
}

- (instancetype)init
{
    self = [super initWithCollectionViewLayout:[[self class] waterfallLayout]];
    if (self) {
        [self initializeDocumentsController];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        [self initializeDocumentsController];
    }
    return self;
}

- (void)initializeDocumentsController
{
    self.documents = [NSArray array];

    self.dataSource = [[MMCollectionViewDataSource alloc] initWithDataModel:self.indexPathController.dataModel];

    self.waterfallLayout = (MMCollectionViewWaterfallLayout *)self.collectionViewLayout;
}


#pragma mark - view lifecycle

- (void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];

    self.collectionView.viewForBaselineLayout.layer.speed = kDefaultLayerSpeed;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    /**
     *  Specify the type of cell we are using to display documents
     */
    UINib *cellNib = [UINib nibWithNibName:@"MMBasicDocumentCollectionViewCell"
                                    bundle:nil];

    // This sizing cell will allow was to calculate the
    self.sizingCell = [cellNib instantiateWithOwner:nil options:nil].firstObject;

    [self.collectionView registerNib:cellNib
          forCellWithReuseIdentifier:kCellReuseIdentifier];
}


#pragma mark - properties

- (NSCache *)itemSizeCache
{
    if (!_itemSizeCache) {
        _itemSizeCache = [[NSCache alloc] init];
        _itemSizeCache.countLimit = kItemSizeCacheCountLimit;
    }
    return _itemSizeCache;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    self.collectionView.contentInset = contentInset;
}

- (UIEdgeInsets)contentInset
{
    return self.collectionView.contentInset;
}

- (void)setDocuments:(NSArray *)documents
{
    _documents = documents;

    typeof(self) __weak weakSelf = self;
    NSString *cellIdentifier = kCellReuseIdentifier;

    // Queue the update if another update is in progress.
    self.onCollectionViewUpdatesCompleted = ^{
        NSMutableArray *items = [NSMutableArray array];
        for (NSDictionary *document in documents) {

            TLIndexPathItem *item = [TLIndexPathItem indexPathItemWithDocument:document
                                                                cellIdentifier:cellIdentifier];
            [weakSelf collectionView:weakSelf.collectionView
                              layout:weakSelf.collectionViewLayout
                         sizeForItem:item];
            [items addObject:item];
        }

        weakSelf.indexPathController.items = [NSArray arrayWithArray:items];
        weakSelf.onCollectionViewUpdatesCompleted = nil;
    };

    // If no update is in progress, execute now
    if (self.dataSource.updatePhase == MMCollectionViewUpdatePhaseNone) {
        self.onCollectionViewUpdatesCompleted();
    }
}


#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSource numberOfSectionsInCollectionView:collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource collectionView:collectionView
                    numberOfItemsInSection:section];
}

- (NSString *)collectionView:(UICollectionView *)collectionView
   cellIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellReuseIdentifier;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self collectionView:collectionView cellIdentifierAtIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                           forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }

    [self collectionView:collectionView configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
         configureCell:(UICollectionViewCell *)cell
           atIndexPath:(NSIndexPath *)indexPath
{
    TLIndexPathItem *item = [self.dataSource itemAtIndexPath:indexPath];
    [self collectionView:collectionView configureCell:cell withItem:item];
}

- (void)collectionView:(UICollectionView *)collectionView
         configureCell:(UICollectionViewCell *)cell
              withItem:(TLIndexPathItem *)item
{
    MMDocumentCollectionViewCell *theCell = (MMDocumentCollectionViewCell *)cell;
    theCell.documentJSON = item.data;

    theCell.image = nil;
    NSString *imageURLString = item.data[@"image"][@"url"];
    if (imageURLString && [imageURLString isKindOfClass:[NSString class]]) {
        void (^setCellImage)(UIImage *, BOOL) = ^(UIImage *image, BOOL animated) {
            [theCell setImage:image
                     animated:animated];
        };

        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        UIImage *image = nil;

        // Look for the image in the cache
        if([[SDWebImageManager sharedManager] cachedImageExistsForURL:imageURL]) {
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:imageURL];
            image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
            if (!image) {
                image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
            }
        }

        if (image) {
            // If we have the image cached, apply it now
            setCellImage(image, NO);
        } else {
            // Otherwise fetch the image
            SDWebImageCompletionWithFinishedBlock completion = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    setCellImage(image, YES); // if there is an image, apply it
                } else {
                    [theCell usePlaceholderImage]; // if there is no image, use the placeeholder
                }
            };

            [theCell showImagePending];
            [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL
                                                            options:0
                                                           progress:nil
                                                          completed:completion];
        }
    } else {
        [theCell usePlaceholderImage]; // no image url, use the place holder
    }
}


#pragma mark - MMCollectionViewDataSourceWaterfallLayout

- (id)itemIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    TLIndexPathItem *item = [self.dataSource itemAtIndexPath:indexPath];
    return item.identifier;
}


#pragma mark - UICollectionViewDelegate

-      (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-  (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.onDocumentSelected) {
        MMDocumentCollectionViewCell *cell;
        cell = (MMDocumentCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        self.onDocumentSelected(cell.documentJSON);
    }
}

-        (BOOL)collectionView:(UICollectionView *)collectionView
shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-     (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.onDocumentDeselected) {
        MMDocumentCollectionViewCell *cell;
        cell = (MMDocumentCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        self.onDocumentDeselected(cell.documentJSON);
    }
}


#pragma mark - MMCollectionViewDelegateWaterfallLayout

- (UICollectionViewCell *)sizingCellWithItem:(TLIndexPathItem *)item
{
    UICollectionViewCell *sizingCell = self.sizingCell;
    return sizingCell;
}

- (CGFloat)heightForCellWithItem:(TLIndexPathItem *)item
{
    UICollectionViewCell *sizingCell = [self sizingCellWithItem:item];
    [self collectionView:self.collectionView
           configureCell:sizingCell
                withItem:item];
    CGFloat height = [self calculateHeightForConfiguredSizingCell:sizingCell];
    return height;
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UICollectionViewCell *)sizingCell
{
    CGRect sizingBounds = sizingCell.bounds;
    sizingBounds.size.width = [self.waterfallLayout itemWidthInSectionAtIndex:0];
    sizingBounds.size.height = MAX(sizingBounds.size.height, 50);
    sizingCell.bounds = sizingBounds;
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];

    return sizingCell.intrinsicContentSize.height;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TLIndexPathItem *item = [self.dataSource itemAtIndexPath:indexPath];

    return [self collectionView:collectionView layout:collectionViewLayout sizeForItem:item];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
             sizeForItem:(TLIndexPathItem *)item
{
    CGSize size;

    id identifier = item.identifier;
    NSValue *value = nil;
    if (identifier) {
        value = [self.itemSizeCache objectForKey:item.identifier];
    }
    if (value) {
        [value getValue:&size];
    } else {
        CGFloat width = [self.waterfallLayout itemWidthInSectionAtIndex:0];
        CGFloat height = [self heightForCellWithItem:item];
        size = CGSizeMake(width, height);

        if (identifier) {
            [self.itemSizeCache setObject:[NSValue valueWithCGSize:size]
                                   forKey:item.identifier];
        }
    }

    return size;
}

- (BOOL)includeItemAtIndexPathInLayout:(NSIndexPath *)indexPath
{
    return [self.dataSource includeItemAtIndexPathInLayout:indexPath];
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller
didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [self.collectionView setContentOffset:CGPointMake(-self.contentInset.left, -self.contentInset.top)
                                 animated:YES];

    // only perform batch updates if view is visible
    if (self.isViewLoaded && self.view.window) {
        if (updates.oldDataModel.items.count == 0 &&
            updates.updatedDataModel.items.count == 0) {
            return;
        }

        typeof(self) __weak weakSelf = self;
        if (updates.oldDataModel.items.count == 0 ||
            updates.updatedDataModel.items.count == 0) {
            // this is a one phase transition, so call prepare performCollectionViewUpdates directly
            [self.dataSource prepareForIndexPathUpdates:updates];
            [self.dataSource finishUpdates];
            [self beginCollectionViewUpdates];
            [self performCollectionViewUpdates:updates
                                    completion:^(BOOL finished){ [weakSelf finishCollectionViewUpdates]; }];
        } else {
            void (^insertCompletion)(BOOL) = ^(BOOL finished) {
                weakSelf.dataSource.updatePhase = MMCollectionViewUpdatePhaseNone;
                [weakSelf.dataSource finishUpdates];

                [weakSelf finishCollectionViewUpdates];
            };

            void (^moveCompletion)(BOOL) = ^(BOOL finished) {
                [weakSelf performCollectionViewUpdatesForPhase:MMCollectionViewUpdatePhaseInsertions
                                                    completion:insertCompletion];
            };

            void (^deleteCompletion)(BOOL) = ^(BOOL finished) {
                if (updates.movedItems.count == 0) {
                    // this is a two phase transition, so skip the movement phase
                    moveCompletion(finished);
                } else {
                    [weakSelf performCollectionViewUpdatesForPhase:MMCollectionViewUpdatePhaseMovements
                                                        completion:moveCompletion];
                }
            };

            [self.dataSource prepareForIndexPathUpdates:updates];
            [self beginCollectionViewUpdates];
            [self performCollectionViewUpdatesForPhase:MMCollectionViewUpdatePhaseDeletions
                                            completion:deleteCompletion];
        }
    } else {
        [self.collectionView reloadData];
    }
}

- (void)performCollectionViewUpdatesForPhase:(enum MMCollectionViewUpdatePhase)updatePhase
                                  completion:(void (^)(BOOL))completion
{
    self.dataSource.updatePhase = updatePhase;
    [self performCollectionViewUpdates:[self.dataSource updatesForCurrentPhase]
                            completion:completion];
}

- (void)performCollectionViewUpdates:(TLIndexPathUpdates *)updates
                          completion:(void (^)(BOOL))completion
{
    [self.collectionView performBatchUpdates:^{
        if (updates.deletedItems.count) {
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (id item in updates.deletedItems) {
                NSIndexPath *indexPath = [updates.oldDataModel indexPathForItem:item];
                [indexPaths addObject:indexPath];
            }
            [self.collectionView deleteItemsAtIndexPaths:indexPaths];
        }

        for (id item in updates.movedItems) {
            NSIndexPath *oldIndexPath = [updates.oldDataModel indexPathForItem:item];
            NSIndexPath *updatedIndexPath = [updates.updatedDataModel indexPathForItem:item];
            [self.collectionView moveItemAtIndexPath:oldIndexPath
                                         toIndexPath:updatedIndexPath];
        }

        if (updates.insertedItems.count) {
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (id item in updates.insertedItems) {
                NSIndexPath *indexPath = [updates.updatedDataModel indexPathForItem:item];
                [indexPaths addObject:indexPath];
            }
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
        }
    } completion:completion];
}

- (void)beginCollectionViewUpdates
{
    self.view.userInteractionEnabled = NO;
}

- (void)finishCollectionViewUpdates
{
    self.view.userInteractionEnabled = YES;

    if (self.onCollectionViewUpdatesCompleted) {
        self.onCollectionViewUpdatesCompleted();
    }
}


@end

#pragma mark - TLIndexPathItem category

@implementation TLIndexPathItem (MMDocument)

+ (instancetype)indexPathItemWithDocument:(id)documentJSON
                           cellIdentifier:(NSString *)cellIdentifier
{
    NSString *documentID = documentJSON[@"documentid"];
    TLIndexPathItem *item = [[TLIndexPathItem alloc] initWithIdentifier:documentID
                                                            sectionName:nil
                                                         cellIdentifier:cellIdentifier
                                                                   data:documentJSON];
    return item;
}

@end