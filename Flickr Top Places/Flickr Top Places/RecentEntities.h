//
//  RecentPlaces.h
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 12/3/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentEntities : NSObject

//override as appropriate in subclass
@property (nonatomic, readonly) NSInteger maxEntries;

@property (nonatomic, readonly) NSArray *recents;

- (void)addRecent: (NSDictionary *)entity;

// Abstract: Must override in subclass
+ (NSObject *)primaryKeyInEntity: (NSDictionary *)entity;

// Given that this is an abstract class, is it approrpiate to have a sharedInstance creation in base (abstract) class?
+ (instancetype)sharedInstance;

@end
