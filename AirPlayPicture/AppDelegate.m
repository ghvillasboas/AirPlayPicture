//
//  AppDelegate.m
//  AirPlayPicture
//
//  Created by George Villasboas on 8/19/14.
//  Copyright (c) 2014 Logics Software. All rights reserved.
//

#import "AppDelegate.h"
#import "ImagesCollectionViewController.h"
#import "ImageViewController.h"

@interface AppDelegate ()
@property (strong, nonatomic) NSMutableArray *windows;
@property (strong, nonatomic, readonly) UIStoryboard *storyboard;
@property (strong, nonatomic, readonly) UIStoryboard *storyboardATV;
@end

@implementation AppDelegate

- (NSMutableArray *)windows
{
    if (!_windows) {
        _windows = [[NSMutableArray alloc] init];
    }
    
    return _windows;
}

- (UIStoryboard *)storyboard
{
    UIStoryboard *storyboard;
    UIDevice *device = [UIDevice currentDevice];
    
    if(device.userInterfaceIdiom == UIUserInterfaceIdiomPad){
        // iPad
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    else if(device.userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        // iPhone
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    
    return storyboard;
}

- (UIStoryboard *)storyboardATV
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_AppleTV" bundle:nil];
    
    return storyboard;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIWindow *window;
    NSArray *screens = [UIScreen screens];
    
    if (screens.count > 1) {
        for (UIScreen *screen in screens) {
            
            if (screen == [UIScreen mainScreen]) {
                ImagesCollectionViewController *controller = [self.storyboard instantiateInitialViewController];
                window = [self createWindowForScreen:screen];
                
                window.rootViewController = controller;
                window.hidden = NO;
                [window makeKeyAndVisible];
            }
            else{
                ImageViewController *ivc = [self.storyboardATV instantiateInitialViewController];
                window = [self createWindowForScreen:screen];
                window.rootViewController = ivc;
                window.hidden = NO;
            }

        }
    }
    
    // Register for notification
    [self registerForScreenNotifications];
    
    return YES;
}

/**
 *  Register for screen notifications
 */
- (void)registerForScreenNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(screenConnected:)
												 name:UIScreenDidConnectNotification
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(screenDisconnected:)
												 name:UIScreenDidDisconnectNotification
											   object:nil];
}

/**
 *  Remove self from screen notifications
 */
- (void)unregisterForScreenNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidConnectNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
}

- (void)screenConnected:(NSNotification *)notification
{
    NSLog(@"%s", __FUNCTION__);
    UIScreen *screen = notification.object;
    [self prepareScreen:screen];
}

- (void)screenDisconnected:(NSNotification *)notification
{
    NSLog(@"%s", __FUNCTION__);
    UIScreen *screen = notification.object;
    
    if ([self.windows containsObject:screen]) {
        [self.windows removeObject:screen];
    }
}

/**
 *  Prepare the connected screen (as suggested in http://adcdownload.apple.com//wwdc_2011/adc_on_itunes__wwdc11_sessions__pdf/406_airplay_and_external_displays_in_ios_apps.pdf)
 *
 *  @param connectedScreen The connected screen
 */
- (void)prepareScreen:(UIScreen *)connectedScreen
{
    UIWindow *window;
    ImageViewController *controller;
    
    window = [self createWindowForScreen:connectedScreen];
    controller = [self.storyboardATV instantiateInitialViewController];
    
    window.rootViewController = controller;
    window.hidden = NO;
}

/**
 *  Create or reuse a window for the connected screen
 *
 *  @param screen The connected screen
 *
 *  @return The window object
 */
- (UIWindow *)createWindowForScreen:(UIScreen *)screen {
    
    UIWindow *newWindow;
    
    // Do we already have a window for this screen?
    for (UIWindow *window in self.windows){
        if (window.screen == screen){
            newWindow = window;
        }
    }
    
    
    // Still nil? Create a new one.
    if (!newWindow){
        newWindow = [[UIWindow alloc] init];
        newWindow.screen = screen;
        [self.windows addObject:newWindow];
    }
    
    // update frame
    CGRect frame = screen.bounds;
    newWindow.frame = frame;
    
    return newWindow;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [self unregisterForScreenNotifications];
}

@end
