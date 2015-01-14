//
//  scrollView.h
//  MindMeld IM
//
//  Created by Juan on 2/20/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDocumentView.h"

/**
 *  This is the scroll view that contains the list of available documents.
 */
@interface MMDocumentsScrollView : UIScrollView

@property (nonatomic, retain) NSMutableArray *documentViews;

- (void)updateWithDocuments:(NSArray *)documents;

@end
