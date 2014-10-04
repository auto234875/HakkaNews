//
//  CommentsViewController.h
//  YNews
//
//  Created by John Smith on 1/18/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HNComment;
#import "HNPost.h"

@interface CommentsViewController : UITableViewController
@property (nonatomic, strong)NSArray *comments;
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)HNPost *replyPost;
@property (nonatomic, strong)HNComment *replyComment;
@end
