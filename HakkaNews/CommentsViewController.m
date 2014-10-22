//
//  CommentsViewController.m
//  YNews
//
//  Created by John Smith on 1/18/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "CommentsViewController.h"
#import "HNComment.h"
#import "commentCell.h"
#import "MCSwipeTableViewCell.h"
#import "UIColor+Colours.h"
#import "HNManager.h"
#import "replyVC.h"
#import "topStoriesViewController.h"
#import "UINavigationController+M13ProgressViewBar.h"
@interface CommentsViewController ()<MCSwipeTableViewCellDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableSet *commentID;
@property (nonatomic, strong)UIRefreshControl *refreshControl;
@property(nonatomic)BOOL userIsLoggedIn;
@property(nonatomic,strong)UIActionSheet *as;
@property(nonatomic,strong)NSIndexPath *voteIndexPath;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitCommentButton;
@property(strong,nonatomic)NSMutableArray *upvoteComment;
@property(strong,nonatomic)NSMutableArray *downvoteComment;
@end

@implementation CommentsViewController
-(void)saveListOfUpvoteComment{
    [[NSUserDefaults standardUserDefaults] setObject:self.upvoteComment forKey:@"listOfUpvoteComment"];

}
-(void)saveListOfDownvoteComment{
    [[NSUserDefaults standardUserDefaults] setObject:self.downvoteComment forKey:@"listOfDownvoteComment"];

}
-(void)retrieveListOfDownvoteComment{
    self.downvoteComment= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfDownvoteComment"] mutableCopy];

}
-(void)retrieveListOfUpvoteComment{
    self.upvoteComment= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfUpvoteComment"] mutableCopy];
}
-(void)canRotate{}
- (void)initialUserSetup {
    if ([[HNManager sharedManager]userIsLoggedIn]) {
        self.userIsLoggedIn=YES;
        if (self.replyPost.Type !=PostTypeJobs) {
            self.navigationItem.rightBarButtonItem.enabled=YES;
        }
        else{
            self.navigationItem.rightBarButtonItem.enabled=NO;
        }
    }
    else{
        self.userIsLoggedIn=NO;
        self.navigationItem.rightBarButtonItem.enabled=NO;

    }
}
-(NSMutableSet*)commentID{
    if (!_commentID) {
        _commentID = [[NSMutableSet alloc] init];
    }
    return _commentID;
}
-(NSMutableArray*)upvoteComment{
    if (!_upvoteComment) {
        _upvoteComment = [[NSMutableArray alloc] init];
    }
    return _upvoteComment;
}
-(NSMutableArray*)downvoteComment{
    if (!_downvoteComment) {
        _downvoteComment = [[NSMutableArray alloc] init];
    }
    return _downvoteComment;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.comments count];
}
- (void)setupCellSelectedBackGroundColor:(commentCell *)cell
{
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    commentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}
- (void)setupCellTextColor:(commentCell *)cell {
    cell.userName.textColor=[UIColor blackColor];
    cell.content.textColor=[UIColor blackColor];
}
- (void)setupCellContentViewBackgroundColor:(commentCell *)cell {
    cell.contentView.backgroundColor=[UIColor snowColor];
}
- (void)setupCellBackgroundColor:(commentCell *)cell {
    cell.backgroundColor=[UIColor snowColor];
}
- (void)setupCellTrigger:(commentCell *)cell {
    cell.firstTrigger = 0.1;
    cell.secondTrigger = 0.35;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[self.as buttonTitleAtIndex:buttonIndex] isEqualToString:@"Upvote"]) {
        HNComment *comment=[self.comments objectAtIndex:self.voteIndexPath.row];
        self.navigationItem.title = @"Upvoting...";
        [self.navigationController setIndeterminate:YES];
        [[HNManager sharedManager] voteOnPostOrComment:comment direction:VoteDirectionUp completion:^(BOOL success) {
            if (success){
                [self.upvoteComment addObject:comment.CommentId];
                [self saveListOfUpvoteComment];
                self.navigationItem.title =@"Upvote Sucessful";
                [self.tableView reloadRowsAtIndexPaths:@[self.voteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
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
   else if ([[self.as buttonTitleAtIndex:buttonIndex] isEqualToString:@"Downvote"]) {
        HNComment *comment=[self.comments objectAtIndex:self.voteIndexPath.row];
        self.navigationItem.title = @"Downvoting...";
       [self.navigationController setIndeterminate:YES];
        [[HNManager sharedManager] voteOnPostOrComment:comment direction:VoteDirectionDown completion:^(BOOL success) {
            if (success){
                [self.downvoteComment addObject:comment.CommentId];
                [self saveListOfDownvoteComment];
                self.navigationItem.title =@"Downvote Sucessful";
                [self.tableView reloadRowsAtIndexPaths:@[self.voteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.navigationController finishProgress];
                [self setDefaultNavigationTitleWithDelay];
            }
            else {
                self.navigationItem.title = @"Could Not Downvote";
                [self.navigationController finishProgress];
                [self setDefaultNavigationTitleWithDelay];
            }
        }];
        
    }
    
}

-(void)setDefaultNavigationTitleWithDelay{
    [self.navigationItem performSelector:@selector(setTitle:) withObject:self.title afterDelay:2];
}
- (void)configureCell:(commentCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HNComment *comment = [self.comments objectAtIndex:indexPath.row];
    [self setupCellBackgroundColor:cell];
    [self setupCellContentViewBackgroundColor:cell];
    [self setupCellSelectedBackGroundColor:cell];

    cell.userName.text = comment.Username;
    cell.content.text = comment.Text;
    [self setupCellTextColor:cell];
    cell.indentationLevel =comment.Level;
    cell.indentationWidth = 13;
    
    
    float indentPoints = cell.indentationLevel * cell.indentationWidth;
    
    cell.contentView.frame = CGRectMake(indentPoints,cell.contentView.frame.origin.y,cell.contentView.frame.size.width - indentPoints,cell.contentView.frame.size.height);
    
  
    
    UIView *action = [self viewWithImageName:@"action"];
    UIView *submit=[self viewWithImageName:@"submit"];
    
    
    [cell setDefaultColor:self.tableView.backgroundView.backgroundColor];
    
    [cell setDelegate:self];
    
    [self setupCellTrigger:cell];
    
    if (self.userIsLoggedIn) {
        if (comment.Type != HNCommentTypeJobs){
            if ([[HNManager sharedManager]SessionUser].Karma >=500) {
                if (![self.upvoteComment containsObject:comment.CommentId] || ![self.downvoteComment containsObject:comment.CommentId]) {
                [cell setSwipeGestureWithView:action color:[UIColor ghostWhiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    self.voteIndexPath=indexPath;
                    if (![self.upvoteComment containsObject:comment.CommentId] && ![self.downvoteComment containsObject:comment.CommentId]) {
                        self.as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Upvote",@"Downvote",nil];
                        [self.as showInView:self.tableView];
                    }
                    else if (![self.upvoteComment containsObject:comment.CommentId] && [self.downvoteComment containsObject:comment.CommentId]) {
                        self.as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Upvote",nil];
                        [self.as showInView:self.tableView];
                        
                    }
                    else if ([self.upvoteComment containsObject:comment.CommentId] && ![self.downvoteComment containsObject:comment.CommentId]) {
                        self.as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Downvote",nil];
                        [self.as showInView:self.tableView];
                        
                    }
            }];}}
            else{
                if(![self.upvoteComment containsObject:comment.CommentId]){
                [cell setSwipeGestureWithView:action color:[UIColor ghostWhiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    NSLog(@"%@ id of upvoted comment",comment.CommentId);
                    self.voteIndexPath=indexPath;
                    self.as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Upvote",nil];
                    [self.as showInView:self.tableView];
                }];}
            }
            
        [cell setSwipeGestureWithView:submit color:[UIColor whiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                self.replyComment = comment;
                [self performSegueWithIdentifier:@"reply" sender:self];
            }];
        }}
}

- (void)setupTableViewBackgroundColor {
    self.tableView.backgroundColor=[UIColor snowColor];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HNComment *comment = [self.comments objectAtIndex:indexPath.row];
    //job comments cannot be collapsed
    if (comment.Type !=HNCommentTypeJobs) {
        //check to see if the comment has already been collapsed
        //collapse and expand as neccessary
    if ([self.commentID containsObject:comment.CommentId]) {
        [self.commentID removeObject:comment.CommentId];
    }
    else{
        [self.commentID addObject:comment.CommentId];
    }

        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   [super tableView:tableView heightForRowAtIndexPath:indexPath];
    HNComment *comment    = [self.comments objectAtIndex:indexPath.row];
    //return collapsed cell height
    if ([self.commentID containsObject:comment.CommentId]) {
        return 41;
    }
    else{
        //comment level *indentation width-padding
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
    CGFloat cellWidth= self.tableView.frame.size.width-(comment.Level *13.0)-20;
    CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
    CGSize textSize = [comment.Text boundingRectWithSize:boundingSize
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{ NSFontAttributeName : textFont }
                                  context:nil].size;
        //50 is accounting for padding and username label
        return textSize.height + 50;
    }
    
}
-(UIView *)viewWithImageName:(NSString *)imageName {
            UIImage *image = [UIImage imageNamed:imageName];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeCenter;
            return imageView;
        }
- (IBAction)showReplyVC:(UIBarButtonItem *)sender {
    
    [self performSegueWithIdentifier:@"reply" sender:sender];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"reply"]) {
        replyVC *rvc= segue.destinationViewController;
        if ([sender isKindOfClass:[CommentsViewController class]]) {
            rvc.replyComment = self.replyComment;
            rvc.replyQuote= self.replyComment.Text;
    }
        
        else if ([sender isKindOfClass:[UIBarButtonItem class]]){
            rvc.replyPost = self.replyPost;
        }
    }
}
- (void)setupDefaultNavTitleAttributes {
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,[UIColor blackColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"HelveticaNeue-Light" size:19], NSFontAttributeName, nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupDefaultNavTitleAttributes];
    //[self defaultStatusBarColor];
    [self registerForInteractivePopGestureRecognizerNotification];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController finishProgress];
    [self stopListeningToInteractivePopGestureRecognizerNotification];

}
- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor blackColor]];
    
    [self.refreshControl addTarget:self action:@selector(activateRefreshControl) forControlEvents:UIControlEventValueChanged];
}
- (void)defaultStatusBarColor {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
-(void)setupLoggedIn{
    if (self.replyPost.Type !=PostTypeJobs) {
        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    else{
        self.navigationItem.rightBarButtonItem.enabled=NO;
    }
    self.userIsLoggedIn=YES;
    [self.tableView reloadData];
}
-(void)setupNotLoggedIn{
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.userIsLoggedIn=NO;
    [self.tableView reloadData];
}
- (void)setupFooterView {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupLoggedIn) name:@"userIsLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNotLoggedIn) name:@"userIsNotLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadComments) name:@"replySuccessful" object:nil];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self retrieveListOfDownvoteComment];
    [self retrieveListOfUpvoteComment];
    [self initialUserSetup];
    [self reloadComments];
    [self initialUserSetup];
    [self setupRefreshControl];
    [self setupTableViewBackgroundColor];
    [self registerNotification];
    [self setupFooterView];
    
}
- (void)reloadComments {
    self.navigationItem.title = @"Loading Comments...";
    [self.navigationController setIndeterminate:YES];
    [[HNManager sharedManager] loadCommentsFromPost:self.replyPost completion:^(NSArray *comments) {
        if (comments){
            self.comments=comments;
            self.title = self.replyPost.Title;
            
            [self.tableView reloadData];
            self.navigationItem.title = self.title ;
            [self.navigationController finishProgress];

            
        }
        else{
            self.navigationItem.title = @"Could not reload comments";
            [self.navigationController finishProgress];
        }
        
    }];
}
-(void)activateRefreshControl{
    [self.refreshControl beginRefreshing];
    [self reloadComments];
    [self.refreshControl endRefreshing];
}
- (IBAction)popVC:(UIBarButtonItem *)sender {
    [self backToStories];
}
- (void)registerForInteractivePopGestureRecognizerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToStories) name:@"popBack" object:nil];
    
}
-(void)backToStories{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)stopListeningToInteractivePopGestureRecognizerNotification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"popBack" object:nil];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}





@end
