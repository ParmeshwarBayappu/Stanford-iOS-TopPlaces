//
//  TopPlacesCDTVC.m
//  Top Regions
//
//  Created by Parmesh Bayappu on 12/29/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "TopPlacesCDTVC.h"
#import "Place.h"
#import "Place+Flickr.h"
#include "PhotoDatabaseAvailability.h"
#include "FlickrFetcher.h"
#include "PhotosListCDTVC.h"
#import "AppDelegate.h"

@implementation TopPlacesCDTVC

-(NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext) {
        AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    [self setupFetchedResultsController];
    //[self updateTopPlaces];
}

-(void)setupFetchedResultsController {
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"country" ascending:true selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"country" cacheName:nil];
    //[self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self printOpQueue];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Place Template" forIndexPath:indexPath];
    //cell.textLabel.text = [NSString stringWithFormat:@"Cell at Section %d and row %d", indexPath.section, indexPath.row];
    
    //NSString *country = [self countryNameForSection:indexPath.section];
    //NSDictionary *topPhotoPlace = (self.topPlaces)[indexPath.row];
    
    Place * place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = place.nameMain;
    cell.detailTextLabel.text = place.nameRest; 
    
    return cell;
}

- (void)updateTopPlaces {
    //[self printOpQueue];
    //self.topPlaces = nil;
    NSURL *urlForTopPlaces = [FlickrFetcher URLforTopPlaces];
    NSURLRequest * request = [NSURLRequest requestWithURL:urlForTopPlaces];
    NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue: [[NSOperationQueue alloc] init]];//[NSOperationQueue mainQueue]];
    
    //[self.refreshControl beginRefreshing]; //mostly unnecessary
    
    //TODO: Review class demo on use of the other session type and loading in appdelegate
    NSURLSessionDownloadTask *sessionDownloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localLocation, NSURLResponse *response, NSError *error) {
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
            }];
            
        }   else {
            NSLog(@"Error:%@", error);
        }
        
    }];
    [sessionDownloadTask resume];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"Photos For Place"]) {
        PhotosListCDTVC * destViewController = segue.destinationViewController;
        UITableViewCell *selection = sender;
        NSIndexPath *indexPath =  [self.tableView indexPathForCell:selection];
        
        Place *topPhotoPlace = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        destViewController.managedObjectContext = self.managedObjectContext;
        destViewController.placeOfPhotos = topPhotoPlace;
    }
}


@end
