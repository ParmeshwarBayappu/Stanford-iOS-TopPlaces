//
//  PhotosListCDTVCViewController.h
//  Top Regions
//
//  Created by Parmesh Bayappu on 12/30/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Place.h"

@interface PhotosListCDTVC : CoreDataTableViewController

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) Place *placeOfPhotos;

@end
