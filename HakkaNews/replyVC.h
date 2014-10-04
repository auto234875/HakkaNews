//
//  replyVC.h
//  HakkaNews
//
//  Created by John Smith on 1/27/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNComment.h"
#import "HNPost.h"

@interface replyVC : UIViewController
@property (nonatomic, strong)NSString *replyQuote;
@property (nonatomic, strong)HNComment *replyComment;
@property (nonatomic, strong)HNPost *replyPost;



@end
