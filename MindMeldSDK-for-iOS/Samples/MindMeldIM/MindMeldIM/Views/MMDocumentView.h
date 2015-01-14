//
//  MMDocument.h
//  MindMeld IM
//
//  Created by Juan on 2/20/14.
//  Copyright (c) 2014 Juan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This view represents one message in the list of messages.
 */
@interface MMDocumentView : UIView

@property (nonatomic, strong) UITextView *titleView;
@property (nonatomic, strong) UITextView *textView;

+ (CGSize)calculateSize;
- (void)updateWithDict:(NSDictionary *)dict;

@end
