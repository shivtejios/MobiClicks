//
//  GalleryViewController.h
//  MobiClicks
//
//  Created by Shiva Teja Celumula on 4/18/15.
//  Copyright (c) 2015 Mobiquity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "AppDelegate.h"
#import "Photo.h"


@interface GalleryViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DBRestClientDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *fullImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property NSString* photosHash;
@property (nonatomic) DBRestClient* restClient;
@property NSArray *photoPaths;
@property UIView *loadingView;
@property UIActivityIndicatorView *activityIndicator;

@property UIImage *image;
@property NSArray *dataArray;

- (IBAction)closeView:(UIButton *)sender;
- (IBAction)back:(UIButton *)sender;
- (IBAction)refresh:(UIButton *)sender;


@end
