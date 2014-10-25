//
//  WebViewController.m
//  YNews
//
//  Created by John Smith on 1/13/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//
#import "WebViewController.h"
#import "topStoriesViewController.h"
#import "UIColor+Colours.h"
#import "CommentsViewController.h"
#import "replyVC.h"
#import "DRPocketActivity.h"
#import "PocketAPI.h"
#import "UINavigationController+M13ProgressViewBar.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "TUSafariActivity.h"


@interface WebViewController () <UIGestureRecognizerDelegate, UIWebViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *postContentWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *commentButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (weak, nonatomic) IBOutlet UIToolbar *webTool;
@property(nonatomic)BOOL userIsLoggedIn;
@property(nonatomic)BOOL hiddenNavBar;
@property(nonatomic,strong)M13ProgressHUD *HUD;
@property(nonatomic)BOOL finishProgressPoppingBack;
@end
@implementation WebViewController
- (void)setupNavTitleAttribute {
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor blackColor],NSForegroundColorAttributeName,[UIColor blackColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"HelveticaNeue-Light" size:11], NSFontAttributeName, nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNavTitleAttribute];
    
    if (self.replyPost.CommentCount==0) {
        self.commentButton.enabled = NO;
    }
    //[self registerForInteractivePopGestureRecognizerNotification];
}
/*- (void)registerForInteractivePopGestureRecognizerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTheProgressBar) name:@"popBack" object:nil];
}
- (void)stopListeningToInteractivePopGestureRecognizerNotification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"popBack" object:nil];
}
-(void)stopTheProgressBar{
    [self.navigationController finishProgress];
}*/
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.postContentWebView.delegate=nil;


}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [self setupDelegation];
    [self registerNotification];

}

-(void)setHiddenNavBar:(BOOL)hiddenNavBar{
    _hiddenNavBar=hiddenNavBar;
    [self setupTopView];

    
}

-(void)setupTopView{
    if (self.hiddenNavBar==NO) {
        
        self.webTool.hidden=NO;
        
    }else{
        
        self.webTool.hidden=YES;
    }
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if(translation.y >0)
    {
        
        self.hiddenNavBar=NO;
    } else if (translation.y < 0)
    {
        self.hiddenNavBar=YES;
    }
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.hiddenNavBar=NO;
    //[self stopListeningToInteractivePopGestureRecognizerNotification];
    if (!self.finishProgressPoppingBack) {
        [self.navigationController finishProgress];
    }



}

- (void)setupInitialWebNavButton {
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
}
-(void)setupLoggedIn{
    self.userIsLoggedIn=YES;
    if(self.replyPost.Type !=PostTypeJobs){
        self.submitButton.enabled=YES;
    }
    else{
        self.submitButton.enabled=NO;
    }
    
}
-(void)setupNotLoggedIn{
    self.userIsLoggedIn=NO;
    self.submitButton.enabled=NO;
    
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupLoggedIn) name:@"userIsLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNotLoggedIn) name:@"userIsNotLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
}
-(void)restartAnimation{
    [self.HUD setIndeterminate:YES];
}

- (void)setupDelegation {
    self.postContentWebView.scrollView.delegate=self;
}
- (void)initialUserSetup {
    if ([[HNManager sharedManager]userIsLoggedIn]) {
        self.userIsLoggedIn=YES;
        if(self.replyPost.Type !=PostTypeJobs){
            self.submitButton.enabled=YES;
        }
        else{
            self.submitButton.enabled=NO;
        }
    }
    else{
        self.userIsLoggedIn=NO;
        self.submitButton.enabled=NO;
    }
}

- (M13ProgressHUD*)HUD {
    if (!_HUD) {
    _HUD = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
    _HUD.progressViewSize = CGSizeMake(60.0, 60.0);
    [_HUD setIndeterminate:YES];
    _HUD.secondaryColor=[UIColor whiteColor];
    _HUD.primaryColor=[UIColor whiteColor];
    _HUD.statusColor=[UIColor whiteColor];
    _HUD.statusFont=[UIFont fontWithName:@"HelveticaNeue-Light" size:19];
    }
    return _HUD;
}

