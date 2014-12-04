//
//  RecentPlaces.m
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 12/3/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "RecentPlaces.h"
#import "FlickrFetcher.h"

@implementation RecentPlaces

+ (NSObject *)primaryKeyInEntity: (NSDictionary *)entity {
    return entity[FLICKR_PHOTO_ID];
}

@end
