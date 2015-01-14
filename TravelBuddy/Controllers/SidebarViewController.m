//
//  SidebarViewController.m
//  
//
//  Created by J.J. Jackson on 1/12/15.
//
//

#import "SidebarViewController.h"

@interface SidebarViewController ()

@end

@implementation SidebarViewController

- (UIViewController *)instantiateLeftViewController
{
    return [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
}

- (UIViewController *)instantiateRightViewController
{
    return  nil;
}

@end
