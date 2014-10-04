//
//  settingsCell.h
//  HakkaNews
//
//  Created by John Smith on 2/14/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface settingsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *settingsTitle;
@property (weak, nonatomic) IBOutlet UISwitch *settingsSwitch;

@end
