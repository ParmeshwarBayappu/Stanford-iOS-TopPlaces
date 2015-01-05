//
//  Place.h
//  Top Regions
//
//  Created by Parmesh Bayappu on 12/30/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * placeId;
@property (nonatomic, retain) NSString * nameMain;
@property (nonatomic, retain) NSString * nameRest;
@property (nonatomic, retain) NSString * urlForPhotosInPlace;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
