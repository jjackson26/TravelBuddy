//
//  MMEntityView.h
//  MindMeld IM
//
//  Created by Juan Rodriguez on 2/24/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This view represents one entity in the list of entities.
 */
@interface MMEntityView : UIView

@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) UILabel *textView;

+ (CGSize)calculateSize;
- (void)updateWithDict:(NSDictionary *)dict;

@end
