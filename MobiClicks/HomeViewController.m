//
//  HomeViewController.m
//  MobiClicks
//
//  Created by Shiva Teja Celumula on 4/17/15.
//  Copyright (c) 2015 Mobiquity. All rights reserved.
//

#import "HomeViewController.h"


@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        [self initializer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializer
{
    // Configuring location manager object and fetching user's location with GPS coordinates
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];

    
    // Setting loader properties
    _loadingView = [[UIView alloc] initWithFrame:self.view.frame];
    _activityIndicator = [[UIActivityIndicatorView alloc] init];
    _loadingView.backgroundColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:0.8];
    
    _activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicator.center=self.view.center;
    [_loadingView addSubview:_activityIndicator];
    [self.view addSubview:_loadingView];
    _loadingView.hidden = YES;
    
    [self showLoader];
}

#pragma mark - CoreLocation delegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get User Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self hideLoader];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    _latitude = location.coordinate.latitude;
    _longitude = location.coordinate.longitude;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error){
             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         _city = placemark.locality;
         
     }];
    
    [_locationManager stopUpdatingLocation];
    [self hideLoader];
}

#pragma mark - IBAction methods

- (IBAction)capturePhoto:(UIButton*)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    // If the device does have a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];

    } else if (sender.tag == 101) { // Navigating to photo album interface if the button tag is 101
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:picker animated:YES completion:NULL];

    }
    else { // If the device doesn't have a camera
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"This device doesn't have a camera" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
   
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    _saveImage =   [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    _photoImgView.image = _saveImage;
    _photoView.hidden = NO;
}

- (IBAction)uploadToDropbox:(id)sender
{
    NSString *fileName = [self generateUniqueID:[NSString stringWithFormat:@"%f", _latitude] longitude:[NSString stringWithFormat:@"%f", _longitude] city:_city];
    
    [self showLoader];
    
    if ([[DBSession sharedSession] isLinked]) {
        
        NSData *data = UIImagePNGRepresentation(_saveImage);
        NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        
        [data writeToFile:file atomically:YES];

        [[self dbRestClient] uploadFile:fileName toPath:@"/Apps/MobiClicks" withParentRev:nil fromPath:file];
    }
}

- (IBAction)goHome:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closePhotoView:(UIButton *)sender {
    _photoView.hidden = YES;
}

- (IBAction)goToGallery:(id)sender {
    [self performSegueWithIdentifier:@"ShowGallery" sender:nil];
}

#pragma mark - DBRestClient delegate methods

- (DBRestClient *)dbRestClient {
    if (!_dbRestClient) {
        _dbRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _dbRestClient.delegate = self;
    }
    return _dbRestClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"File has been uploaded successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [self hideLoader];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"File hasn't been uploaded successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [self hideLoader];
    
}

// Generates a uniqueID for photo name by concatenating city, latitude, longitude and timestamp
- (NSString*)generateUniqueID:(NSString*)latitude longitude:(NSString*)longitude city:(NSString*)city
{
    NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[intervalString doubleValue]];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddhhmmss"];
    
    return [NSString stringWithFormat:@"%@|%@|%@|%@.jpg", city, latitude, longitude, [formatter stringFromDate:date]];
}

- (void)showLoader
{
    [_activityIndicator startAnimating];
    _loadingView.hidden = NO;
    
}

- (void)hideLoader
{
    [_activityIndicator stopAnimating];
    _loadingView.hidden = YES;
}
@end
