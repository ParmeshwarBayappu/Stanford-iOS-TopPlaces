//
//  AppDelegate.m
//  Top Regions
//
//  Created by Parmesh Bayappu on 12/15/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "AppDelegate.h"
#include "PhotoDatabaseAvailability.h"
#import "Place+Flickr.h"
#import "FlickrFetcher.h"


@interface AppDelegate ()

@property (nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Create and notify of managed object context
    NSDictionary *userInfo = @{ PHOTO_DATABASE_AVAILABILITY_NOTIFICATION_CONTEXT_KEY : self.managedObjectContext };
    [[NSNotificationCenter defaultCenter] postNotificationName:PHOTO_DATABASE_AVAILABILITY_NOTIFICATION object:self userInfo:userInfo];

    [self updateTopPlaces];
    [self setupForegroundFetchTimer];
    return YES;
}


- (void)printOpQueue {
    NSLog(@"%@", [NSOperationQueue currentQueue]);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.parmesh.cs193p.Top_Regions" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Top_Regions" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Top_Regions.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark -- Fetch

- (NSURLSession *) session {
    if(!_session) {
        NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue: [[NSOperationQueue alloc] init]];//[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)updateTopPlaces {
    // (Re)Download top places unless a download is in progress.
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if(downloadTasks.count){
            //resume downloads - Q) will they be in paused state ever - with an ephemeralSessionConfiguration?
            NSLog(@"updateTopPlaces: Resuming existing download task.");
            [downloadTasks makeObjectsPerformSelector:@selector(resume)];
        } else {
            //start new download
            NSLog(@"updateTopPlaces: Creating new download task.");
            //[self printOpQueue];
            NSURL *urlForTopPlaces = [FlickrFetcher URLforTopPlaces];
            NSURLRequest * request = [NSURLRequest requestWithURL:urlForTopPlaces];
            
            NSURLSessionDownloadTask *sessionDownloadTask = [self.session downloadTaskWithRequest:request completionHandler:^(NSURL *localLocation, NSURLResponse *response, NSError *error) {
                //[self printOpQueue];
                if(!error) {
                    NSData *jsonResults = [NSData dataWithContentsOfURL:localLocation options:0 error:&error];
                    NSDictionary *propertyListResults= [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
                    //NSLog(@"Top Places response as property list: %@", [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES]);
                    NSArray *flickrTopPlaces = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
                    //NSLog(@"Sending request to relaodData");
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [Place loadPlacesFromFlickrArray:flickrTopPlaces intoManagedObjectContext:self.managedObjectContext];
                        NSError *error;
                        [self.managedObjectContext save:&error];
                        //[self.tableView reloadData];
                        //[self.refreshControl endRefreshing];
                        //[self.flickrForegroundFetchTimer fire];
                    }];
                    
                }   else {
                    NSLog(@"Error:%@", error);
                }
                
            }];
            [sessionDownloadTask resume];
        }
    }];
}

#pragma mark -- Timer

- (void)setupForegroundFetchTimer {
    self.flickrForegroundFetchTimer = [NSTimer  scheduledTimerWithTimeInterval:5*60 target:self selector:@selector(updateTopPlacesForTimer:) userInfo:nil repeats:YES];
}

-(void)updateTopPlacesForTimer:(NSTimer *)timer {
    [self updateTopPlaces];
}

@end
