//
//  topStoriesViewController.h
//  YNews
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNPost.h"
#import "HNManager.h"
#import "WebViewController.h"

@interface topStoriesViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *currentPosts;
@property (nonatomic, strong) NSString *postType;
@property(nonatomic)BOOL reloadStories;
@property(nonatomic)BOOL limitReached;
@property(nonatomic,weak)UIImage *loginBackgroundImage;

-(void)loadingStories;
-(void)getStories;

@end
