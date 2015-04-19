//
//  LandingViewController.h
//  MobiClicks
//
//  Created by Shiva Teja Celumula on 4/18/15.
//  Copyright (c) 2015 Mobiquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface LandingViewController : UIViewController <DBRestClientDelegate>

@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UIButton *getStartedBtn;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;

- (IBAction)signIn:(UIButton*)sender;
- (IBAction)getStarted:(UIButton*)sender;

@end
