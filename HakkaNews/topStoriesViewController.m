//
//  topStoriesViewController.m
//  YNews
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//

#import "topStoriesViewController.h"
#import "WebViewController.h"
#import "CommentsViewController.h"
#import "MCSwipeTableViewCell.h"
#import "UIColor+Colours.h"
#import "postCell.h"
#import <SafariServices/SafariServices.h>
#import "PocketAPI.h"
#import "TWTSideMenuViewController.h"
#import "UINavigationController+M13ProgressViewBar.h"
#import "LoginVC.h"
#import "SettingsVC.h"

@interface topStoriesViewController () <UIGestureRecognizerDelegate, MCSwipeTableViewCellDelegate,UIScrollViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *readPost;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong)NSIndexPath *selectedIndexPath;
@property(nonatomic)BOOL userIsLoggedIn;
@property (nonatomic, strong)NSIndexPath *upvoteIndexPath;
@property(strong, nonatomic)UIActionSheet *as;
@property(strong,nonatomic)NSMutableArray *upvote;
@end

@implementation topStoriesViewController
-(void)didReceiveMemoryWarning
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)stopListeningToInteractivePopGestureRecognizerNotification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"popBack" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopListeningToInteractivePopGestureRecognizerNotification];

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    if ([self.readPost containsObject:post.PostId]) {
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-30;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        return textSize.height + 52;
    }
    else{
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-30;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        return textSize.height + 52;
    }
    
}
- (void)registerForInteractivePopGestureRecognizerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMenu) name:@"popBack" object:nil];
    
}
- (void)defaultStatusBarColor {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self registerForInteractivePopGestureRecognizerNotification];
    [self setStatusNavigationTitleAttribute];
    [self.tableView reloadData];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

}

-(NSMutableArray*)readPost{
    if (!_readPost) {
        _readPost = [[NSMutableArray alloc] init];
    }
    return _readPost;
}
-(NSMutableArray*)upvote{
    if (!_upvote) {
        _upvote = [[NSMutableArray alloc] init];
    }
    return _upvote;
}
- (void)saveTheListOfReadPost {
    [[NSUserDefaults standardUserDefaults] setObject:self.readPost forKey:@"listOfReadPosts"];
}
- (void)saveTheListOfUpvote {
    [[NSUserDefaults standardUserDefaults] setObject:self.upvote forKey:@"listOfUpvote"];
}
- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor blackColor]];
    [self.refreshControl addTarget:self action:@selector(loadingStories) forControlEvents:UIControlEventValueChanged];
}
- (void)loadDefaultStories {
    self.postType=@"Top";
}
- (void)setupDelegation {
    self.navigationController.interactivePopGestureRecognizer.delegate=self;
}
- (void)registerForNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupLoggedIn) name:@"userIsLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNotLoggedIn) name:@"userIsNotLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sideMenuWillClosePreparation) name:@"sideMenuWillClose" object:nil];

}
-(void)sideMenuWillClosePreparation{
    self.tableView.scrollEnabled=YES;
}
- (void)retrieveListofReadPost {
    self.readPost= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfReadPosts"] mutableCopy];
}
- (void)retrieveListofUpvote {
    self.upvote= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfUpvote"] mutableCopy];
}
- (void)setupNavigationBarAttributes {
    self.navigationController.navigationBar.tintColor=[UIColor darkGrayColor];
    self.navigationController.navigationBar.barTintColor=[UIColor snowColor];
}
- (void)setupTableViewBackgroundColor {
    self.tableView.backgroundColor=[UIColor snowColor];
}

