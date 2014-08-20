//
//  ImageViewController.m
//  AirPlayPicture
//
//  Created by George Villasboas on 8/20/14.
//  Copyright (c) 2014 Logics Software. All rights reserved.
//

#import "ImageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ImageViewController ()<NSURLSessionDownloadDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) NSURLSession *urlSession;
@property (strong, nonatomic) NSURLSessionDownloadTask *imageDownloadTask;
@property (nonatomic, readonly, getter = isAppleTV) BOOL appleTV;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIView *fadeView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *appleTVAlertLabel;
@end

@implementation ImageViewController

#pragma mark -
#pragma mark Getters overriders

- (BOOL)isAppleTV
{
    return [[UIScreen screens] count] > 1;
}

#pragma mark -
#pragma mark Setters overriders

- (void)setImageURL:(NSURL *)imageURL
{
    if (![imageURL isEqual:_imageURL]) {
        _imageURL = imageURL;
        
        [self setupUIForImageDownloading];
        [self hideDescriptionViewAnimated:self.isAppleTV];
        
        self.imageDownloadTask = [self.urlSession downloadTaskWithURL:_imageURL];
        [self.imageDownloadTask resume];
    }
}

- (void)setImageDescription:(NSString *)imageDescription
{
    if (![imageDescription isEqualToString:_imageDescription]) {
        _imageDescription = imageDescription;
        
        self.descriptionLabel.text = _imageDescription;
    }
}

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Public methods

#pragma mark - UI Setup methods

/**
 *  Setup the UI for initial usage
 */
- (void)setupUI
{
    self.progress.progress = 0.0;
    self.fadeView.backgroundColor = [UIColor clearColor];
    
    if (self.isAppleTV) {
        [self showAppleTVAlertAnimated:NO];
        self.progress.hidden = YES;
        [self.spinner stopAnimating];
    }
    else{
        [self hideAppleTVAlertAnimated:NO];
        self.progress.hidden = NO;
        [self.spinner startAnimating];
    }
    
    if ([self.description isEqualToString:@""]) self.descriptionLabel.text = @"";
    [self addLinearGradientToView:self.fadeView withColor:[UIColor clearColor]];
    [self hideDescriptionViewAnimated:NO];
}

/**
 * Sets up the UI when the image is 100% downloaded
 */
- (void)setupUIForImageDownloaded
{
    [self.spinner stopAnimating];
    self.progress.hidden = YES;
    [self.progress setProgress:0.0 animated:NO];
    self.imageView.alpha = 1.0;
}

/**
 *  Sets up the UI for starting up the download process
 */
- (void)setupUIForImageDownloading
{
    
    [self hideAppleTVAlertAnimated:YES];
    
    self.imageView.alpha = 0.3;
    [self.progress setProgress:0.0 animated:NO];
    self.progress.hidden = NO;
    [self.spinner startAnimating];
}

#pragma mark - Description view methods

/**
 *  Show the description view
 *
 *  @param animated Animation flag
 */
- (void)showDescriptionViewAnimated:(BOOL)animated
{
    self.descriptionBottomConstraint.constant = 0.0;
    if (animated) {
        [UIView animateWithDuration:1.0 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else{
        [self.view layoutIfNeeded];
    }
}

/**
 *  Hide the description view
 *
 *  @param animated Animation flag
 */
- (void)hideDescriptionViewAnimated:(BOOL)animated
{
    self.descriptionBottomConstraint.constant = -CGRectGetHeight(self.fadeView.frame);
    if (animated) {
        [UIView animateWithDuration:1.0 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else{
        [self.view layoutIfNeeded];
    }
}

/**
 *  Adds a color gradient to the view
 *
 *  @param theView             View to add color gradient
 *  @param theColor            The color
 */
- (void)addLinearGradientToView:(UIView *)theView withColor:(UIColor *)theColor
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    //the gradient layer must be positioned at the origin of the view
    CGRect gradientFrame = theView.frame;
    gradientFrame.size.width = CGRectGetWidth(self.view.bounds);
    gradientFrame.origin.x = 0;
    gradientFrame.origin.y = 0;
    gradient.frame = gradientFrame;
    
    //build the colors array for the gradient
    NSArray *colors = [NSArray arrayWithObjects:
                       (id)[theColor CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.5f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:1.0f] CGColor],
                       nil];
    
    //apply the colors and the gradient to the view
    gradient.colors = colors;
    
    [theView.layer insertSublayer:gradient atIndex:0];
}

#pragma mark - Apple TV alert methods

/**
 *  Shows the apple tv alert
 *
 *  @param animated Animation flag
 */
- (void)showAppleTVAlertAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.appleTVAlertLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (finished) {
                self.appleTVAlertLabel.hidden = NO;
            }
        }];
    }
    else{
        self.appleTVAlertLabel.hidden = NO;
    }
}

/**
 *  Hides the apple tv alert
 *
 *  @param animated Animation flag
 */
- (void)hideAppleTVAlertAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.appleTVAlertLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                self.appleTVAlertLabel.hidden = YES;
            }
        }];
    }
    else{
        self.appleTVAlertLabel.hidden = YES;
    }
}

#pragma mark -
#pragma mark Private methods

#pragma mark -
#pragma mark ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupUI];
}

#pragma mark -
#pragma mark Overriden methods

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
    self.imageWidthConstraint.constant = image.size.width;
    self.imageHeightConstraint.constant = image.size.height;
    self.imageView.image = image;
    
    [self setupUIForImageDownloaded];
    [self showDescriptionViewAnimated:YES];
    
    NSError *error;
    BOOL result = [[NSFileManager defaultManager] removeItemAtURL:location error:&error];
    if (!result) {
        NSLog(@"Error removing temp file at: %@, error: %@", location, error);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"%lld | %lld | %.2f%%", totalBytesWritten, totalBytesExpectedToWrite,(totalBytesWritten/(float)totalBytesExpectedToWrite) * 100);
    CGFloat progress = (totalBytesWritten/(float)totalBytesExpectedToWrite);
    [self.progress setProgress:progress animated:YES];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

#pragma mark - UIScrollView Delegates

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark -
#pragma mark Notification center

@end
