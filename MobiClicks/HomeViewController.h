//
//  HomeViewController.h
//  MobiClicks
//
//  Created by Shiva Teja Celumula on 4/17/15.
//  Copyright (c) 2015 Mobiquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <DropboxSDK/DropboxSDK.h>


@interface HomeViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, DBRestClientDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;
@property UIImage *saveImage;
@property UIView *loadingView;
@property UIActivityIndicatorView *activityIndicator;

@property (nonatomic) DBRestClient *dbRestClient;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property double latitude;
@property double longitude;
@property NSString *city;

- (IBAction)capturePhoto:(id)sender;
- (IBAction)uploadToDropbox:(id)sender;
- (IBAction)goHome:(UIButton *)sender;
- (IBAction)closePhotoView:(UIButton *)sender;
- (IBAction)goToGallery:(id)sender;

@end

