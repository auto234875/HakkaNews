//
//  AppDelegate.m
//  YNews
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//

#import "AppDelegate.h"
#import "HNManager.h"
#import "storiesViewController.h"
#import "PocketAPI.h"
#import "TWTSideMenuViewController.h"
#import "topStoriesViewController.h"
#import "storiesViewController.h"
#import "UIImage+ImageEffects.h"
@interface AppDelegate()
@property(nonatomic,strong)TWTSideMenuViewController *sideMenuVC;
@property(nonatomic,strong)storiesViewController *stvc;
@property(nonatomic,strong)topStoriesViewController *tvc;
@property(nonatomic,strong)UINavigationController *nav;
@property(nonatomic,strong)UIImage *backgroundImage;

@end

@implementation AppDelegate

- (void)startHNsession
{
    [[HNManager sharedManager] startSession];
}

- (void)setupPocket
{
    [[PocketAPI sharedAPI] setConsumerKey:@"23344-c7d00c8b0846ebd1ecd75032"];
}

- (void)setupSideMenuVC
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.stvc =[sb instantiateViewControllerWithIdentifier:@"stories"];
    
    //self.tvc = [sb instantiateViewControllerWithIdentifier:@"topStories"];
    self.nav=[sb instantiateViewControllerWithIdentifier:@"nav"];
    topStoriesViewController *tsvc=[[self.nav viewControllers]objectAtIndex:0];
    self.backgroundImage=[UIImage imageNamed:@"69.PNG"];
    tsvc.loginBackgroundImage=self.stvc.backgroundImage=self.backgroundImage;
    self.sideMenuVC = [[TWTSideMenuViewController alloc] initWithMenuViewController:self.stvc mainViewController:self.nav];
    self.sideMenuVC.shadowColor = [UIColor whiteColor];
    self.sideMenuVC.edgeOffset = (UIOffset) { .horizontal = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 18.0f : 0.0f };
    self.sideMenuVC.zoomScale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0.5634f : 0.85f;
    self.sideMenuVC.delegate = self;
    self.window.rootViewController = self.sideMenuVC;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self startHNsession];
    [self setupPocket];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self setupSideMenuVC];
    return YES;
}

#pragma mark - TWTSideMenuViewControllerDelegate

/*- (UIStatusBarStyle)sideMenuViewController:(TWTSideMenuViewController *)sideMenuViewController statusBarStyleForViewController:(UIViewController *)viewController
{
    if (viewController == self.stvc) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}*/
- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sideMenuWillOpen" object:nil];
}
- (void)sideMenuViewControllerWillCloseMenu:(TWTSideMenuViewController *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sideMenuWillClose" object:nil];
}

- (void)sideMenuViewControllerDidOpenMenu:(TWTSideMenuViewController *)sideMenuViewController{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sideMenuDidOpen" object:nil];

}
- (void)sideMenuViewControllerDidCloseMenu:(TWTSideMenuViewController *)sideMenuViewController{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sideMenuDidClose" object:nil];

}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    if([[PocketAPI sharedAPI] handleOpenURL:url]){
        return YES;
    }else{
        // if you handle your own custom url-schemes, do it here
        return NO;
    }
    
}

@end

