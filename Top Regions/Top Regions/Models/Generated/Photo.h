//
//  Photo.h
//  Top Regions
//
//  Created by Parmesh Bayappu on 12/30/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * detailDescription;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSDate * lastViewed;
@property (nonatomic, retain) Place *whichPlace;

@end
