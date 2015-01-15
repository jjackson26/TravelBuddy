//
//  Attraction.h
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/14/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Attraction : NSObject

+ (instancetype)attractionWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *description;
@property (nonatomic, readonly) CGFloat rating;
@property (nonatomic, readonly) NSInteger reviewCount;

@end
