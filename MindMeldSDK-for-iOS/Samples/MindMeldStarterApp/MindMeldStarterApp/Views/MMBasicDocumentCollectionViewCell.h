//
//  MMBasicDocumentCollectionViewCell.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 10/6/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "MMDocumentCollectionViewCell.h"

@interface MMBasicDocumentCollectionViewCell : MMDocumentCollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet UILabel *leftDetailLabel1;
@property (nonatomic, weak) IBOutlet UILabel *leftDetailLabel2;

@property (nonatomic, weak) IBOutlet UILabel *rightDetailLabel1;
@property (nonatomic, weak) IBOutlet UILabel *rightDetailLabel2;

@end

