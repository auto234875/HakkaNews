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


@interface replyVC ()<UITextViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic)UIButton *replyButton;
@property (strong, nonatomic)UITextView *replyText;
@property(strong, nonatomic)UIActionSheet *as;
@property (strong, nonatomic)UIButton *discardButton;
@end

@implementation replyVC
- (void)HUDCouldNotReply {
    //self.replyItem.title = @"Could not reply";
    //could not reply animation here
}

- (void)HUDReplySuccess {
    //reply successful animation here
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"replySuccessful" object:nil];
        
    }];
}

- (void)reply{
    self.replyButton.enabled= NO;
    //start progress animation
    if (self.replyPost) {
        self.replyButton.enabled=NO;
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

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor snowColor];
    self.discardButton=[[UIButton alloc] init];
    self.discardButton.frame=CGRectMake(10, 20, 60, 44);
    [self.discardButton setTitle:@"Discard" forState:UIControlStateNormal];

    self.discardButton.titleLabel.font=[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:17];
    [self.discardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.discardButton.backgroundColor=[UIColor snowColor];
    self.replyButton=[[UIButton alloc] init];
    [self.replyButton setTitle:@"Reply" forState:UIControlStateNormal];

    self.replyButton.frame=CGRectMake(self.view.bounds.size.width-65, 20, 60, 44);
    self.replyButton.titleLabel.text=@"Reply";
    self.replyButton.titleLabel.font=[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:17];
    [self.replyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.replyButton.backgroundColor=[UIColor snowColor];
    [self.discardButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.replyButton addTarget:self action:@selector(reply) forControlEvents:UIControlEventTouchUpInside];
    CALayer *layer=[CALayer layer];
    layer.backgroundColor=[UIColor blackColor].CGColor;
    layer.frame=CGRectMake(15, 64, self.view.bounds.size.width-30, 0.3);
    [self.view addSubview:self.discardButton];
    [self.view addSubview:self.replyButton];
    [self.view.layer addSublayer:layer];
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

- (void)cancel{
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



@end
