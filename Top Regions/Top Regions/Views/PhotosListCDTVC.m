//
//  PhotosListCDTVCViewController.m
//  Top Regions
//
//  Created by Parmesh Bayappu on 12/30/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "PhotosListCDTVC.h"
#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"
#import "PhotoDatabaseAvailability.h"
#import "AppDelegate.h"

@interface PhotosListCDTVC ()

//IB properties
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation PhotosListCDTVC

-(NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext) {
        AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

-(void)awakeFromNib {
    //[super awakeFromNib];
//    [[NSNotificationCenter defaultCenter] addObserverForName:PHOTO_DATABASE_AVAILABILITY_NOTIFICATION object:nil queue:nil usingBlock:^(NSNotification *note) {
//        self.managedObjectContext = note.userInfo[PHOTO_DATABASE_AVAILABILITY_NOTIFICATION_CONTEXT_KEY];
//    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    if (!self.placeOfPhotos) {
        NSDate * recentDate = [NSDate dateWithTimeIntervalSinceNow:-600];
        request.predicate = [NSPredicate predicateWithFormat:@"lastViewed > %@", recentDate];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastViewed" ascending:false selector:@selector(compare:)]];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"whichPlace.placeId = %@", self.placeOfPhotos.placeId] ;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"photoId" ascending:true selector:@selector(localizedStandardCompare:)]];
    }
    
    assert(self.managedObjectContext!=nil);
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    if(self.placeOfPhotos) {
        [self updatePhotosList];
    }
    [self.tableView reloadData];
    
}

- (void)updatePhotosList {
    NSURL *urlForPhotosInPlace = [NSURL URLWithString:self.placeOfPhotos.urlForPhotosInPlace];
    NSURLRequest * request = [NSURLRequest requestWithURL:urlForPhotosInPlace];
    NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue: [[NSOperationQueue alloc] init]];//[NSOperationQueue mainQueue]];
    
    //[self.refreshControl beginRefreshing]; //mostly unnecessary
    
    //TODO: Review class demo on use of the other session type and loading in appdelegate
    NSURLSessionDownloadTask *sessionDownloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localLocation, NSURLResponse *response, NSError *error) {
        //[self printOpQueue];
        if(!error) {
            NSData *jsonResults = [NSData dataWithContentsOfURL:localLocation options:0 error:&error];
            NSDictionary *propertyListResults= [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
            //NSLog(@"Photos in Place response as property list: %@", [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES]);
            NSArray *flickrPhotosInPlace = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
            //NSLog(@"Sending request to relaodData");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [Photo loadPhotosFromFlickrArray:flickrPhotosInPlace atPlace:self.placeOfPhotos intoManagedObjectContext:self.managedObjectContext];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo List Entry" forIndexPath:indexPath];
    Photo * photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.detailDescription;
    
    return cell;
}


#pragma mark - Navigation

- (void)onPhotoSelected: (Photo *)selectedPhoto destinationViewController: (UIViewController *)destinationViewController {
    PhotoViewController * destViewController = (PhotoViewController *)((UINavigationController *)destinationViewController).topViewController;
    
    destViewController.photo = selectedPhoto;
    if(self.placeOfPhotos) {
        selectedPhoto.lastViewed = [NSDate date];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
        NSLog(@"Photo for selected Photo set to %@", selectedPhoto.lastViewed );
       // [self.recents addRecent:selectedPhoto];
    }
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"To Photo Page"]) {
        UITableViewCell *selection = sender;
        NSIndexPath *indexPath =  [self.tableView indexPathForCell:selection];
        Photo *selectedPhoto = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [self onPhotoSelected:selectedPhoto destinationViewController:segue.destinationViewController];
    }
    
}

@end
