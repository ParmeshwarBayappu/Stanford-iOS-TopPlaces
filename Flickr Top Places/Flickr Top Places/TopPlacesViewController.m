//
//  TopPlacesViewController.m
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 11/19/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "TopPlacesViewController.h"
#import "FlickrFetcher.h"
#import "PhotosListTableViewController.h"

@interface TopPlacesViewController ()

@property (nonatomic) NSArray *topPlaces;
@property (nonatomic) NSMutableDictionary *countriesToPlaces;
@property (nonatomic) NSArray *sortedCountryToPlaces;

@end

@implementation TopPlacesViewController

@synthesize sortedCountryToPlaces = _sortedCountryToPlaces;

- (void)setTopPlaces:(NSArray *)topPlaces {

    if(topPlaces) {
        NSLog(@"1st place %@", topPlaces[1]);
    }
    _topPlaces = topPlaces;
    [self updateCountryToPlacesWithPlaces:_topPlaces];
    [self.tableView reloadData];
}

- (NSMutableDictionary *)countriesToPlaces {
    if(!_countriesToPlaces) {
        _countriesToPlaces = [NSMutableDictionary new];
    }
    return _countriesToPlaces;
}

- (NSArray *)sortedCountryToPlaces {
    if(!_sortedCountryToPlaces) {
        NSLog(@"Sorted Country List creation starting...");
        _sortedCountryToPlaces = [[self.countriesToPlaces allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *) obj1 compare:obj2];
        }];
        NSLog(@"Sorted Country List creation completed!");
    }
    return _sortedCountryToPlaces;
}

- (void)setSortedCountryToPlaces:(NSArray *)sortedCountryToPlaces {
    assert(sortedCountryToPlaces==nil);
    _sortedCountryToPlaces = sortedCountryToPlaces;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
    
    //self.navigationItem.title = @"NavItem Code";
    //self.navigationController.title = @"Places Title From Code";
}

- (void)setup {
    [self updateTopPlaces];

}
- (IBAction)onTableRefreshAction:(UIRefreshControl *)sender {
    NSLog(@"onTableRefreshAction occurred");
    [self updateTopPlaces];
}

- (void)updateTopPlaces {
    //[self printOpQueue];
    self.topPlaces = nil;
    NSURL *urlForTopPlaces = [FlickrFetcher URLforTopPlaces];
    //NSError *error;

//    //Option 1
//    NSData *jsonResults = [NSData dataWithContentsOfURL:urlForTopPlaces options:0 error:&error];
//    NSDictionary propertyListResults= [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
//    NSLog(@"Top Places response as property list: %@", propertyListResults);
//    self.topPlaces = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];

    //Option 2
    NSURLRequest * request = [NSURLRequest requestWithURL:urlForTopPlaces];
    NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue: [[NSOperationQueue alloc] init]];//[NSOperationQueue mainQueue]];

    [self.refreshControl beginRefreshing]; //mostly unnecessary

    NSURLSessionDownloadTask *sessionDownloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localLocation, NSURLResponse *response, NSError *error) {
        //[self printOpQueue];
        if(!error) {
            NSData *jsonResults = [NSData dataWithContentsOfURL:localLocation options:0 error:&error];
            NSDictionary *propertyListResults= [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
            //NSLog(@"Top Places response as property list: %@", [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES]);
            self.topPlaces = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];

        }   else {
            NSLog(@"Error:%@", error);
        }
        NSLog(@"Sending request to relaodData");
//        //Option 1
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//            [self.refreshControl endRefreshing];
//        });

        //Option 2
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }];

    }];
    [sessionDownloadTask resume];
}

- (void)printOpQueue {
    NSLog(@"%@", [NSOperationQueue currentQueue]);
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return nil;
//}

- (NSString *)countryNameForSection:(NSInteger)section {
    return self.sortedCountryToPlaces[section];
}

+ (NSString *)getNameOfPlace:(NSDictionary *)place {
    return [place valueForKeyPath:FLICKR_PLACE_NAME];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [self countryNameForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self printOpQueue];

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Place Template" forIndexPath:indexPath];
    //cell.textLabel.text = [NSString stringWithFormat:@"Cell at Section %d and row %d", indexPath.section, indexPath.row];

    NSString *country = [self countryNameForSection:indexPath.section];
    //NSDictionary *topPhotoPlace = (self.topPlaces)[indexPath.row];
    NSDictionary *topPhotoPlace = (self.countriesToPlaces[country])[indexPath.row];
    cell.textLabel.text = [self.class getNameOfPlace:topPhotoPlace];
    //cell.detailTextLabel.text = [photo valueForKeyPath:FLICKR_PLACE_NAME];
    cell.detailTextLabel.text = [FlickrFetcher extractRestOfNameFromPlaceInformation:topPhotoPlace];

    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *countryName =  self.sortedCountryToPlaces[section];
    NSArray *placesInCountry = self.countriesToPlaces[countryName];
    return placesInCountry.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.countriesToPlaces.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Group the places into countries and provide an array of

- (void) updateCountryToPlacesWithPlaces: (NSArray *)places {
    [self.countriesToPlaces removeAllObjects];
    for (NSDictionary *place in places) {
        [self addPlace:place];
    }
    [self sortPlacesInEachCountry];

    self.sortedCountryToPlaces = nil;
    NSLog(@"Country dictionary update completed!");
}

//Sort the places within each country
- (void)sortPlacesInEachCountry {
    for (NSMutableArray *countryToPlaces in self.countriesToPlaces.allValues) {
        [countryToPlaces sortUsingComparator:^NSComparisonResult(NSDictionary * place1, NSDictionary * place2) {
            NSString *place1Name = [self.class getNameOfPlace:place1];
            NSString *place2Name = [self.class getNameOfPlace:place2];
            return [place1Name compare:place2Name];
        }];
    }
}

- (void)addPlace:(NSDictionary *)place {
    NSString *country = [FlickrFetcher extractCountryNameFromPlaceInformation:place];
    NSMutableArray *existingPlaceListForCountry = [self.countriesToPlaces objectForKey:country];
    if(!existingPlaceListForCountry) {
        existingPlaceListForCountry = [NSMutableArray new];
        [self.countriesToPlaces setObject:existingPlaceListForCountry forKey:country];
    }
    [existingPlaceListForCountry addObject:place];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if([segue.identifier isEqualToString:@"Photos For Place"]) {
        PhotosListTableViewController * destViewController = segue.destinationViewController;
        UITableViewCell *selection = sender;
        NSIndexPath *indexPath =  [self.tableView indexPathForCell:selection];
        NSString *country = [self countryNameForSection:indexPath.section];
        NSDictionary *topPhotoPlace = (self.countriesToPlaces[country])[indexPath.row];

        destViewController.placeOfPhotos = topPhotoPlace;
    }
}

@end
