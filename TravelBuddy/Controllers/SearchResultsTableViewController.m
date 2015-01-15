//
//  SearchResultsTableViewController.m
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/14/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import "SearchResultsTableViewController.h"

// controllers
#import "SVWebViewController.h"

// views
#import "AttractionTableViewCell.h"

@interface SearchResultsTableViewController ()

@property (nonatomic, strong) UIImage *blurredUnderlyingImage;
@property (nonatomic, strong) UIImageView *underlyingImageView;

@end

@implementation SearchResultsTableViewController

#pragma mark - view lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _documents = [NSArray array];
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
    //
}

#pragma mark - Table view data source

- (void)setDocuments:(NSArray *)documents
{
    _documents = documents;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationFade];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.documents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttractionTableViewCell *cell = (AttractionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AttractionTVC"
                                                                                               forIndexPath:indexPath];

    NSDictionary *documentJson = self.documents[indexPath.row];
    [cell useDocument:documentJson];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((375.0 / 500.0) * self.view.bounds.size.width);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *documentJson = self.documents[indexPath.row];
    NSString *urlString = documentJson[@"originurl"];

    SVWebViewController *controller = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];

    [self.parentViewController.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

@end
