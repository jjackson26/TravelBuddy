//
//  MMOverlayController.h
//  MindMeldStarterApp
//
//  Created by J.J. Jackson on 03/10/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMOverlayController : UIViewController

/**
 *  This is the view to which all content should be added. Adding subviews to view will result in undesired behavior.
 */
@property (nonatomic, strong) IBOutlet UIView *contentView;

/**
 *  This is an image of the underlying view.
 */
@property (nonatomic, strong) UIImage *underlyingImage;

/**
 *  This block is called when the overlay controller is dismissed.
 */
@property (nonatomic, copy) void (^onDismissed)();

- (void)dismiss;

@end
