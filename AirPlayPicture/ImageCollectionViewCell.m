//
//  ImageCollectionViewCell.m
//  AirPlayPicture
//
//  Created by George Villasboas on 8/19/14.
//  Copyright (c) 2014 Logics Software. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@interface ImageCollectionViewCell () <NSURLSessionDownloadDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIImageView *airPlayIconImageView;

@property (strong, nonatomic) NSURLSession *urlSession;
@property (strong, nonatomic) NSURLSessionDownloadTask *imageDownloadTask;
@end

@implementation ImageCollectionViewCell

#pragma mark -
#pragma mark Getters overriders

#pragma mark -
#pragma mark Setters overriders

- (void)setImageURL:(NSURL *)imageURL
{
    if (![imageURL isEqual:_imageURL]) {
        _imageURL = imageURL;
        self.imageDownloadTask = [self.urlSession downloadTaskWithURL:_imageURL];
        [self.imageDownloadTask resume];
    }
}

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Public methods

#pragma mark -
#pragma mark Private methods

/**
 *  Display or not the airplay icon
 */
- (void)setupAirPlayIcon
{
    if ([UIScreen screens].count > 1) {
        self.airPlayIconImageView.hidden = NO;
    }
    else{
        self.airPlayIconImageView.hidden = YES;
    }
}

#pragma mark -
#pragma mark View life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
}

#pragma mark -
#pragma mark Overriden methods

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        [self setupAirPlayIcon];
        self.layer.borderWidth = 5.0;
        self.layer.borderColor = [UIColor redColor].CGColor;
    }
    else{
        self.airPlayIconImageView.hidden = YES;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0.0;
    }
}

#pragma mark -
#pragma mark Storyboards Segues

#pragma mark -
#pragma mark Target/Actions

#pragma mark -
#pragma mark Delegates

#pragma mark - NSURLSession Delegates

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // If image is large, consider creating the image off the main queue
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
    
    [self.spinner stopAnimating];
    self.imageView.image = image;
    
    NSError *error;
    BOOL result = [[NSFileManager defaultManager] removeItemAtURL:location error:&error];
    if (!result) {
        NSLog(@"Error removing temp file at: %@, error: %@", location, error);
    }
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

#pragma mark -
#pragma mark Notification center


@end
