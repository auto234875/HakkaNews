//
//  topStoriesViewController.h
//  YNews
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//

@class HNPost;
@interface topStoriesViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *currentPosts;
@property (nonatomic, strong) NSString *postType;
@property(nonatomic)BOOL reloadStories;
@property(nonatomic)BOOL limitReached;
-(void)getStories;

@end
