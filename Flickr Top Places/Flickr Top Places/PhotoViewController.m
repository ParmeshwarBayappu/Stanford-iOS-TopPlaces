//
//  PhotoViewController.m
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 11/25/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotoViewController () <UIScrollViewDelegate>

//IB Related
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) UIImageView *imageView;

@property (nonatomic) UIImage *image;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView addSubview:self.imageView];

    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.delegate = self;


//    NSDictionary *photo = @{
//            @"farm" : @"8",
//            @"geo_is_contact" : @"0",
//            @"geo_is_family" : @"0",
//            @"geo_is_friend" : @"0",
//            @"geo_is_public" : @"1",
//            @"id" : @"15849186326",
//            @"isfamily" : @"0",
//            @"isfriend" : @"0",
//            @"ispublic" : @"1",
//            @"latitude" : @"45.75835",
//            @"longitude" : @"4.82681",
//            @"originalformat" : @"jpg",
//            @"originalsecret" : @"fb9e0c6f28",
//            @"owner" : @"32803223@N00",
//            @"ownername" : @"falena",
//            @"place_id" : @"gUrZ2NhXUrPDYlI",
//            @"secret" : @"7b2d16ff70",
//            @"server" : @"7577",
//            @"tags" : @"square squareformat sutro iphoneography instagramapp uploaded:by=instagram foursquare:venue=4f72f6bae4b039d89883e769",
//            @"title" : @"Quel che resta della #nebbia fritta! @instaweatherpro #instaweather #instaweatherpro #weather #wx #android #lyon #francia #day #autumn #clouds #fr",
//            @"woeid" : @"609125"
//    };
//    self.photoMetaData = photo;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UIImage *)image {
//    return self.imageView.image;
//}

- (UIImageView *)imageView {
    if(!_imageView) {
        _imageView = [UIImageView new];
    }
    return _imageView;
}

- (UIImage *)image {
    return _imageView.image;
}

- (void)setImage: (UIImage *)image {
    self.imageView.image = image;
    [self.imageView sizeToFit];

    self.scrollView.contentSize = image? image.size : CGSizeMake(1.0, 1.0); // CGSizeZero not working!!! Any non-zero size value is OK. (0,0) size - likely to hide whole view permanently
    //[self.scrollView setContentOffset:CGPointMake(50.0, 50.0)];
    NSLog(@"SetImage call done");
}

//fetch image
- (void)fetchImage {
    NSLog(@"Fetch Image called");

    //self.photos = nil;

    NSURL *urlForPhoto = [FlickrFetcher URLforPhoto:self.photoMetaData format:FlickrPhotoFormatLarge];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];

    [self.activityIndicator startAnimating];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlForPhoto];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:urlRequest completionHandler:^(NSURL *localURL, NSURLResponse *response, NSError *error) {
        if(!error) {
            NSData *data = [NSData dataWithContentsOfURL:localURL options:0 error:&error];
            UIImage *image = [UIImage imageWithData:data];
//            [_imageView setImage:image];

            //Option 1
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImage:image];
            });

//            //Option 2
//            [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:false];

        } else {
            NSLog(@"Error fetching photo!");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
        });
    }];
    //[downloadTask performSelector:@selector(resume) withObject:nil afterDelay:5];
    [downloadTask resume];

}

- (void)setPhotoMetaData:(NSDictionary *)photoMetaData {
    _photoMetaData = photoMetaData;
    NSLog(@"Photo set to : %@", photoMetaData);
    [self fetchImage];
}

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    _scrollView.contentSize = self.image? self.image.size : CGSizeMake(1024, 1024); // Any non-zero size value is OK. (0,0) size - likely to hide whole view permanently
    NSLog(@"SetScrollView call done");
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
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
