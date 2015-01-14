//
//  MMSessionView.h
//  MindMeld IM
//
//  Created by Juan Rodriguez on 2/24/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMSessionView;
// We create a protocol to send UI events back to the view controller
@protocol MMSessionViewDelegate <NSObject>
- (void)sessionViewTapped:(MMSessionView*)sessionView;
@end

/**
 *  This view represents one conversation in the list of sessions.
 */
@interface MMSessionView : UIView

@property (nonatomic, strong) id <MMSessionViewDelegate> sessionViewDelegate;
@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) UILabel *nameView;

+ (CGSize)calculateSize;
- (void)updateWithDict:(NSDictionary *)dict;

@end
