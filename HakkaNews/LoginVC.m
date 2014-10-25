//
//  LoginVC.m
//  YNews
//
//  Created by John Smith on 1/24/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "LoginVC.h"
#import "HNManager.h"
#import "HNUser.h"
#import "UIColor+Colours.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+tintImage.h"
#import "FBShimmeringLayer.h"
#import "FBShimmeringView.h"


@interface LoginVC ()<UITextFieldDelegate>
@property (strong, nonatomic)  UITextField *username;
@property (strong, nonatomic)  UITextField *password;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIView *separatorView;
@property(strong,nonatomic)FBShimmeringView *shimmeringView;
@property (strong, nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)NSArray *closeButtonContraint;

@end

@implementation LoginVC

#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.height == 736.0)


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
}


- (void)addingSubView {
    [self.view addSubview:self.shimmeringView];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.password];
    [self.view addSubview:self.username];
    [self.view addSubview:self.separatorView];
}

- (void)setupCloseButton {

    [self.closeButton setImage:[[UIImage imageNamed:@"cancel"] tintedImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
    [self.closeButton setImage:[[UIImage imageNamed:@"cancel"] tintedImageWithColor:[UIColor turquoiseColor]] forState:UIControlStateHighlighted];
    [self.closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alreadyLoggedInSetup) name:@"userIsLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];

}
-(void)keyboardWillHide{
    CGFloat fivex=35.5;
    CGFloat fivey=fivex-0.5;
    CGFloat fivez=fivey-50;
    CGFloat fourx=35.5;
    CGFloat foury=fourx-0.5;
    CGFloat fourz=foury-50;
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         if (IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6_PLUS) {
                         self.password.frame=CGRectMake(20, (self.view.frame.size.height/2)+fivex, self.view.frame.size.width-40,50);
                         self.separatorView.frame=CGRectMake(20, (self.view.frame.size.height/2)+fivey, self.password.frame.size.width,.5);
                         self.username.frame=CGRectMake(20, (self.view.frame.size.height/2)+fivez, self.password.frame.size.width, self.password.frame.size.height);
                             self.shimmeringView.frame=CGRectMake((self.view.bounds.size.width/2)-140, 110, 280, 59);
                         }
                        
                         else{
                             self.password.frame=CGRectMake(20, (self.view.frame.size.height/2)+fourx, self.view.frame.size.width-40,50);
                             self.separatorView.frame=CGRectMake(20, (self.view.frame.size.height/2)+foury, self.password.frame.size.width,.5);
                             self.username.frame=CGRectMake(20, (self.view.frame.size.height/2)+fourz, self.password.frame.size.width, self.password.frame.size.height);
                             self.shimmeringView.frame=CGRectMake(20, 80, 280, 59);
                             
                         }
                     }
                     completion:^(BOOL finished){}];
  
}

-(void)keyboardWillShow:(NSNotification*)aNotification{
    NSDictionary *info=[aNotification userInfo];
    CGSize keyboardSize=[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self updatePasswordFrameForShownKeyboard:keyboardSize];
    
}


-(void)updatePasswordFrameForShownKeyboard:(CGSize)keyboardSize{
    CGFloat fivex=119;
    CGFloat fivey=fivex+1;
    CGFloat fivez=fivey+50;
    CGFloat fourx=70;
    CGFloat foury=fourx+1;
    CGFloat fourz=foury+50;
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         if (IS_IPHONE_5) {
                         self.password.frame=CGRectMake(20, self.view.frame.size.height-fivex-keyboardSize.height, self.view.frame.size.width-40,50);
                         self.separatorView.frame=CGRectMake(20, self.view.frame.size.height-fivey-keyboardSize.height, self.password.frame.size.width,1);
                         self.username.frame=CGRectMake(20, self.view.frame.size.height-fivez-keyboardSize.height, self.password.frame.size.width, self.password.frame.size.height);
                             self.shimmeringView.frame=CGRectMake(20, 70, 280, 59);
                             
                         }
                         else if (IS_IPHONE_6 || IS_IPHONE_6_PLUS) {
                             self.password.frame=CGRectMake(20, (self.view.frame.size.height/2)+35.5, self.view.frame.size.width-40,50);
                             self.separatorView.frame=CGRectMake(20, (self.view.frame.size.height/2)+35, self.password.frame.size.width,.5);
                             self.username.frame=CGRectMake(20, (self.view.frame.size.height/2)-15, self.password.frame.size.width, self.password.frame.size.height);
                             self.shimmeringView.frame=CGRectMake((self.view.bounds.size.width/2)-140, 110, 280, 59);
                         }
                         else{
                             self.password.frame=CGRectMake(20, self.view.frame.size.height-fourx-keyboardSize.height, self.view.frame.size.width-40,50);
                             self.separatorView.frame=CGRectMake(20, self.view.frame.size.height-foury-keyboardSize.height, self.password.frame.size.width,1);
                             self.username.frame=CGRectMake(20, self.view.frame.size.height-fourz-keyboardSize.height, self.password.frame.size.width, self.password.frame.size.height);
                             self.shimmeringView.frame=CGRectMake(20, 50, 280, 59);
                         }

                     }
                     completion:^(BOOL finished){}];
    
}



