//
//  AttractionTableViewCell.h
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/14/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttractionTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *rankLabel;
@property (nonatomic, weak) IBOutlet UITextView *descriptionText;

- (void)useDocument:(NSDictionary *)dictionary;

@end
