//
//  GalleryViewController.m
//  MobiClicks
//
//  Created by Shiva Teja Celumula on 4/18/15.
//  Copyright (c) 2015 Mobiquity. All rights reserved.
//

#import "GalleryViewController.h"

@interface GalleryViewController ()

@end

@implementation GalleryViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
     [self.restClient loadMetadata:@"/Apps/MobiClicks" withHash:_photosHash];
    
    [self fetchData];
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 14.0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    Photo *photo = _dataArray[indexPath.row];
    
    // Resizing and setting the image to CollectionView cell
    UIImage *image = [UIImage imageWithData:photo.imageData];
    CGSize scaleSize = CGSizeMake(105, 105);
    UIGraphicsBeginImageContextWithOptions(scaleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
     cell.backgroundColor = [UIColor colorWithPatternImage:resizedImage];
    
    return cell;
}

#pragma mark DBRestClientDelegate methods

- (DBRestClient*)restClient {
    if (_restClient == nil) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    
    _photosHash = metadata.hash ;
    
    NSArray* validExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", nil];
    NSMutableArray* newPhotoPaths = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
        NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            [newPhotoPaths addObject:child.path];
        }
    }
    _photoPaths = newPhotoPaths;
    
    for (NSString* photoPath in _photoPaths)
    {
        NSString *fileName = [NSTemporaryDirectory() stringByAppendingPathComponent:[photoPath componentsSeparatedByString:@"/"][3]] ;
        
        [self.restClient loadThumbnail:photoPath ofSize:@"iphone_bestfit" intoPath:fileName];
    }
    [self hideLoader];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    [self displayError];
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
   
    // Seperating all the values from the file name and storing it in database
    
    NSArray *fileArray = [destPath componentsSeparatedByString:@"/"];
    NSString *fileName = fileArray[fileArray.count-1];
    NSArray *fileNameArray = [fileName componentsSeparatedByString:@"|"];
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:destPath], 0.7);
    
    NSString *title = [fileNameArray[3] componentsSeparatedByString:@"."][0];
    NSNumber *lat = @([fileNameArray[1] intValue]);
    NSNumber *lon = @([fileNameArray[2] intValue]);
    NSString *city = fileNameArray[0];
    
    [self savePhotoWithTitle:title imageData: imageData city:city latitude:lat longitude:lon];
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
    [self displayError];
}

- (void)displayError {
    [[[UIAlertView alloc] initWithTitle:@"Error Loading Photo"
                                           message:@"There was an error loading your photo."
                                           delegate:nil
                              cancelButtonTitle:@"OK"
                             otherButtonTitles:nil]
     show];
}

#pragma mark - CoreData 

- (NSManagedObjectContext *)managedObjectContext
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    return managedObjectContext;
}

- (void)fetchData {
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Photo" inManagedObjectContext:moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];

        NSError *error;
        _dataArray = [moc executeFetchRequest:request error:&error];
    

}

// Saving the photo to database
- (BOOL)savePhotoWithTitle:(NSString*)title imageData:(NSData*)imageData city:(NSString*)city latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude {
    
    _managedObjectContext = [self managedObjectContext];
    
    BOOL result = NO;

    Photo *newPhoto = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Photo"
                       inManagedObjectContext:_managedObjectContext];
    
    if (newPhoto == nil) {
        NSLog(@"Failed to create the new Photo");
        return NO;
    }
    
    newPhoto.title = title;
    newPhoto.imageData = imageData;
    newPhoto.city = city;
    newPhoto.latitude = latitude;
    newPhoto.longitude = longitude;

    NSError *error = nil;
    
    if ([_managedObjectContext save:&error]) {
        NSLog(@"save");
        return YES;
    } else {
        NSLog(@"Failed to save the new Photo. Error = %@", error);
    }
    return result;
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

#pragma mark - IBAction methods

- (IBAction)closeView:(UIButton *)sender {
    _photoView.hidden = YES;
}

- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refresh:(UIButton *)sender {
    [self.collectionView reloadData];
}


#pragma mark <UICollectionViewDelegate>


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Photo *photo = _dataArray[indexPath.row];
    
   _fullImageView.image = [UIImage imageWithData:photo.imageData];
    _titleLbl.text = photo.city;
    _photoView.hidden = NO;
    
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


@end
