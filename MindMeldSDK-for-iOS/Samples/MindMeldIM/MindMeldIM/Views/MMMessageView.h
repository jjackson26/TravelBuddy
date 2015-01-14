//
//  MMessageView.h
//  MindMeld IM
//
//  Created by Juan on 2/19/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This view represents one message in the list of messages.
 */
@interface MMMessageView : UIView

@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) UITextView *textView;

+ (CGSize)calculateSizeForText:(NSString *)text;
- (void)updateWithDict:(NSDictionary *)dict;

@end
