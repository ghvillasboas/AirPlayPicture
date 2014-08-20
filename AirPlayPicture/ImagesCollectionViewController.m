//
//  ImagesCollectionViewController.m
//  AirPlayPicture
//
//  Created by George Villasboas on 8/19/14.
//  Copyright (c) 2014 Logics Software. All rights reserved.
//

#import "ImagesCollectionViewController.h"
#import "ImageCollectionViewCell.h"
#import "ObjectiveFlickr.h"
#import "ImageViewController.h"

@interface ImagesCollectionViewController () <OFFlickrAPIRequestDelegate>
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) OFFlickrAPIContext *flickrContext;
@property (strong, nonatomic) OFFlickrAPIRequest *flickrRequest;
@end

@implementation ImagesCollectionViewController

#pragma mark -
#pragma mark Getters overriders

- (OFFlickrAPIContext *)flickrContext
{
    if (!_flickrContext) {
        _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:FLICKR_API_KEY sharedSecret:FLICKR_API_SECRET];
    }
    
    return _flickrContext;
}

#pragma mark -
#pragma mark Setters overriders

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Public methods

#pragma mark -
#pragma mark Private methods

/**
 *  Requests the flickr api to fetch some images
 */
- (void)loadImages
{
    self.flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
    self.flickrRequest.delegate = self;
    
    [self.flickrRequest callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:@{@"per_page" : @"20", @"extras":@"owner_name,date_taken,description"}];
}

#pragma mark -
#pragma mark ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.images = @[];
    [self loadImages];
}

#pragma mark -
#pragma mark Overriden methods

#pragma mark -
#pragma mark Storyboards Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = self.collectionView.indexPathsForSelectedItems.lastObject;
    NSDictionary *image = self.images[indexPath.row];
    
    if ([@"imageSegue" isEqualToString:segue.identifier]) {
        ImageViewController *ivc = (ImageViewController *)segue.destinationViewController;
        ivc.imageURL = [self.flickrContext photoSourceURLFromDictionary:image size:OFFlickrLargeSize];
        ivc.imageDescription = [NSString stringWithFormat:@"%@", image[@"ownername"]];
    }
}

#pragma mark -
#pragma mark Target/Actions

#pragma mark -
#pragma mark Delegates

#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *photo = [self.images objectAtIndex:indexPath.row];
    cell.imageURL = [self.flickrContext photoSourceURLFromDictionary:photo size:OFFlickrSmallSquareSize];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *image = self.images[indexPath.row];
    NSArray *screens = [UIScreen screens];
    
    if (screens.count > 1) {
        for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
            if (window.screen != [UIScreen mainScreen]) {
                ImageViewController *ivc = (ImageViewController *)window.rootViewController;
                ivc.imageURL = [self.flickrContext photoSourceURLFromDictionary:image size:OFFlickrLargeSize];
                ivc.imageDescription = [NSString stringWithFormat:@"%@", image[@"ownername"]];
            }
        }
    }
    else{
        [self performSegueWithIdentifier:@"imageSegue" sender:self];
    }
}

#pragma mark - Flickr Delegates

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)response
{
    NSArray *photos = [response valueForKeyPath:@"photos.photo"];
    
    self.images = photos;
    
    self.flickrRequest = nil;
    
    [self.collectionView reloadData];
    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"%@", inError);
}

#pragma mark -
#pragma mark Notification center

@end
