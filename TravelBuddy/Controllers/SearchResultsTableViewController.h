//
//  SearchResultsTableViewController.h
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/14/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *documents;


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
