//
//  HelloWorldView.m
//  MindMeldHelloWorld
//
//  Created by Juan Rodriguez on 11/6/13.
//  Copyright (c) 2013 Expect Labs. All rights reserved.
//

#import "HelloWorldView.h"

@implementation HelloWorldView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        // Set the background for this view
        self.backgroundColor = [UIColor whiteColor];
        
        // Add the response text view
        UIImageView *logoIM = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM-api-logo.png"]];
        CGRect rect = logoIM.frame;
        rect.origin.y = (frame.size.height - rect.size.height) / 2;
        rect.origin.x = (frame.size.width - rect.size.width) / 2;
        logoIM.frame = rect;
        [self addSubview:logoIM];
        self.logoView = logoIM;
    }

    return self;
}

@end
