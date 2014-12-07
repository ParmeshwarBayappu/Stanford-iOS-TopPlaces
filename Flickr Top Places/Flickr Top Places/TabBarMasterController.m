//
//  TabBarSplitViewMasterViewController.m
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 12/5/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "TabBarMasterController.h"

@interface TabBarMasterController () <UITabBarControllerDelegate>

@end

@implementation TabBarMasterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setDetailTabBarController:(UITabBarController *)detailTabController {
    _detailTabBarController = detailTabController;
    //TODO: hide the tabs of the detail tab controller
}

// When tab selection on master tabbar controller changes, do change the selection on the detail tabbar controller accordingly
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    //Select corresponding tab in detail view controller
    NSUInteger masterSelectedTabIndex = tabBarController.selectedIndex;
    self.detailTabBarController.selectedIndex = masterSelectedTabIndex;
}

// Detail view controller corresponding for this master view controller
-(UIViewController *)detailViewControllerForMaster: (UIViewController *)masterVC {
    NSUInteger masterSelectedTabIndex = [self.viewControllers indexOfObject:masterVC];
    assert(masterSelectedTabIndex!=NSNotFound);
    return self.detailTabBarController.viewControllers[masterSelectedTabIndex];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
