//
//  TopPlacesViewController.h
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 11/19/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopPlacesViewController : UITableViewController

+ (NSString *)getNameOfPlace:(NSDictionary *)place;
@end
