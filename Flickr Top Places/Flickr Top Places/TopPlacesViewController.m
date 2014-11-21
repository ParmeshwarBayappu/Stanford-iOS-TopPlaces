//
//  TopPlacesViewController.m
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 11/19/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "TopPlacesViewController.h"
#import "FlickrFetcher.h"

@interface TopPlacesViewController ()

@property (nonatomic) NSArray *topPlaces;
@property (nonatomic) NSMutableDictionary *countryToPlaces;
@property (nonatomic, readonly) NSArray *sortedCountryToPlaces;

@end

@implementation TopPlacesViewController

- (void)setTopPlaces:(NSArray *)topPlaces {

    if(topPlaces) {
        NSLog(@"1st place %@", topPlaces[1]);
    }
    _topPlaces = topPlaces;
    [self updateCountryToPlacesWithPlaces:_topPlaces];
    [self.tableView reloadData];
}

- (NSMutableDictionary *)countryToPlaces {
    if(!_countryToPlaces) {
        _countryToPlaces = [NSMutableDictionary new];
    }
    return _countryToPlaces;
}

- (NSArray *)sortedCountryToPlaces {
    return [[self.countryToPlaces allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *) obj1 compare:obj2];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
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
    NSDictionary *propertyListResults = nil;
    NSURL *urlForTopPlaces = [FlickrFetcher URLforTopPlaces];
    NSError *error;

//    //Option 1
//    NSData *jsonResults = [NSData dataWithContentsOfURL:urlForTopPlaces options:0 error:&error];
//    propertyListResults= [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
//    NSLog(@"Top Places response as property list: %@", propertyListResults);
//    self.topPlaces = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];

    //Option 2
    NSURLRequest * request = [NSURLRequest requestWithURL:urlForTopPlaces];
    NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue: [[NSOperationQueue alloc] init]];//[NSOperationQueue mainQueue]];

    [self.refreshControl beginRefreshing];
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
        [self.refreshControl endRefreshing];
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [self countryNameForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self printOpQueue];

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Place Template" forIndexPath:indexPath];
    //cell.textLabel.text = [NSString stringWithFormat:@"Cell at Section %d and row %d", indexPath.section, indexPath.row];

    NSString *country = [self countryNameForSection:indexPath.section];
    //NSDictionary *topPhotoPlace = (self.topPlaces)[indexPath.row];
    NSDictionary *topPhotoPlace = (self.countryToPlaces[country])[indexPath.row];
    cell.textLabel.text = [topPhotoPlace valueForKeyPath:FLICKR_PLACE_ID];
    //cell.detailTextLabel.text = [photo valueForKeyPath:FLICKR_PLACE_NAME];
    cell.detailTextLabel.text = [FlickrFetcher extractCountryNameFromPlaceInformation:topPhotoPlace];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *countryName =  self.sortedCountryToPlaces[section];
    NSArray *placesInCountry = self.countryToPlaces[countryName];
    return placesInCountry.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.countryToPlaces.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Group the places into countries and provide an array of

- (void) updateCountryToPlacesWithPlaces: (NSArray *)places {
    [self.countryToPlaces removeAllObjects];
    for (NSDictionary *place in places) {
        [self addPlace:place];
    }
}

- (void)addPlace:(NSDictionary *)place {
    NSString *country = [FlickrFetcher extractCountryNameFromPlaceInformation:place];
    NSMutableArray *existingPlaceListForCountry = [self.countryToPlaces objectForKey:country];
    if(!existingPlaceListForCountry) {
        existingPlaceListForCountry = [NSMutableArray new];
        [self.countryToPlaces setObject:existingPlaceListForCountry forKey:country];
    }
    [existingPlaceListForCountry addObject:place];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
