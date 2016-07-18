//
//  UserSpotCreationVC.m
//  MapSpot
//
//  Created by DetroitLabs on 5/29/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "UserSpotCreationVC.h"
#import "FirebaseOperation.h"
#import "CurrentUser.h"
@import Photos;

@interface UserSpotCreationVC ()
@property (weak, nonatomic) IBOutlet UITextView *messageTF;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *photoLibraryCollectionView;

@property (nonatomic, strong) PHAssetCollection *photoLibrary;
@property (nonatomic, strong) NSMutableArray *spotMediaItems;
@property (nonatomic) CGSize assetThumbnailSize;
@property (nonatomic, strong) PHImageRequestOptions *requestOptions;
@property (nonatomic, strong) PHFetchResult *imageAssests;
@property (nonatomic, strong) PHImageManager *manager;

@end

@implementation UserSpotCreationVC

#pragma mark Lifecycle methods

- (void)viewDidLoad {
    [self.navigationController setNavigationBarHidden:FALSE];
    _manager = [[PHImageManager alloc] init];
    [super viewDidLoad];
    
    [self accessDevicePhotoLibrary:^(PHFetchResult *cameraRollAssets) {
        
        _imageAssests = cameraRollAssets;
        
        [_photoLibraryCollectionView reloadData];

    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Help Methods

//Customizes the subviews
-(void)viewWillLayoutSubviews {
    _mediaCollectionView.layer.borderWidth = 1.0;
    _mediaCollectionView.layer.borderColor = [[UIColor blackColor]CGColor];
    _mediaCollectionView.layer.backgroundColor = [[UIColor whiteColor]CGColor];
    
}

/*
 Accepts a date and turns it into a string.
 We use this to store date on Firebase as a string because Firebase doesn't accept NSDate.
 */

 -(NSString *)dateToStringFormatter:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:date];
}

-(void)accessDevicePhotoLibrary:(void(^)(PHFetchResult *cameraRollAssets))completion {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    
    _requestOptions = [[PHImageRequestOptions alloc]init];
    _requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    _requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    self.requestOptions.synchronous = true;
    
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
    
    PHAssetCollection *cameraRoll = result.firstObject;
    
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:fetchOptions];

    completion(assets);

}

#pragma mark Firebase Helper Methods

/*
 Used to create a spot when the createSpotButton is pressed.
 It then saves the spot to Firebase.
*/
-(void)createSpotWithMessage:(NSString *)message latitude:(NSString *)latitude longitude:(NSString *)longitude {
    NSDate *now = [NSDate date];

    FIRUser *currentUserAuth = [[FIRAuth auth]currentUser];
    CurrentUser *currentUser = [CurrentUser sharedInstance];
    
    NSDictionary *spot = @{@"userId": currentUserAuth.uid,
                           @"username": currentUser.username,
                           @"email": currentUserAuth.email,
                           @"latitude":latitude,
                           @"longitude": longitude,
                           @"message": message,
                           @"createdAt": [self dateToStringFormatter:now]};
    
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    
    [firebaseOperation setValueForFirebaseChild:@"spots" value:spot];

}

#pragma mark Photo Library CollectionView

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView.tag == 1) {
        return [_imageAssests count];
    } else {
        return [_spotMediaItems count];
    }
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView.tag == 1) {

        PHAsset *asset = _imageAssests[indexPath.item];
        
        UICollectionViewCell *photoLibraryCell = [_photoLibraryCollectionView dequeueReusableCellWithReuseIdentifier:@"photoLibraryCell" forIndexPath:indexPath];
        
        _assetThumbnailSize = CGSizeMake(100,100);
        
        UIImageView *photoLibraryCellImageView = (UIImageView *)[photoLibraryCell viewWithTag:200];

        [_manager requestImageForAsset:asset
                                     targetSize:_assetThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      // Set the cell's thumbnail image if it's still showing the same asset.
                                      photoLibraryCellImageView.image = result;
                                  }];
        

        return photoLibraryCell;

        } else {
            
        return nil;
    }
    
}

#pragma mark IBActions

//This creates the spot by calling the createSpotWithUsername func.
- (IBAction)createSpotButtonPressed:(id)sender {
    
    NSString *latAsString = [NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.latitude];
    NSString *longAsString = [NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.longitude];
    
    [self createSpotWithMessage:_messageTF.text latitude: latAsString longitude:longAsString];
    
}

- (IBAction)cameraButtonPressed:(id)sender {
    
}

@end
