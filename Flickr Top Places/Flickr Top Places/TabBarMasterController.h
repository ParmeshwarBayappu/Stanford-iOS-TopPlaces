//
//  TabBarSplitViewMasterViewController.h
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 12/5/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarMasterController : UITabBarController

@property (nonatomic) UITabBarController * detailTabBarController;

-(UIViewController *)detailViewControllerForMaster: (UIViewController *)masterVC;

@end
