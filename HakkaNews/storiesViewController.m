//
//  storiesViewController.m
//  YNews
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//

#import "storiesViewController.h"
#import "topStoriesViewController.h"
#import "HNPost.h"
#import "UIColor+Colours.h"
#import "PocketAPI.h"
#import  <Social/Social.h>
#import "TWTSideMenuViewController.h"
#import "HNUser.h"
#import "UIImage+ImageEffects.h"

@interface storiesViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableMenu;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property(strong,nonatomic)NSArray *menuItems;
@property(nonatomic,strong)NSString *storiesType;
@property(nonatomic)BOOL userIsLoggedIn;
@property(nonatomic)BOOL twitterIsAvailable;
@property(nonatomic)NSUInteger animateCounter;
@property(nonatomic,strong)UIActionSheet *as;

@end
@implementation storiesViewController
-(UIActionSheet*)as{
    if (!_as) {
        _as=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
    }
    return _as;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==self.as.destructiveButtonIndex) {
        [[HNManager sharedManager]logout];
        [self checkLoginStatus];
    }
}
- (void)closeMenu {
    [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
}

- (IBAction)panGestureHandle:(UIPanGestureRecognizer *)sender {
    CGPoint vel = [sender velocityInView:self.view];
    if (vel.x > 0)
    {
        // user dragged towards the right
    }
    else
    {
        // user dragged towards the left
        [self closeMenu];
        
    }
}
-(NSArray*)menuItems{
    if (!_menuItems) {
        _menuItems=@[@"Top",@"New",@"Best",@"Ask",@"Jobs",@"Settings",@"Login",@"Contact"];
    }
    return _menuItems;
}
- (void)registerForNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSupport) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performLoggedInSetup) name:@"userIsLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(performNotLoggedInSetup) name:@"userIsNotLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setupSupport) name:@"twitterIsAvailable" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeSupport) name:@"twitterIsNotAvailable" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sideMenuWillOpenPreparation) name:@"sideMenuWillOpen" object:nil];
}
-(void)sideMenuWillOpenPreparation{
    self.animateCounter=0;
    [self.tableMenu reloadData];
}
- (void)setupLoginChecker {
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(checkLoginStatus)
                                   userInfo:nil
                                    repeats:YES];
}
- (void)removeFooter {
    self.tableMenu.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
- (void)setupUsernameAttributes {
    self.userName.textColor=[UIColor whiteColor];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupUsernameAttributes];
    [self checkSupport];
    [self setupLoginChecker];
    [self registerForNotification];
    [self removeFooter];
    //self.backgroundImageView.image=self.backgroundImage;

}


-(void)openMenuSetup{
    
}
-(void)performLoggedInSetup{
    NSString *userName=[[HNManager sharedManager]SessionUser].Username;
    NSInteger karma=[[HNManager sharedManager]SessionUser].Karma;
    self.userName.text=[NSString stringWithFormat:@"%@ (%li)",userName,(long)karma];
    if (self.twitterIsAvailable){
    self.menuItems=@[@"Top",@"New",@"Best",@"Ask",@"Jobs",@"Settings",@"Logout",@"Contact"];
    }
    else{
    self.menuItems=@[@"Top",@"New",@"Best",@"Ask",@"Jobs",@"Settings",@"Logout"];
    }
    [self.tableMenu reloadData];
    }
