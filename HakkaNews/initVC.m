//
//  initVC.m
//  HakkaNews
//
//  Created by John Smith on 2/11/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "initVC.h"

@interface initVC ()

@end

@implementation initVC

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
	// Do any additional setup after loading the view.
    self.topViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
