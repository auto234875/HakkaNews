//
//  replyVC.m
//  HakkaNews
//
//  Created by John Smith on 1/27/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "replyVC.h"
#import "HNManager.h"
#import "UIColor+Colours.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "M13ProgressView.h"

@interface replyVC ()<UITextViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *replyButton;
@property (weak, nonatomic) IBOutlet UITextView *replyText;
@property(strong, nonatomic)UIActionSheet *as;
@property (weak, nonatomic) IBOutlet UINavigationBar *replyBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *replyItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *discardButton;
@property(nonatomic,strong)M13ProgressHUD *HUD;
@end

@implementation replyVC
- (void)HUDCouldNotReply {
    //self.replyItem.title = @"Could not reply";
    self.HUD.status=@"Could not Reply";
    [self.HUD performAction:M13ProgressViewActionFailure animated:YES];
    [self.HUD performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:2.0];
}

- (void)HUDReplySuccess {
    [self.HUD hide:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"replySuccessful" object:nil];
        
    }];
}

- (IBAction)reply:(UIBarButtonItem *)sender {
    self.replyButton.enabled= NO;
    [self.HUD setIndeterminate:YES];
    if (self.replyPost) {
        self.replyButton.enabled=NO;
        self.HUD.status=@"Replying..";
        [self.HUD show:YES];
        [self.HUD performAction:M13ProgressViewActionNone animated:YES];
        [[HNManager sharedManager] replyToPostOrComment:self.replyPost withText:self.replyText.text completion:^(BOOL success) {
            if (success) {
                [self HUDReplySuccess];
            }
            else{
                [self HUDCouldNotReply];
                self.replyButton.enabled=YES;
            }
        }];
    }
    
    else if (self.replyComment){
        self.replyButton.enabled=NO;
        self.HUD.status=@"Replying..";
        [self.HUD show:YES];
        [self.HUD performAction:M13ProgressViewActionNone animated:YES];
        [[HNManager sharedManager] replyToPostOrComment:self.replyComment withText:self.replyText.text completion:^(BOOL success) {
            if (success) {
                [self HUDReplySuccess];
                }
            else{
                [self HUDCouldNotReply];
                self.replyButton.enabled=YES;
            }
        }];
    }

}


- (void)setupDefaultStatusBarColor {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if (self.replyQuote) {
        self.replyText.text=[NSString stringWithFormat:@">%@ ", self.replyQuote];
        [self textViewDidChangeSelection:self.replyText];
      }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void)setupNavigationBarColor {
    [self.replyBar setBackgroundImage:[UIImage new]
                        forBarMetrics:UIBarMetricsDefault];
    self.replyBar.shadowImage = [UIImage new];
    self.replyBar.translucent = YES;
    self.replyBar.backgroundColor = [UIColor clearColor];
    self.replyBar.tintColor=[UIColor whiteColor];
}

- (void)setupButtonTitleTextAttributes {
    [self.discardButton setTitleTextAttributes:@{
                                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:17],
                                                 NSForegroundColorAttributeName: [UIColor blackColor]
                                                 } forState:UIControlStateNormal];
    [self.replyButton setTitleTextAttributes:@{
                                               NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:17],
                                               NSForegroundColorAttributeName: [UIColor blackColor]
                                               } forState:UIControlStateNormal];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupHUD];
    [self setupNavigationBarColor];
    [self setupButtonTitleTextAttributes];
    self.replyBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor blackColor],NSForegroundColorAttributeName,
                                                                   [UIColor blackColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"HelveticaNeue-Light" size:19], NSFontAttributeName, nil];
    [self.replyText becomeFirstResponder];

}

- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        // leave 7 pixels margin
            offset.y += overflow+7;
        
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

-(void)textViewDidChangeSelection:(UITextView *)textView{
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top);
    
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow+7; // leave 7 pixels margind

        
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    if (!self.as) {
        self.as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Discard Draft" otherButtonTitles:nil];
    }
    [self.as showInView:self.view];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==self.as.destructiveButtonIndex) {
        [self.replyText resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:^{
        }];

    }
}
- (void)setupHUD {
    self.HUD = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
    self.HUD.progressViewSize = CGSizeMake(60.0, 60.0);
    [self.view addSubview:self.HUD];
    //[self.HUD setIndeterminate:YES];
    //self.HUD.hudBackgroundColor=[UIColor snowColor];
    self.HUD.secondaryColor=[UIColor whiteColor];
    self.HUD.primaryColor=[UIColor whiteColor];
    self.HUD.statusColor=[UIColor whiteColor];
    //self.HUD.maskType=M13ProgressHUDMaskTypeGradient;
    self.HUD.statusFont=[UIFont fontWithName:@"HelveticaNeue-Light" size:19];
}



@end
