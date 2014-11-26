//
//  PhotosListTableViewController.h
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 11/21/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosListTableViewController : UITableViewController

@property (nonatomic) NSDictionary *placeOfPhotos;

+ (NSString *)titleForPhoto:(NSDictionary *)photo;
@end
