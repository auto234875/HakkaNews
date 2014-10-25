//
//  SettingsVC.m
//  HakkaNews
//
//  Created by John Smith on 2/14/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "SettingsVC.h"
#import "settingsCell.h"
#import "PocketAPI.h"

@interface SettingsVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *settingsItems;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *settingsBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *settingsItem;

@end

@implementation SettingsVC
- (void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)settingSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"SwitchState"];
    if (sender.isOn){
        [[PocketAPI sharedAPI] loginWithHandler: ^(PocketAPI *API, NSError *error){
            if (error != nil)
            {
                sender.on=NO;
            }
            else
            {
            }
        }];
    }
    else{
        [[PocketAPI sharedAPI] logout];

    }
    
        
        
}
-(void)setStatusNavigationTitleAttribute{
    self.settingsBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor blackColor],NSForegroundColorAttributeName,
                                                                   [UIColor blackColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"HelveticaNeue-Light" size:19], NSFontAttributeName, nil];
}

-(NSArray*)settingsItems{
    if (_settingsItems) {
        _settingsItems=@[@"Pocket"];
    }
    return _settingsItems;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    settingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.settingsTitle=[self.settingsItems objectAtIndex:indexPath.row];
    cell.settingsSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"SwitchState"];
    return cell;
}
- (void)removeFooter {
    self.settingsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
-(void)viewDidLoad{
    [self removeFooter];
    [self setStatusNavigationTitleAttribute];
    self.view.backgroundColor=[UIColor whiteColor];
    [self setupSettingsNavigationBar];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    closeButton.tintColor=[UIColor blackColor];
    self.settingsItem.leftBarButtonItem=closeButton;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
- (void)setupSettingsNavigationBar {
    [self.settingsBar setBackgroundImage:[UIImage new]
                           forBarMetrics:UIBarMetricsDefault];
    self.settingsBar.shadowImage = [UIImage new];
    self.settingsBar.translucent = YES;
    self.settingsBar.backgroundColor = [UIColor whiteColor];
    self.settingsBar.tintColor=[UIColor blackColor];
}


@end
