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

@end
