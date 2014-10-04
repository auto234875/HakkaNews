//
//  postCell.h
//  YNews
//
//  Created by John Smith on 1/23/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "MCSwipeTableViewCell.h"

@interface postCell : MCSwipeTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *postDetail;

@end
