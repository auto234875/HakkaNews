//
//  WebViewController.h
//  YNews
//
//  Created by John Smith on 1/13/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNPost.h"

@interface WebViewController : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) NSURLRequest *postContentRequest;
@property(strong, nonatomic) NSString *urlString;
@property (strong, nonatomic)HNPost *replyPost;
@end
