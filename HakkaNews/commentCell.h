//
//  commentCell.h
//  YNews
//
//  Created by John Smith on 1/19/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@interface commentCell : MCSwipeTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *content;

@end