- (void)setupWebView {
    NSURL *postContentURL=[NSURL URLWithString:self.replyPost.UrlString];
    NSURLRequest *postContentRequest= [NSURLRequest requestWithURL:postContentURL];
    self.postContentRequest= postContentRequest;
    [self.postContentWebView loadRequest:self.postContentRequest];
}

-(void) viewDidLoad{
    [self setupWebView];
    //[self registerNotification];
    [self setupInitialWebNavButton];
    [self initialUserSetup];
    //[self setupDelegation];
    self.hiddenNavBar=NO;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //[self.activityIndicator stopAnimating];
    if ([self.postContentWebView canGoBack]) {
        self.backButton.enabled = YES;
    }
    else{
        self.backButton.enabled = NO;
    }
    
    if ([self.postContentWebView canGoForward]) {
        self.forwardButton.enabled = YES;
    }
    else{
        self.forwardButton.enabled = NO;
    }
    self.navigationItem.title = [self.postContentWebView.request.URL absoluteString];
    [self.navigationController finishProgress];
    


}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [self.navigationController setIndeterminate:YES];
    return YES;
}



- (IBAction)goBack:(UIBarButtonItem *)sender {
    [self.postContentWebView goBack];
    self.navigationItem.title = [self.postContentWebView.request.URL absoluteString];



}

- (IBAction)goForward:(UIBarButtonItem *)sender {
    [self.postContentWebView goForward];
    self.navigationItem.title = [self.postContentWebView.request.URL absoluteString];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showCommentVC"]){
        self.finishProgressPoppingBack=YES;
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        CommentsViewController *scvc=segue.destinationViewController;
        scvc.replyPost = self.replyPost;
    }
    
    else if ([segue.identifier isEqualToString:@"showReplyVC"]){
        replyVC *rvc = segue.destinationViewController;
        rvc.replyPost= self.replyPost;
    }
}

- (void)HUDSaved {
    self.HUD.status=@"Saved";
    [self.HUD show:YES];
    [self.HUD performAction:M13ProgressViewActionSuccess animated:YES];
    [self.HUD performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.7];
}

- (void)HUDUnableToSave {
    self.HUD.status=@"Unable to Save";
    [self.HUD show:YES];
    [self.HUD performAction:M13ProgressViewActionFailure animated:YES];
    [self.HUD performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.5];
}

- (IBAction)share:(UIBarButtonItem *)sender {
    if (![self.HUD isDescendantOfView:self.view] ) {
        [self.view addSubview:self.HUD];
    }
    TUSafariActivity *openInSafari=[[TUSafariActivity alloc]init];


    BOOL login = [[PocketAPI sharedAPI] isLoggedIn];
    if (login) {
    DRPocketActivity *pocketActivity = [[DRPocketActivity alloc] init];
    NSArray *applicationActivities = @[openInSafari,pocketActivity];
	
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:self.postContentWebView.request.URL, nil] applicationActivities:applicationActivities];
        activityController.completionHandler = ^(NSString *activityType, BOOL completed) {
            if ([activityType isEqualToString:pocketActivity.activityType]) {
                if (completed) {
                    [self HUDSaved];
                }
                else{
                    [self HUDUnableToSave];
                }
                
            }
            else if ([activityType isEqualToString:UIActivityTypeAddToReadingList]) {
                if (completed) {
                    [self HUDSaved];
                }
                else{
                    [self HUDUnableToSave];
                }
                
            }};
        
            activityController.excludedActivityTypes=@[UIActivityTypeAirDrop];
        [self presentViewController:activityController animated:YES completion:nil];
    }
    else{
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:self.postContentWebView.request.URL, nil] applicationActivities:@[openInSafari]];
        activityController.completionHandler = ^(NSString *activityType, BOOL completed) {
            if ([activityType isEqualToString:UIActivityTypeAddToReadingList]) {
                if (completed) {
                    [self HUDSaved];
                }
                else{
                    [self HUDUnableToSave];
                }
            }
            
        };
        activityController.excludedActivityTypes=@[UIActivityTypeAirDrop];
        [self presentViewController:activityController animated:YES completion:nil];
    }
    
   
    
}





@end
