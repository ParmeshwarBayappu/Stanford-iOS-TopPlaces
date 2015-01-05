//
//  Photo+Flickr.m
//  Top Regions
//
//  Created by Parmesh Bayappu on 12/29/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"

@implementation Photo (Flickr)

+(Photo *)photoWithFlickrInfo:(NSDictionary *)flickrDictionary atPlace:(Place *)place inManagedObjectContext:(NSManagedObjectContext *)context {
    Photo * photo = nil;
    
    NSString * photoId = flickrDictionary[FLICKR_PHOTO_ID];
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photoId = %@", photoId];
    
    NSError * error;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    if(!matches || error || matches.count >1) {
        NSLog(@"Error to handle");
    } else if (matches.count) {
        photo = matches.firstObject;
    } else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        
        photo.photoId = photoId;
        photo.imageUrl = [[FlickrFetcher URLforPhoto:flickrDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.title = [self titleForPhoto:flickrDictionary];
        photo.detailDescription = [self descriptionForPhoto:flickrDictionary];
        photo.whichPlace = place;
    }
    
    return photo;
}

+(void)loadPhotosFromFlickrArray:(NSArray *)photos atPlace:(Place *)place intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo atPlace:place inManagedObjectContext:context];
    }
}

+ (NSString *)titleForPhoto:(NSDictionary *)photo {
    NSString *title = photo[FLICKR_PHOTO_TITLE];
    if(title==nil || title.length==0) {
        title = [self descriptionForPhoto:photo];
    }
    return (title==nil || title.length==0)? @"Unknown" : title;
}

+ (NSString *)descriptionForPhoto:(NSDictionary *)photo {
    return [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}

@end
