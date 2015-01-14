//
//  MMDocumentsScrollView.m
//  MindMeld IM
//
//  Created by Juan on 2/20/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import "MMDocumentsScrollView.h"

static const CGFloat kDocumentVerticalPadding = 10;

@implementation MMDocumentsScrollView

// Here we just start this view, and all the subviews contained inside.
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialize the documents array
        NSMutableArray *docs = [NSMutableArray array];
        self.documentViews = docs;
    }
    return self;
}

// This scroll view is responsible for updating it's subviews. In particular, it needs to
// update the documents it displays. This is the method that takes an array of documents
// and creates a view for each one of them.
- (void)updateWithDocuments:(NSArray *)documents {
    // First remove all the documents
    [self.documentViews removeAllObjects];
    
    // Now create a view for each document
    for (NSDictionary *nextDocument in documents) {
        CGSize size = [MMDocumentView calculateSize];
        MMDocumentView *dv = [[MMDocumentView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [dv updateWithDict:nextDocument];
        [self.documentViews addObject:dv];
    }
    
    // Now arrange the messages
    [self arrangeDocuments];
}

// This methods takes all the views inside the scroll view and arranges them by order.
- (void)arrangeDocuments {
    NSInteger index = 0;
    for (MMDocumentView *documentView in self.documentViews) {
        CGRect frame = documentView.frame;
        CGFloat x = (self.frame.size.width - frame.size.width) / 2;
        CGFloat y = kDocumentVerticalPadding + (kDocumentVerticalPadding + documentView.frame.size.height) * index;
        CGPoint origin = CGPointMake(x, y);
        frame.origin = origin;
        documentView.frame = frame;
        [self addSubview:documentView];
        
        index++;
    }
    
    // Set the content size of the scroll
    CGFloat itemHeight = [self.documentViews.firstObject frame].size.height;
    CGFloat totalHeight = kDocumentVerticalPadding + (kDocumentVerticalPadding + itemHeight) * index;
    self.contentSize = CGSizeMake(self.frame.size.width, totalHeight);
}


@end
