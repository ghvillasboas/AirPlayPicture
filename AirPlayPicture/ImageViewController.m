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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSURLSession *urlSession;
@property (strong, nonatomic) NSURLSessionDownloadTask *imageDownloadTask;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIView *fadeView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *appleTVAlertLabel;
@property (nonatomic, readonly, getter = isAppleTV) BOOL appleTV;
@end

@implementation ImageViewController

- (BOOL)isAppleTV
{
    return [[UIScreen screens] count] > 1;
}

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

- (void)setDescription:(NSString *)description
{
    if (![description isEqualToString:_description]) {
        _description = description;
        
        self.descriptionLabel.text = _description;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
}

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
    [self addLinearGradientToView:self.fadeView withColor:[UIColor clearColor] transparentToOpaque:YES];
    [self hideDescriptionViewAnimated:NO];
}

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupUI];
}

- (void)setupUIForImageDownloaded
{
    [self.spinner stopAnimating];
    self.progress.hidden = YES;
    [self.progress setProgress:0.0 animated:NO];
    self.imageView.alpha = 1.0;
}

- (void)setupUIForImageDownloading
{
    
    [self hideAppleTVAlertAnimated:YES];
    
    self.imageView.alpha = 0.3;
    [self.progress setProgress:0.0 animated:NO];
    self.progress.hidden = NO;
    [self.spinner startAnimating];
}

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

- (void)addLinearGradientToView:(UIView *)theView withColor:(UIColor *)theColor transparentToOpaque:(BOOL)transparentToOpaque
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

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"%lld | %lld | %.2f%%", totalBytesWritten, totalBytesExpectedToWrite,(totalBytesWritten/(float)totalBytesExpectedToWrite) * 100);
    CGFloat progress = (totalBytesWritten/(float)totalBytesExpectedToWrite);
    [self.progress setProgress:progress animated:YES];
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
