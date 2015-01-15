//
//  AttractionTableViewCell.m
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/14/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import "AttractionTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation AttractionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)useDocument:(NSDictionary *)documentJson
{
    [self.backgroundImageView sd_setImageWithURL:documentJson[@"image"][@"url"]];
    self.titleLabel.text = documentJson[@"title"];
    self.rankLabel.text = [NSString stringWithFormat:@"#%@ in Paris", documentJson[@"rank_in_city"]];
    self.descriptionText.text = documentJson[@"description"];
}

@end
