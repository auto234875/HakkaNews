//
//  AppDelegate.m
//  YNews
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//

#import "AppDelegate.h"
#import "HNManager.h"
#import "PocketAPI.h"
#import "topStoriesViewController.h"
@interface AppDelegate()
@property(nonatomic,strong)topStoriesViewController *tvc;
@property(nonatomic,strong)UINavigationController *nav;

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[HNManager sharedManager] startSession];
    [[PocketAPI sharedAPI] setConsumerKey:@"23344-c7d00c8b0846ebd1ecd75032"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.tvc =[[topStoriesViewController alloc] init];
    self.window.rootViewController = self.tvc;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
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

