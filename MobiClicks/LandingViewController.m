//
//  LandingViewController.m
//  MobiClicks
//
//  Created by Shiva Teja Celumula on 4/18/15.
//  Copyright (c) 2015 Mobiquity. All rights reserved.
//

#import "LandingViewController.h"


@interface LandingViewController ()

@end

@implementation LandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Checking dropbox link active status
    
    if ([[DBSession sharedSession] isLinked]) {
        [_signInBtn setTitle:@"       Sign Out" forState:UIControlStateNormal];
        [_statusImage setImage:[UIImage imageNamed:@"online.png"]];
    }
    else {
        [_signInBtn setTitle:@"       Sign In" forState:UIControlStateNormal];
        [_statusImage setImage:[UIImage imageNamed:@"offline.png"]];
    }
}

#pragma mark - IBAction Methods

- (IBAction)signIn:(UIButton*)sender {
    
    // Navigating to Dropbox API login page, if app is not linked
    if (![[DBSession sharedSession] isLinked])
    {
        [[DBSession sharedSession] linkFromController:self];
    }
    else {
        [[DBSession sharedSession] unlinkAll];
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Information" message:@"Signed Out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
        [_signInBtn setTitle:@"       Sign In" forState:UIControlStateNormal];
        [_statusImage setImage:[UIImage imageNamed:@"offline.png"]];
    }
}


- (IBAction)getStarted:(UIButton*)sender {
    
    // Checking for linked status, to navigate to next scene
    if ([[DBSession sharedSession] isLinked]) {
        
        [self performSegueWithIdentifier:@"GetStarted" sender:nil];
    }
    else {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Information" message:@"Please sign in to Dropbox first" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
