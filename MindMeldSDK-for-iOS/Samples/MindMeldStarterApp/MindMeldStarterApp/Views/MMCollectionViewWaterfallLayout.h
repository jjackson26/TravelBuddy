//
//  MMCollectionViewWaterfallLayout.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "CHTCollectionViewWaterfallLayout.h"

@protocol MMCollectionViewDataSourceWaterfallLayout <UICollectionViewDataSource>

- (id)itemIdentifierAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol MMCollectionViewDelegateWaterfallLayout <CHTCollectionViewDelegateWaterfallLayout>

- (BOOL)includeItemAtIndexPathInLayout:(NSIndexPath *)indexPath;

@end

@interface MMCollectionViewWaterfallLayout : CHTCollectionViewWaterfallLayout

@end
