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

#pragma mark IBOutlets
@property (weak, nonatomic) IBOutlet UITextView *messageTF;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *photoLibraryCollectionView;

#pragma mark Properties
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
    _spotMediaItems = [[NSMutableArray alloc]init];
    [super viewDidLoad];
    
    [self checkForPhotoLibraryPermission];

    [self collectionViewSetUp];

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

-(BOOL)imageIsPortrait:(UIImage *)image {
    if (image.size.height > image.size.width) {
        return TRUE;
    } else {
        return FALSE;
    }
}

-(void)checkForPhotoLibraryPermission {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
       
        if (status == PHAuthorizationStatusAuthorized) {
            [self accessDevicePhotoLibrary:^(PHFetchResult *cameraRollAssets) {
                _imageAssests = cameraRollAssets;
                
                [_photoLibraryCollectionView reloadData];
            }];
        } else {
            NSLog(@"Permission Denied.");
        }
        
    }];
}

-(void)accessDevicePhotoLibrary:(void(^)(PHFetchResult *cameraRollAssets))completion {
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:FALSE]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:fetchOptions];

    completion(allPhotos);

}

- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size {
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size)) {
        return originalImage;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
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

-(void)collectionViewSetUp {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setSectionInset: UIEdgeInsetsMake(20, 0, 10, 0)];
    [_photoLibraryCollectionView setCollectionViewLayout:flowLayout];
    _photoLibraryCollectionView.allowsMultipleSelection = TRUE;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (collectionView.tag == 1) {
        return CGSizeMake(_photoLibraryCollectionView.frame.size.width/3, _photoLibraryCollectionView.frame.size.width/3);
    } else {
        return CGSizeMake(_mediaCollectionView.frame.size.width/3.5, _mediaCollectionView.frame.size.width/3.5);
    }

}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView.tag == 1) {
        return [_imageAssests count];
    } else {
        return [_spotMediaItems count];
    }
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *photoLibraryCell = [_photoLibraryCollectionView cellForItemAtIndexPath:indexPath];
    
        photoLibraryCell.layer.borderWidth = 2.0;
        photoLibraryCell.layer.borderColor = [[UIColor greenColor]CGColor];
    
    if (collectionView.tag == 1) {
        
        PHAsset *selectedImage = [_imageAssests objectAtIndex:indexPath.item];

        if (![_spotMediaItems containsObject:selectedImage]) {
            [_spotMediaItems addObject:selectedImage];
            [_mediaCollectionView reloadData];
        } else {

        }

    }

}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *photoLibraryCell = [_photoLibraryCollectionView cellForItemAtIndexPath:indexPath];
    
    PHAsset *deSelectedImage = [_imageAssests objectAtIndex:indexPath.item];
    if ([_spotMediaItems containsObject:deSelectedImage]) {
        [_spotMediaItems removeObject:deSelectedImage];
        [_mediaCollectionView reloadData];
        photoLibraryCell.layer.borderWidth = 0.0;
        photoLibraryCell.layer.borderColor = [[UIColor clearColor]CGColor];
    }
    


}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView.tag == 1) {

        PHAsset *asset = _imageAssests[indexPath.item];
        
        UICollectionViewCell *photoLibraryCell = [_photoLibraryCollectionView dequeueReusableCellWithReuseIdentifier:@"photoLibraryCell" forIndexPath:indexPath];
        
        UIImageView *photoLibraryCellImageView = (UIImageView *)[photoLibraryCell viewWithTag:200];
        photoLibraryCellImageView.layer.masksToBounds = TRUE;
        
        if (photoLibraryCell.selected) {
            photoLibraryCell.layer.borderWidth = 2.0;
            photoLibraryCell.layer.borderColor = [[UIColor greenColor]CGColor];
        } else {
            photoLibraryCell.layer.borderWidth = 0.0;
            photoLibraryCell.layer.borderColor = [[UIColor clearColor]CGColor];
        }

        
        if (indexPath.item == 0) {
            photoLibraryCellImageView.image = [UIImage imageNamed:@"old_english_D"];
        } else if (indexPath.item == 1) {
        
        } else if (indexPath.item == 2) {
        
        }
        
        
        CGRect screenSize = [[UIScreen mainScreen] bounds];

        _assetThumbnailSize = CGSizeMake(screenSize.size.width / 3, screenSize.size.height / 3);

        
//        This may be helpful for retrieving video assets...
//        
//        if (asset.mediaType == PHAssetMediaTypeImage) {
//            
//        } else if (asset.mediaType == PHAssetMediaTypeVideo) {
//        
//        }
//       
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
           
            PHAsset *asset = _spotMediaItems[indexPath.item];
            
            UICollectionViewCell *spotMediaCell = [_mediaCollectionView dequeueReusableCellWithReuseIdentifier:@"spotMediaCell" forIndexPath:indexPath];
            UIImageView *spotMediaCellImageView = (UIImageView *)[spotMediaCell viewWithTag:100];
            spotMediaCellImageView.layer.masksToBounds = TRUE;
            spotMediaCellImageView.layer.cornerRadius = spotMediaCellImageView.frame.size.height/2;
 
            [_manager requestImageForAsset:asset
                                targetSize:_assetThumbnailSize
                               contentMode:PHImageContentModeAspectFill
                                   options:nil
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 // Set the cell's thumbnail image if it's still showing the same asset.
                                 spotMediaCellImageView.image = result;
                             }];
            
            
//            spotMediaCellImageView.image = _spotMediaItems[indexPath.row];
            
        return spotMediaCell;
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
