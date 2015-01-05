//
//  Place+Flickr.h
//  Top Regions
//
//  Created by Parmesh Bayappu on 12/29/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "Place.h"

@interface Place (Flickr)
+ (Place *)placeWithFlickrInfo:(NSDictionary *)flickrDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)loadPlacesFromFlickrArray:(NSArray *)places // of Flickr NSDictionary
         intoManagedObjectContext: (NSManagedObjectContext *)context;


@end
