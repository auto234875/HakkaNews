//
//  submitVC.m
//  YNews
//
//  Created by John Smith on 1/25/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "submitVC.h"
#import "HNManager.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Colours.h"

@interface submitVC ()<UITextFieldDelegate, UITextViewDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *submissionTitle;
@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (weak, nonatomic) IBOutlet UITextView *mainText;
@property (weak, nonatomic) IBOutlet UINavigationItem *submitBar;
@property (weak, nonatomic) IBOutlet UINavigationBar *loginNavBar;
@property(strong, nonatomic)UIActionSheet *as;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *discardButton;

@end

@implementation submitVC

- (void)ConfigureTextFieldsPlaceHolderColor:(UIColor *)color {
    self.submissionTitle.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName: color}];
    self.url.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"url" attributes:@{NSForegroundColorAttributeName: color}];
}

- (void)configureTextfieldsTintColor {
    self.submissionTitle.tintColor=[UIColor blackColor];
    self.url.tintColor=[UIColor blackColor];
}

- (void)setupBarButtonItemTitleTextAttributes {
    [self.discardButton setTitleTextAttributes:@{
                                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:17],
                                                 NSForegroundColorAttributeName: [UIColor blackColor]
                                                 } forState:UIControlStateNormal];
    [self.submitButton setTitleTextAttributes:@{
                                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:17],
                                                NSForegroundColorAttributeName: [UIColor blackColor]
                                                } forState:UIControlStateNormal];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    UIColor *color = [UIColor lightGrayColor];
    [self ConfigureTextFieldsPlaceHolderColor:color];
    [self configureTextfieldsTintColor];
    [self setupBarButtonItemTitleTextAttributes];
    self.loginNavBar.titleTextAttributes=[NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIColor blackColor],NSForegroundColorAttributeName,
                                          [UIColor blackColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"HelveticaNeue-Light" size:19], NSFontAttributeName, nil];

}
- (void)configureNavigationBarColor {
    [self.loginNavBar setBackgroundImage:[UIImage new]
                           forBarMetrics:UIBarMetricsDefault];
    self.loginNavBar.shadowImage = [UIImage new];
    self.loginNavBar.translucent = YES;
    self.loginNavBar.backgroundColor = [UIColor clearColor];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.submissionTitle becomeFirstResponder];

}
-(UIActionSheet*)as{
    if (!_as) {
        _as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Discard Draft" otherButtonTitles:nil];
    }
    return _as;
}
- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.as showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==self.as.destructiveButtonIndex) {
        if (self.submissionTitle.isFirstResponder) {
            [self.submissionTitle resignFirstResponder];
        }
        else if(self.url.isFirstResponder){
            [self.url resignFirstResponder];
        }
        else{
            [self.mainText resignFirstResponder];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        }
}
- (IBAction)submit:(UIBarButtonItem*)sender {
    self.submitButton.enabled=NO;
    //No title, must have title
    if ([self.submissionTitle.text isEqualToString:@""]) {
        self.submitBar.title = @"Must have title";
        self.submitButton.enabled=YES;
    }
    
    
    else {
            if (![self.url.text isEqualToString:@""]) {
                self.submitButton.enabled=NO;
                self.submitBar.title = @"Submitting...";
                [[HNManager sharedManager] submitPostWithTitle:self.submissionTitle.text link:self.url.text text:nil completion:^(BOOL success) {
                if(success){
                    [self dismissViewControllerAnimated:YES
                                                                      completion:nil];
                }
                else{
                    self.submitBar.title = @"Could not submit";
                    self.submitButton.enabled=YES;
                }
            }];}
        
            else {
                     if ([self.mainText.text isEqualToString:@""]) {
                         self.submitBar.title = @"Must have url or text";
                         self.submitButton.enabled=YES;
                     }
                    else {
                        self.submitButton.enabled=NO;
                        self.submitBar.title = @"Submitting...";
                        [[HNManager sharedManager] submitPostWithTitle:self.submissionTitle.text link:nil text:self.mainText.text completion:^(BOOL success) {
                if (success) {
                    [self dismissViewControllerAnimated:YES
                                             completion:nil];
                }
                else{
                    self.submitBar.title = @"Could not submit";
                    self.submitButton.enabled=YES;

                }
            }];}
        }}


}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField==self.submissionTitle) {
        [self.url becomeFirstResponder];
        return YES;
    }
    else if (textField==self.url){
        [self.mainText becomeFirstResponder];
        return YES;
    }
    return YES;
    
}

- (void)textViewDidChange:(UITextView *)textView {
   
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top);
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
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
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}
@end
