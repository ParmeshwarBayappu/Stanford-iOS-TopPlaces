//
//  PhotoViewController.h
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 11/25/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface PhotoViewController : UIViewController

@property (nonatomic) NSDictionary *photoMetaData;
@property (nonatomic) Photo *photo;

@end
