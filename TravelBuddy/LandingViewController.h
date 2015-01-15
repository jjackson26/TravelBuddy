//
//  LandingViewController.h
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/14/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandingViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *imageURLs;

@end
