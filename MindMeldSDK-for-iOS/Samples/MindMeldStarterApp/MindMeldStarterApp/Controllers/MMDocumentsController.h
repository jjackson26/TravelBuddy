//
//  MMDocumentsController.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/6/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

// superclass
#import "TLCollectionViewController.h"

// views
#import "MMCollectionViewWaterfallLayout.h"

// types
#import <MindMeldSDK/MMBlockTypes.h>

@interface MMDocumentsController : TLCollectionViewController <MMCollectionViewDataSourceWaterfallLayout, MMCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) NSArray *documents;
@property (nonatomic, assign) BOOL displayAsChannels;

@property (nonatomic, copy) MMSuccessHandler onDocumentSelected;
@property (nonatomic, copy) MMSuccessHandler onDocumentDeselected;

@property (nonatomic, assign) UIEdgeInsets contentInset;

+ (instancetype)controller;

@end
