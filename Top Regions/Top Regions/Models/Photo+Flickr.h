//
//  Photo+Flickr.h
//  Top Regions
//
//  Created by Parmesh Bayappu on 12/29/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrDictionary atPlace:(Place *)place inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         atPlace:(Place *)place intoManagedObjectContext: (NSManagedObjectContext *)context;


@end
