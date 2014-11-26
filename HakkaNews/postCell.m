//
//  postCell.m
//  YNews
//
//  Created by John Smith on 1/23/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "postCell.h"

@implementation postCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(UILabel*)postTitle{
    if (!_postTitle) {
        _postTitle=[[UILabel alloc] init];
        _postTitle.font=[UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        _postTitle.textColor=[UIColor blackColor];
        _postTitle.textAlignment=NSTextAlignmentLeft;
        _postTitle.numberOfLines=0;

        [self.contentView addSubview:_postTitle];
    }
    return _postTitle;
}
-(UILabel*)postDetail{
    if (!_postDetail) {
        _postDetail=[[UILabel alloc] init];
        _postDetail.font=[UIFont fontWithName:@"AvenirNext-Regular" size:11];
        _postDetail.textColor=[UIColor blackColor];
        _postDetail.textAlignment=NSTextAlignmentLeft;
        _postDetail.lineBreakMode=NO;
        
        
        [self.contentView addSubview:_postDetail];
    }
    return _postDetail;
}

@end