-(void)performNotLoggedInSetup{
    self.userName.text=@"";
    if ([[SLComposeViewController class] isAvailableForServiceType: SLServiceTypeTwitter]){
        self.menuItems=@[@"Top",@"New",@"Best",@"Ask",@"Jobs",@"Settings",@"Login",@"Contact"];
    }
    else{
        self.menuItems=@[@"Top",@"New",@"Best",@"Ask",@"Jobs",@"Settings",@"Login"];
    }
    [self.tableMenu reloadData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.menuItems count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [selectedBackgroundView setBackgroundColor:[UIColor clearColor]]; // set color here
    [cell setSelectedBackgroundView:selectedBackgroundView];
    cell.textLabel.highlightedTextColor = [UIColor turquoiseColor];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.animateCounter<8) {
    cell.layer.transform = CATransform3DMakeScale(0.3, 0.3, 0.1);
    cell.alpha = 0;
    
    [UIView animateWithDuration:0.3f
                          delay:0+0.040*indexPath.row
     //             usingSpringWithDamping:0.7
     //              initialSpringVelocity:0.5
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         cell.layer.transform = CATransform3DIdentity;
                         cell.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.animateCounter +=1;
                         }
                     }];
    }
}
- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureTextLabel:cell forRowAtIndexPath:indexPath];
}
-(void)configureTextLabel:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    if (indexPath.row==6) {
        if (self.userIsLoggedIn) {
            cell.textLabel.text=@"Log out";
        }
        else{
            cell.textLabel.text=@"Login";
        }
    }
    else{cell.textLabel.text=[self.menuItems objectAtIndex:indexPath.row];
}
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==6) {
        if (!self.userIsLoggedIn) {
            //[self performSegueWithIdentifier:@"showLogin" sender:self];
            [self showLogin];
            [self.tableMenu deselectRowAtIndexPath:indexPath animated:NO];
        }else{
            [self.as showInView:self.view];
            [self.tableMenu deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    if (indexPath.row<5) {
        self.storiesType=[self.menuItems objectAtIndex:indexPath.row];
        [self loadStoriesAndCloseSideMenu];
    }
    if (indexPath.row==7) {
        [self support];
    }
    if (indexPath.row==5) {
        //[self performSegueWithIdentifier:@"showSettings" sender:self];
        [self showSettings];
        [self.tableMenu deselectRowAtIndexPath:indexPath animated:NO];
    }
}
-(void)showSettings{
    UINavigationController *x=(UINavigationController*) self.sideMenuViewController.mainViewController;
    topStoriesViewController *y=[[x viewControllers] objectAtIndex:0];
    [self closeMenu];
    [y performSegueWithIdentifier:@"showSettings" sender:y];
}
-(void)showLogin{
    UINavigationController *x=(UINavigationController*) self.sideMenuViewController.mainViewController;
    topStoriesViewController *y=[[x viewControllers] objectAtIndex:0];
    [self closeMenu];
    [y performSegueWithIdentifier:@"showLogin" sender:y];
    

}
-(void)loadStoriesAndCloseSideMenu{
        UINavigationController *x=(UINavigationController*) self.sideMenuViewController.mainViewController;
        topStoriesViewController *y=[[x viewControllers] objectAtIndex:0];
        y.postType=self.storiesType;
        y.limitReached=NO;

        [y getStories];
        [self closeMenu];
}
-(void)setupSupport{
    if (self.userIsLoggedIn) {
     self.menuItems=@[@"Top",@"New",@"Best",@"Ask",@"Jobs",@"Settings",@"Logout",@"Contact"];
    }
    else{
        self.menuItems=@[@"Top",@"New",@"Best",@"Ask",@"Jobs",@"Settings",@"Login",@"Contact"];
    }
    [self.tableMenu reloadData];
}
-(void)removeSupport{
    if (self.userIsLoggedIn) {
        self.menuItems=@[@"Top",@"New",@"Best",@"Ask",@"Jobs",@"Settings",@"Logout"];
    }
    else{
        self.menuItems=@[@"Top",@"New",@"Best",@"Ask",@"Jobs",@"Settings",@"Login"];
    }
    [self.tableMenu reloadData];
}
-(void)checkSupport{
    if ([[SLComposeViewController class] isAvailableForServiceType: SLServiceTypeTwitter]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"twitterIsAvailable" object:nil];
        self.twitterIsAvailable=YES;

    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"twitterIsNotAvailable" object:nil];
        self.twitterIsAvailable=NO;

    }
}
-(void)support{
    SLComposeViewController * composeVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeVC setInitialText:@"@HakkaNews "];
    [self presentViewController:composeVC animated:YES completion:^{
        [self.tableMenu reloadData];
    }];
}
-(void)checkLoginStatus{
    if ([[HNManager sharedManager] userIsLoggedIn]) {
        if (!self.userIsLoggedIn) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userIsLoggedIn" object:nil];
        }
        self.userIsLoggedIn=YES;
    }
    else{
        if (self.userIsLoggedIn){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userIsNotLoggedIn" object:nil];
        }
        self.userIsLoggedIn=NO;
    }
}

-(void)karmaChangeNotification{
    
}

@end
