//
//  Place+Flickr.m
//  Top Regions
//
//  Created by Parmesh Bayappu on 12/29/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "Place+Flickr.h"
#import "FlickrFetcher.h"

@implementation Place (Flickr)

#define MAX_PHOTOS_IN_RESULTS 50
+(Place *)placeWithFlickrInfo:(NSDictionary *)flickrDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Place *place = nil;
    
    NSString* placeId = flickrDictionary[FLICKR_PLACE_ID];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"placeId = %@", placeId];
    
    NSError * error = nil;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    if(!matches || error) {
        //TODO: Handle error
    } else if (matches.count >1) {
        //TODO: serious error handle
        assert(false); //TODO: serious error handle
    } else if (matches.count ==1) {
        place = matches.firstObject;
        NSLog(@"Place with placeId='%@' already exists", placeId);
    } else {
        place = [self insertPlaceWithFlickrInfo:flickrDictionary inManagedObjectContext:context];
    }
    
    return place;
}

+(void)loadPlacesFromFlickrArray:(NSArray *)flikrPlaces intoManagedObjectContext:(NSManagedObjectContext *)context {

    NSMutableArray * newFlikrPlaces = [flikrPlaces mutableCopy];
    NSArray * existingPlaces = [self allPlacesInManagedObjectContext:context];

    unsigned long placesInDbBeforeLoad = existingPlaces.count;
    unsigned long placesFromWeb = newFlikrPlaces.count;

    //Delete places no longer valid
    unsigned long deletedPlacesCount = 0, addedPlacesCount=0, existingValidPlacesCount=0;
    for (Place *existingPlace in existingPlaces) {
        NSError *error;
        NSString * existingPlaceId = existingPlace.placeId;
        NSArray *matches = [newFlikrPlaces filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", FLICKR_PLACE_ID, existingPlaceId]];
        if(!matches || error || matches.count>1) {
            //TODO: Handle error
            [self handleUnexceptedError:[NSString stringWithFormat:@"Error: TOOD: Retrieving Places from context. %@", error]];
        } else if (matches.count ==1) {
            //Place already exists not need to add again - so remove from newPlaces
            //NSLog(@"Place with placeId='%@' and name='%@' still exists in top places", existingPlaceId, existingPlace.nameMain);
            [newFlikrPlaces removeObject:matches.firstObject];
            existingValidPlacesCount++;
        } else {
            //Place is no longer among top places - so remove it from db
            //NSLog(@"Place with placeId='%@' and name='%@' no longer exists in top places", existingPlaceId, existingPlace.nameMain);
            [context deleteObject:existingPlace]; // should this be done outside the iterator?
            deletedPlacesCount++;
        }
    }
    
    //Add remaining places
    for (NSDictionary *newFlikrPlace in newFlikrPlaces) {
        Place * place =  [self insertPlaceWithFlickrInfo:newFlikrPlace inManagedObjectContext:context];
        NSLog(@"Place with placeId='%@' and name='%@' added to top places", place.placeId, place.nameMain);
        addedPlacesCount++;
    }
    
    NSError *error;
    [context save:&error];
    
    unsigned long placesInDbAfterLoad = [self countOfPlacesInManagedObjectContext:context];
    NSLog(@"Places count: InDBBefore:%ld; WebLoad=%ld; After=%ld, deletedPlacesCount=%ld, addedPlacesCount=%ld, existingValidPlacesCount=%ld", placesInDbBeforeLoad, placesFromWeb, placesInDbAfterLoad, deletedPlacesCount, addedPlacesCount, existingValidPlacesCount);
}

+(Place *)insertPlaceWithFlickrInfo:(NSDictionary *)flickrDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Place * place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
    assert(place!=nil);
    
    place.placeId = flickrDictionary[FLICKR_PLACE_ID];;
    place.urlForPhotosInPlace = [[FlickrFetcher URLforPhotosInPlace:place.placeId maxResults:MAX_PHOTOS_IN_RESULTS] absoluteString];
    place.country = [FlickrFetcher extractCountryNameFromPlaceInformation:flickrDictionary];
    place.nameMain = [self getNameOfPlace:flickrDictionary];
    place.nameRest = [FlickrFetcher extractRestOfNameFromPlaceInformation:flickrDictionary];
    
    return place;
}

+(NSArray *)allPlacesInManagedObjectContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = nil;
    
    NSError * error = nil;
    NSArray * places = [context executeFetchRequest:request error:&error];
    if(!places || error) {
        //TODO: Handle error
        [self handleUnexceptedError:[NSString stringWithFormat:@"Error: TOOD: Retrieving Places from context. %@", error]];
    }
    return places;
}


+(NSUInteger)countOfPlacesInManagedObjectContext: (NSManagedObjectContext *)context {
    NSArray * matches = [self allPlacesInManagedObjectContext:context];
    return matches.count;
}

+ (NSString *)getNameOfPlace:(NSDictionary *)place {
    return [place valueForKeyPath:FLICKR_PLACE_NAME];
}

+(void)handleUnexceptedError:(NSString *)errorMessage {
    NSLog(@"Error: TOOD: Retrieving Places from context. %@", errorMessage);
    assert(false);
    abort();
}

@end
