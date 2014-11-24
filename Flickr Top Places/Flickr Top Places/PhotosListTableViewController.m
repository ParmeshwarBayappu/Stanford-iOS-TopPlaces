//
//  PhotosListTableViewController.m
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 11/21/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "PhotosListTableViewController.h"
#import "FlickrFetcher.h"

@interface PhotosListTableViewController ()

@property (nonatomic) NSArray *photos;
@property (nonatomic, readonly) NSString *placeID;

//IB properties
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation PhotosListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Was unable to set any constraints in Xcode so doing programmatically
    [self.activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO]; //Essential for below constraints to work
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

    //Use of the below constraints did not have any impact on the size of the indicator
    //[self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    //[self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    NSDictionary *placeOfPhotos = @{FLICKR_PLACE_ID:@"609125"};
    self.placeOfPhotos = placeOfPhotos;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (void)setPlaceOfPhotos:(NSDictionary *)placeOfPhotos {
    _placeOfPhotos = placeOfPhotos;
    [self fetchPhotos];
}

- (NSString *)placeID {
    //return @"609125";
    return self.placeOfPhotos[FLICKR_PLACE_ID];
}

//- (NSArray *)photos {
//    if(!_photos) {
//        _photos = [NSMutableArray new];
//    }
//    return _photos;
//}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [self.tableView reloadData];
}

#define MAX_PHOTOS_IN_RESULTS 50
- (void)fetchPhotos {
    self.photos = nil;

    NSURL *urlForPhotos = [FlickrFetcher URLforPhotosInPlace:self.placeID maxResults:MAX_PHOTOS_IN_RESULTS];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];

    //[self.refreshControl beginRefreshing];

    [self.activityIndicator startAnimating];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlForPhotos];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:urlRequest completionHandler:^(NSURL *localURL, NSURLResponse *response, NSError *error) {
        if(!error) {
            NSData *jsonData = [NSData dataWithContentsOfURL:localURL options:0 error:&error];
            NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            NSLog(@"Photos from place %@:\n%@", self.placeID, propertyListResults);
            NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
//            //Option 1
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.photos = photos;
//            });
            //Option 2
            [self performSelectorOnMainThread:@selector(setPhotos:) withObject:photos waitUntilDone:false];
        } else {
            NSLog(@"Error fetching photos list!");
        }
        [self.activityIndicator stopAnimating];
    }];
    [downloadTask performSelector:@selector(resume) withObject:nil afterDelay:5];
    //[self performSelectorOnMainThread:@selector(resume) withObject:nil waitUntilDone:false];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo List Entry" forIndexPath:indexPath];
    NSDictionary *photo = self.photos[indexPath.row];
    cell.textLabel.text = [self titleForPhoto:photo];
    cell.detailTextLabel.text = [self descriptionForPhoto:photo];

    return cell;
}

- (NSString *)titleForPhoto:(NSDictionary *)photo {
    NSString *title = photo[FLICKR_PHOTO_TITLE];
    if(title==nil || title.length==0) {
        title = [self descriptionForPhoto:photo];
    }
    return (title==nil || title.length==0)? @"Unknown" : title;
}

- (NSString *)descriptionForPhoto:(NSDictionary *)photo {
    return [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
