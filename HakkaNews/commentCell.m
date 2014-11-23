//
//  commentCell.m
//  YNews
//
//  Created by John Smith on 1/19/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "commentCell.h"

@implementation commentCell

- (void)layoutSubviews{
    [super layoutSubviews];
    float indentPoints = self.indentationLevel * self.indentationWidth;
    
    self.contentView.frame = CGRectMake(
                                        indentPoints,
                                        self.contentView.frame.origin.y,
                                        self.contentView.frame.size.width - indentPoints,
                                        self.contentView.frame.size.height
                                        );
}

-(UILabel*)userName{
    if (!_userName) {
        _userName=[[UILabel alloc] init];
        _userName.font=[UIFont fontWithName:@"AvenirNext-DemiBold" size:15];
        _userName.textColor=[UIColor blackColor];
        _userName.textAlignment=NSTextAlignmentLeft;
        [self.contentView addSubview:_userName];
    }
    return _userName;
}
-(UILabel*)body{
    if (!_body) {
        _body=[[UILabel alloc] init];
        _body.font=[UIFont fontWithName:@"AvenirNext-Regular" size:14];
        _body.textColor=[UIColor blackColor];
        _body.textAlignment=NSTextAlignmentLeft;
        _body.numberOfLines=0;
        _body.lineBreakMode=NO;
        

        [self.contentView addSubview:_body];
    }
    return _body;
}


@end
