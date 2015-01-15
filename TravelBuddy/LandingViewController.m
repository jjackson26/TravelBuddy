//
//  LandingViewController.m
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/14/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import "LandingViewController.h"

// views
#import "ImageCollectionViewCell.h"


// utilities
#import <SDWebImage/UIImageView+WebCache.h>

@interface LandingViewController ()

@property (nonatomic, strong) NSMutableArray *collectionData;

@end

static NSString *const kCellReuseIdentifier = @"ImageCell";

@implementation LandingViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.collectionData = [NSMutableArray array];
        self.imageURLs = @[ @"https://cdn1.gbot.me/photos/DB/tr/1284987233/Torre_Eiffel___Tour_Eiffe-Tour_Eiffel__Eiffel_Tower-3000000000975-1024x768.jpg",
                            @"https://cdn4.gbot.me/photos/Fg/Av/1317756887/-visit_to_Musee_du_Louvre_-20000000001965247-1024x768.jpg",
                            @"https://cdn4.gbot.me/photos/dS/xb/1284984946/Arc_De_Triomhe__aris__in_-Arc_de_Triomphe-3000000000998-1024x768.jpg" ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self preloadImages];
    [self configureCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setImageURLs:(NSArray *)imageURLs {
    _imageURLs = imageURLs;


    [self.collectionData removeAllObjects];
    if (imageURLs.count > 1) {
        [self.collectionData addObjectsFromArray:imageURLs];
        [self.collectionData addObject:imageURLs.firstObject];
        [self.collectionData addObject:imageURLs[1]];
    } else {
        [self.collectionData addObjectsFromArray:imageURLs];
    }
}

- (void)preloadImages {
    for (NSString *urlString in self.imageURLs) {
        NSURL *imageURL = [NSURL URLWithString:urlString];

        SDWebImageCompletionWithFinishedBlock completion = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            //noop, just prefetching
        };

        [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL
                                                        options:0
                                                       progress:nil
                                                      completed:completion];
    }
}


#pragma mark - Collection View

- (void)configureCollectionView
{
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

    // TODO: anything ?
}


#pragma mark - UICollectionViewDataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.collectionData.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCVC"
                                                                                                         forIndexPath:indexPath];
    NSURL *imageURL = [NSURL URLWithString:self.collectionData[indexPath.item]];
    [cell.imageView sd_setImageWithURL:imageURL];
    
    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.bounds.size;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.bounds.size.width;
    CGFloat contentOffSetWhenFullyScrolledRight = pageWidth * (self.collectionData.count - 1);

    if (scrollView.contentOffset.x == contentOffSetWhenFullyScrolledRight) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:1
                                                        inSection:0];

        [self.collectionView scrollToItemAtIndexPath:newIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionLeft
                                            animated:NO];
    } else if (scrollView.contentOffset.x == 0) {

        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:self.collectionData.count - 2
                                                        inSection:0];

        [self.collectionView scrollToItemAtIndexPath:newIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionLeft
                                            animated:NO];

    }
}

@end