- (void)initialUserSetup {
    if ([[HNManager sharedManager]userIsLoggedIn]) {
        self.userIsLoggedIn=YES;
        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    else{
        self.userIsLoggedIn=NO;
        self.navigationItem.rightBarButtonItem.enabled=NO;

    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupDelegation];
    [self registerForNotification];
    [self initialUserSetup];
    [self retrieveListofReadPost];
    [self retrieveListofUpvote];
    [self loadDefaultStories];
    [self getStories];
    [self setupTableViewBackgroundColor];
    [self setupRefreshControl];
    self.limitReached=NO;
    [self setupNavigationBarAttributes];
    
}
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer==self.navigationController.interactivePopGestureRecognizer) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"popBack" object:nil];
    }
    return YES;
}
-(void)setupLoggedIn{
    self.navigationItem.rightBarButtonItem.enabled=YES;
    self.userIsLoggedIn=YES;
    [self.tableView reloadData];
}
-(void)setupNotLoggedIn{
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.userIsLoggedIn=NO;
    [self.tableView reloadData];
}
- (IBAction)menuButton:(UIBarButtonItem *)sender {
    [self openMenu];
}
-(void)openMenu{
    //So the table will stop scrolling when the side menu open
    self.tableView.scrollEnabled=NO;
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}
- (void)getStories {
    self.navigationItem.title = @"Loading...";
    [self.navigationController setIndeterminate:YES];
    if ([self.postType isEqualToString:@"Top"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeTop completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                self.navigationItem.title = self.postType;
                [self.tableView reloadData];
                [self.navigationController finishProgress];

            }
            else{
                self.navigationItem.title = @"Could not retrieve posts..";
                [self.navigationController finishProgress];

            }
        }];
    }
    
    else if ([self.postType isEqualToString:@"New"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeNew completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                self.navigationItem.title = self.postType;
                
                [self.tableView reloadData];
                [self.navigationController finishProgress];

                
            }
            else{
                self.navigationItem.title = @"Could not retrieve posts..";
                [self.navigationController finishProgress];

            }
        }];
    }
    
    else if ([self.postType isEqualToString:@"Best"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeBest completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                self.navigationItem.title = self.postType;
                
                [self.tableView reloadData];
                [self.navigationController finishProgress];

                
            }
            else{
                self.navigationItem.title = @"Could not retrieve posts..";
                [self.navigationController finishProgress];

                
            }
        }];
    }
    
    else if ([self.postType isEqualToString:@"Ask"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeAsk completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                self.navigationItem.title = self.postType;
                
                [self.tableView reloadData];
                [self.navigationController finishProgress];

                
            }
            else{
                self.navigationItem.title = @"Could not retrieve posts..";
                [self.navigationController finishProgress];

                
            }
        }];
    }
    
    else if ([self.postType isEqualToString:@"Jobs"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeJobs completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                self.navigationItem.title = self.postType;
                
                [self.tableView reloadData];
                [self.navigationController finishProgress];

            }
            else{
                self.navigationItem.title = @"Could not retrieve posts..";
                [self.navigationController finishProgress];

                
            }
        }];
    }
    [self scrollToTopOfTableView];
}
- (void)scrollToTopOfTableView {
    self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
}
-(void)loadingStories{
    
    [self.refreshControl beginRefreshing];
    [self getStories];
    self.limitReached=NO;
    [self.refreshControl endRefreshing];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.currentPosts count];
}
- (void)setupCellContentViewBackgroundColor:(postCell *)cell
{
    cell.contentView.backgroundColor=[UIColor snowColor];
}

- (void)setupCellHighlightedColor:(postCell *)cell
{
    cell.postTitle.highlightedTextColor = [UIColor turquoiseColor];
    cell.postDetail.highlightedTextColor = [UIColor turquoiseColor];
}

