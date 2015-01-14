//
//  MMBrowser.h
//  MindMeld Browser
//
//  Created by Juan Rodriguez on 2/27/14.
//  Copyright (c) 2014 Regio Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMBrowser : UIView <UIWebViewDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITextField *urlField;
@property (nonatomic, strong) UIButton *goButton;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *entitiesButton;
@property (nonatomic, strong) UIView *activityBackground;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (void)showActivityIndicator;
- (void)hideActivityIndicator;

@end
