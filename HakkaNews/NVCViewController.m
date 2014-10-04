//
//  NVCViewController.m
//  HakkaNews
//
//  Created by John Smith on 2/11/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "NVCViewController.h"
#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.m"
#import "storiesViewController.h"


@interface NVCViewController ()

@end

@implementation NVCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[storiesViewController class]]) {
        self.slidingViewController.underLeftViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"stories"];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