- (void)setupCellSelectedBackgroundColor:(postCell *)cell
{
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [selectedBackgroundView setBackgroundColor:[UIColor whiteColor]]; // set color here
    [cell setSelectedBackgroundView:selectedBackgroundView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==self.as.destructiveButtonIndex) {
        HNPost *post=[self.currentPosts objectAtIndex:self.upvoteIndexPath.row];
        self.navigationItem.title = @"Upvoting...";
        [self.navigationController setIndeterminate:YES];
        [[HNManager sharedManager] voteOnPostOrComment:post direction:VoteDirectionUp completion:^(BOOL success) {
            if (success){
                [self.upvote addObject:post.PostId];
                [self saveTheListOfUpvote];
                self.navigationItem.title =@"Upvote Sucessful";
                [self.tableView reloadRowsAtIndexPaths:@[self.upvoteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.navigationController finishProgress];
                [self setDefaultNavigationTitleWithDelay];
            }
            else {
                self.navigationItem.title = @"Could Not Upvote";
                [self.navigationController finishProgress];
                [self setDefaultNavigationTitleWithDelay];
            }
        }];
    
    }
}

-(UIActionSheet*)as{
    if (!_as) {
        _as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Upvote" otherButtonTitles:nil];
    }
    return _as;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
     postCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    [self setupCellSelectedBackgroundColor:cell];
    [self setupCellHighlightedColor:cell];
    [self setupCellContentViewBackgroundColor:cell];
    return cell;
}
- (void)setupCellTrigger:(postCell *)cell {
    cell.firstTrigger = 0.1;
    cell.secondTrigger = 0.35;
}

- (void)configureCell:(postCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    //check if the post exist in readPost array and set the postTitle font accordingly
    if ([self.readPost containsObject:post.PostId]) {
        cell.postTitle.font= [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        cell.postTitle.textColor=[UIColor lightGrayColor];
    }
    else{
        cell.postTitle.font= [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        cell.postTitle.textColor=[UIColor blackColor];
    }
    cell.postTitle.text=post.Title;
   cell.postDetail.text=[NSString stringWithFormat:@"%i points by %@ %@ - %i comments", post.Points, post.Username, post.TimeCreatedString,post.CommentCount];
    UIView *commentView = [self viewWithImageName:@"Comment"];
    UIView *upvoteView=[self viewWithImageName:@"like"];
    [cell setDelegate:self];
    [self setupCellTrigger:cell];
   //setting up the vote view
    if (self.userIsLoggedIn) {
        //[HNManager sharedManager]hasVotedOnObject:post
        if (![self.upvote containsObject:post.PostId]) {
        if (post.Type == PostTypeDefault || post.Type==PostTypeAskHN) {
        [cell setSwipeGestureWithView:upvoteView color:[UIColor ghostWhiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            self.upvoteIndexPath=indexPath;
            [self.as showInView:self.tableView];}];}}}
    
[cell setSwipeGestureWithView:commentView color:[UIColor whiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
    self.selectedIndexPath = indexPath;
        if (post.Type==PostTypeDefault) {
            //if there is no comment, we don't segue
            if (post.CommentCount==0){
                self.navigationItem.title = @"No comment...";
                [self setDefaultNavigationTitleWithDelay];
            }
            else {
                //we add the post to the read post list and segue to comment
                [self.readPost addObject:post.PostId];
                [self performSegueWithIdentifier:@"showComment" sender:self];

            }
            
        }
        else if (post.Type == PostTypeAskHN){
            //we always show the comment because it's askHN
            //askHN always have at least 1 comment
            [self.readPost addObject:post.PostId];
            [self performSegueWithIdentifier:@"showComment" sender:self];

        }
        //Job Post, check to see if it's a self post or webpage by loading the first comment and checking the string
        else if (post.Type == PostTypeJobs){[[HNManager sharedManager] loadCommentsFromPost:post completion:^(NSArray *comments) {
            HNComment *firstComment = [comments firstObject];
            if (![firstComment.Text isEqualToString:@""]) {
                if (self.comments) {
                    self.comments = [comments mutableCopy];}
                else{
                    self.comments = [NSMutableArray arrayWithArray:comments];
                }
                [self.readPost addObject:post.PostId];
                [self performSegueWithIdentifier:@"showComment" sender:self];

            }
            else {
                [self.readPost addObject:post.PostId];
                [self performSegueWithIdentifier:@"showPostContent" sender:self];

            }
            
        }];}
        }];

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //get the indexpath of the selected cell so we can perform segue
    self.selectedIndexPath = indexPath;
    //retrieve the corresponding post
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    //add it to the the list of read posts
    [self.readPost addObject:post.PostId];
    //if the post is default, we go to the webpage
    if (post.Type == PostTypeDefault){
        [self performSegueWithIdentifier:@"showPostContent" sender:self];

    }
    //if the post is ask, we show the comment because AskHN is always self-post on HN
    else if (post.Type == PostTypeAskHN){
            [self performSegueWithIdentifier:@"showComment" sender:self];

        }
    //if it is a job post, we have to load the comment and check to see if it is self post or from a webpage
    else if (post.Type== PostTypeJobs){
        [[HNManager sharedManager] loadCommentsFromPost:post completion:^(NSArray *comments) {
            //getting the first comment and checking if the string is empty
            //the string is NEVER nil
            HNComment *firstComment = [comments firstObject];
            if (![firstComment.Text isEqualToString:@""]) {
                if (self.comments) {
                    self.comments = [comments mutableCopy];}
                else{
                    self.comments = [NSMutableArray arrayWithArray:comments];}
                [self performSegueWithIdentifier:@"showComment" sender:self];}
            else {
                [self performSegueWithIdentifier:@"showPostContent" sender:self];
            }
        
        
        }];}
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
HNPost *post=[self.currentPosts objectAtIndex:self.selectedIndexPath.row];
    [self saveTheListOfReadPost];

    if ([segue.identifier isEqualToString:@"showPostContent"]) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

            WebViewController *webView=segue.destinationViewController;
            //the post that we reply to from the webview
            webView.replyPost = post;
    }
    else if ([segue.identifier isEqualToString:@"showComment"]) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        CommentsViewController *cvc=segue.destinationViewController;
        //The post that we comment reply to
        cvc.replyPost = post;
    }
    
    else if ([segue.identifier isEqualToString:@"showLogin"]){
        LoginVC *lvc=segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:@"showSettings"]){
        SettingsVC *svc=segue.destinationViewController;
    }
}
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    //disable cell selection to prevent crashing
    //[self.tableView setAllowsSelection:NO];
}
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    //When user cancel swipe, this reenable selection with delay to prevent crashing
    //[self.tableView performSelector:@selector(setAllowsSelection:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
}
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage {
}
-(UIView *)viewWithImageName:(NSString *)imageName {
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeCenter;
        return imageView;
}
-(void)setDefaultNavigationTitleAttributeWithDelay{
    [self.navigationController.navigationBar performSelector:@selector(setTitleTextAttributes:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,[UIColor blackColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"HelveticaNeue-Light" size:19], NSFontAttributeName, nil]
                                                              afterDelay:2];
}
-(void)setStatusNavigationTitleAttribute{
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor blackColor],NSForegroundColorAttributeName,
                                                                   [UIColor blackColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"HelveticaNeue-Light" size:19], NSFontAttributeName, nil];
}
-(void)setDefaultNavigationTitleWithDelay{
    [self.navigationItem performSelector:@selector(setTitle:) withObject:self.postType afterDelay:2];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Displaying the last cell, so we will load more stories
   if(indexPath.row == [self.currentPosts count] - 1){
           if (self.limitReached==NO) {
           if (![self.postType isEqualToString:@"Jobs"]){
        self.navigationItem.title=@"Loading more...";
               [self.navigationController setIndeterminate:YES];
        [[HNManager sharedManager] loadPostsWithUrlAddition:[[HNManager sharedManager] postUrlAddition] completion:^(NSArray *posts, NSString *urlAddition) {
            if (posts) {
                [self.currentPosts addObjectsFromArray:posts];
                [self.tableView reloadData];
                self.navigationItem.title=self.postType;
                [self.navigationController finishProgress];
                if ([posts count]==0) {
                    self.limitReached=YES;
                    self.navigationItem.title=@"Could not load more";
                    [self.navigationController setIndeterminate:YES];
                    [self setDefaultNavigationTitleWithDelay];

                }
            }
            
        }];
        }}}

    

}
@end
