//
//  MMBrowser.m
//  MindMeld Browser
//
//  Created by Juan Rodriguez on 2/27/14.
//  Copyright (c) 2014 Regio Systems. All rights reserved.
//

#import "MMBrowser.h"

static const CGFloat kHeaderHeight = 40;
static const CGFloat kGoButtonWidth = 50;
static const CGFloat kFooterHeight = 40;

@implementation MMBrowser

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // Add the header view
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kHeaderHeight)];
        headerView.backgroundColor = [UIColor grayColor];
        [self addSubview:headerView];
        self.headerView = headerView;
        
        // Add the text field
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - kGoButtonWidth, kHeaderHeight)];
        textField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        textField.keyboardType = UIKeyboardTypeURL;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.headerView addSubview:textField];
        self.urlField = textField;
        
        // Add the go button
        UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
        goButton.frame = CGRectMake(frame.size.width - kGoButtonWidth, 0, kGoButtonWidth, kHeaderHeight);
        [goButton setTitle:@"Go" forState:UIControlStateNormal];
        UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        [goButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [goButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [self.headerView addSubview:goButton];
        self.goButton = goButton;
        
        // Add the web view
        CGFloat y = CGRectGetMaxY(self.headerView.frame);
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, frame.size.height - y - kHeaderHeight)];
        webView.backgroundColor = [UIColor grayColor];
        webView.delegate = self;
        [self addSubview:webView];
        self.webView = webView;

        // Add a footer view
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.webView.frame), frame.size.width, kFooterHeight)];
        [self addSubview:footerView];
        self.footerView = footerView;
        
        // Add the entities button
        UIButton *entitiesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        entitiesButton.frame = CGRectMake(0, 0, self.footerView.frame.size.width, self.footerView.frame.size.height);
        [entitiesButton setTitle:@"Get Entities" forState:UIControlStateNormal];
        buttonImage = [[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        [entitiesButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [entitiesButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [self.footerView addSubview:entitiesButton];
        self.entitiesButton = entitiesButton;
        
        // Create the activity background
        UIView *activityBackground = [[UIView alloc] initWithFrame:frame];
        activityBackground.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
        self.activityBackground = activityBackground;
        
        // Create the activity indicator view
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center = self.center;
        self.activityIndicator = activityView;
        [self.activityBackground addSubview:self.activityIndicator];
        
        // by default, go to ABC news
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://abcnews.go.com/"]];
        [self.webView loadRequest:request];
    }
    return self;
}

// These methods show and hide the activity indicator when the entities are
// being fetched.
- (void)showActivityIndicator {
    [self addSubview:self.activityBackground];
    [self.activityIndicator startAnimating];
}
- (void)hideActivityIndicator {
    [self.activityIndicator stopAnimating];
    [self.activityBackground removeFromSuperview];
}

// This method is called when the web view finishes loading a web page
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Change the url of the webview
    self.urlField.text = self.webView.request.URL.absoluteString;
}

@end
