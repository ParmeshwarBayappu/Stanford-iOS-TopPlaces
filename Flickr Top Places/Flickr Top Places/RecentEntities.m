//
//  RecentPlaces.m
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 12/3/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "RecentEntities.h"

@interface RecentEntities ()
//@property (nonatomic,readonly) NSUserDefaults *userDefaults;
@end

NSString *const kRecentEntitiesKey = @"Recent Places";
const int kMaxRecentEntries = 10;

@implementation RecentEntities

+ (NSUserDefaults *) userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

-(NSInteger)maxEntries {
    return 10;
}

- (NSArray *)recents{
    NSArray * recents = [[self.class userDefaults] objectForKey:kRecentEntitiesKey];
    if (!recents) {
        recents = [NSArray new];
    }
    return recents;
}

- (void)addRecent:(NSDictionary *)entity {
    NSMutableArray *recentEntities = [[self recents] mutableCopy];
    [self.class removeMatchingEntityInArray:recentEntities entityToMatch:entity];
    [recentEntities addObject:entity];
    
    if(recentEntities.count >kMaxRecentEntries) {
        [recentEntities removeObjectAtIndex:0];
    }
    
    [[self.class userDefaults] setObject:recentEntities forKey:kRecentEntitiesKey];
    
    [self.class LogEntities:recentEntities];
}

+ (void)removeMatchingEntityInArray: (NSMutableArray *)recentEntities entityToMatch:(NSDictionary *)entityToMatch {
    NSObject *entityIDToMatch = [self primaryKeyInEntity: entityToMatch];
    for (NSDictionary *recentEntity in recentEntities) {
        if([[self primaryKeyInEntity:recentEntity] isEqual:entityIDToMatch]) {
            [recentEntities removeObject:recentEntity];
            break;
        }
    }
}

// Abstract: Must override in subclass
+ (NSObject *)primaryKeyInEntity: (NSDictionary *)entity {
    assert(false); //Must override in subclass
    return nil;
}

+ (void)LogEntities: (NSArray *)entities {
    for (NSDictionary *entity in entities) {
        NSLog(@" %@", [self primaryKeyInEntity:entity]);
    }
}

// Creates a singleton instance for the invoking class (this or its derived class)
+ (instancetype) sharedInstance {
    
    static RecentEntities *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self.class new];
    });
    
    return sharedInstance;
}

@end