- (void)createCloseButton {
    self.closeButton=[[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-44.5, self.view.frame.size.height-15-89, 89, 89)];
}

- (void)createCustomSubviews {
    self.view.backgroundColor= [UIColor whiteColor];
    self.password=[[UITextField alloc] init];
    self.username=[[UITextField alloc]init];
    self.separatorView=[[UIView alloc]init];
    self.shimmeringView=[[FBShimmeringView alloc] init];
    self.titleLabel=[[UILabel alloc] initWithFrame:self.shimmeringView.bounds];
    self.shimmeringView.contentView=self.titleLabel;
}

- (void)setupTitleLabel {
    self.titleLabel.text=@"Hacker News";
    self.titleLabel.font=[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:51];
    self.titleLabel.textColor=[UIColor blackColor];
}

-(void)viewDidLoad{
    [self registerNotification];
    [self createCloseButton];
    [self setupCloseButton];
    [self createCustomSubviews];
    self.separatorView.backgroundColor=[UIColor lightGrayColor];
    self.shimmeringView.shimmeringSpeed=375;
    self.shimmeringView.shimmeringOpacity=0.15;
    [self keyboardWillHide];
    [self setupTitleLabel];
    [self addingSubView];
    [self setupTextField];
    
}


-(void)setupTextField{
    self.username.delegate = self;
    self.password.delegate = self;
    self.username.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:22];
    self.password.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:22];
    self.password.textColor=[UIColor blackColor];
    self.username.textColor=[UIColor blackColor];
    self.username.tintColor=[UIColor blackColor];
    self.password.tintColor=[UIColor blackColor];
    self.password.secureTextEntry=YES;
    self.username.keyboardAppearance=UIKeyboardAppearanceDark;
    self.password.keyboardAppearance=UIKeyboardAppearanceDark;
    self.username.autocorrectionType=UITextAutocorrectionTypeNo;
    self.password.autocorrectionType=UITextAutocorrectionTypeNo;
    self.username.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.password.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [self setupPlaceHolder];
    
}
-(void)setupPlaceHolder{
    UIColor *color = [UIColor lightGrayColor];
    self.username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"username" attributes:@{NSForegroundColorAttributeName: color}];
    self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"password" attributes:@{NSForegroundColorAttributeName: color}];
}

-(void)alreadyLoggedInSetup{
  
    [self dismiss];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.username) {
        [self.password becomeFirstResponder];
    }
    
    else if (textField == self.password){
        
            [self.password resignFirstResponder];
            self.username.userInteractionEnabled=NO;
            self.password.userInteractionEnabled=NO;
            self.username.tintColor=[UIColor clearColor];
            self.password.tintColor=[UIColor clearColor];
            self.username.textColor=[UIColor clearColor];
            self.password.textColor=[UIColor clearColor];
            self.separatorView.backgroundColor=[UIColor clearColor];
            [self moveTitleLabel];
            
            [[HNManager sharedManager] loginWithUsername:self.username.text password:self.password.text completion:^(HNUser *user) {
            if (user) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"userIsLoggedIn" object:nil];
                
                
            }
            else{
                self.shimmeringView.shimmering=NO;
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Something went wrong" message:@"Try again!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                [self keyboardWillHide];
                self.shimmeringView.shimmering=NO;
                self.username.tintColor=[UIColor blackColor];
                self.password.tintColor=[UIColor blackColor];
                self.username.textColor=[UIColor blackColor];
                self.password.textColor=[UIColor blackColor];
                self.separatorView.backgroundColor=[UIColor lightGrayColor];
                self.username.userInteractionEnabled=YES;
                self.password.userInteractionEnabled=YES;
                
            }
            }];
        
    
    }

    return  YES;

    
    

}

-(void)moveTitleLabel
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.shimmeringView.frame=CGRectMake((self.view.bounds.size.width/2)-140, (self.view.frame.size.height/2)-(self.titleLabel.frame.size.height/2), 280, 59);
                         
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                         self.shimmeringView.shimmering=YES;
                         
                         }}];
    
    
}


@end
