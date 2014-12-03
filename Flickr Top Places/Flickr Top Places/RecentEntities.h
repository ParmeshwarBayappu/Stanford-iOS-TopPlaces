//
//  RecentPlaces.h
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 12/3/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentEntities : NSObject

+ (NSArray *)recents;

+(void)addRecent: (NSDictionary *)entity;

// Abstract: Must override in subclass
+ (NSObject *)primaryKeyInEntity: (NSDictionary *)entity;

@end
