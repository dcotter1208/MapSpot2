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

@interface UserSpotCreationVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

#pragma mark IBOutlets
@property (weak, nonatomic) IBOutlet UITextView *messageTF;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *photoLibraryCollectionView;

#pragma mark Properties
@property (nonatomic, strong) UIImagePickerController *imagePicker;
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
    
    self.automaticallyAdjustsScrollViewInsets = NO;

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

#pragma mark Camera Methods

-(void)presentCamera {
    _imagePicker = [[UIImagePickerController alloc] init];
    [_imagePicker setDelegate:self];
    [_imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:_imagePicker animated:TRUE completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
    
    NSData *imageData = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 1);
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    [_spotMediaItems addObject:image];
    NSLog(@"Spot Media Items Array Count: %lu", _spotMediaItems.count);
    [_mediaCollectionView reloadData];
    
}

#pragma mark Firebase Helper Methods

/*
 Used to create a spot when the createSpotButton is pressed.
 It then saves the spot to Firebase.
*/
-(void)createSpotWithMessage:(NSString *)message imageURLArray:(NSMutableArray *)imageURLArray latitude:(NSString *)latitude longitude:(NSString *)longitude {
    NSDate *now = [NSDate date];

    FIRUser *currentUserAuth = [[FIRAuth auth]currentUser];
    CurrentUser *currentUser = [CurrentUser sharedInstance];
    NSMutableDictionary *imageURLDict = [[NSMutableDictionary alloc]init];
    
    for (NSString *imageURLString in imageURLArray) {
        NSString *key = [[NSNumber numberWithUnsignedInteger:[imageURLArray indexOfObject:imageURLString]]stringValue];
        [imageURLDict setValue:imageURLString forKey:key];
    }

    NSDictionary *spot = @{@"userId": currentUserAuth.uid,
                           @"username": currentUser.username,
                           @"email": currentUserAuth.email,
                           @"latitude":latitude,
                           @"longitude": longitude,
                           @"message": message,
                           @"createdAt": [self dateToStringFormatter:now],
                           @"images": imageURLDict};
    
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

-(void)setImageForCellImageViewWithAsset:(PHAsset *)asset imageView:(UIImageView *)imageView {

    [_manager requestImageForAsset:asset
                    targetSize:_assetThumbnailSize
                   contentMode:PHImageContentModeAspectFill
                       options:nil
                 resultHandler:^(UIImage *result, NSDictionary *info) {
                     imageView.image = result;
            }];
}

-(BOOL)checkMediaArrayCapacity {
    if ([_spotMediaItems count] == 10) {
        return TRUE;
    } else {
        return FALSE;
    }
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
    
    if (collectionView.tag == 1) {
        PHAsset *selectedImage = [_imageAssests objectAtIndex:indexPath.item];
        
        if (![self checkMediaArrayCapacity]) {
            if (![_spotMediaItems containsObject:selectedImage]) {
                [_spotMediaItems addObject:selectedImage];
                [_mediaCollectionView reloadData];
            }
        }
        
    } else {
        PHAsset *selectedImage = [_spotMediaItems objectAtIndex:indexPath.item];

    }

}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGRect screenSize = [[UIScreen mainScreen] bounds];
    _assetThumbnailSize = CGSizeMake(screenSize.size.width / 3, screenSize.size.height / 3);
    
    //If the collectionView is the _photoLibraryCollectionView (which has a tag of 1)
    if (collectionView.tag == 1) {

        PHAsset *asset = _imageAssests[indexPath.item];
        
        UICollectionViewCell *photoLibraryCell = [_photoLibraryCollectionView dequeueReusableCellWithReuseIdentifier:@"photoLibraryCell" forIndexPath:indexPath];
        UIImageView *photoLibraryCellImageView = (UIImageView *)[photoLibraryCell viewWithTag:200];
        photoLibraryCellImageView.layer.masksToBounds = TRUE;
        
        [self setImageForCellImageViewWithAsset:asset imageView:photoLibraryCellImageView];

    return photoLibraryCell;

    } else {

        UICollectionViewCell *spotMediaCell = [_mediaCollectionView dequeueReusableCellWithReuseIdentifier:@"spotMediaCell" forIndexPath:indexPath];
        UIImageView *spotMediaCellImageView = (UIImageView *)[spotMediaCell viewWithTag:100];
        spotMediaCellImageView.layer.masksToBounds = TRUE;
        spotMediaCellImageView.layer.cornerRadius = spotMediaCellImageView.frame.size.height/2;
        
        UIButton *mediaCellButton = (UIButton *)[spotMediaCell viewWithTag:201];
        
        [mediaCellButton addTarget:self action:@selector(deleteSelectedSpotMedia:event:) forControlEvents:UIControlEventTouchUpInside];
        
        //***********************************************************************************************
        
        id image = _spotMediaItems[indexPath.item];
        
            if ([image isMemberOfClass:[UIImage class]]) {
                UIImage *image = _spotMediaItems[indexPath.item];
                NSLog(@"IMAGE: %@", image.description);
                spotMediaCellImageView.image = image;
            } else {
                PHAsset *asset = _spotMediaItems[indexPath.item];
                NSLog(@"Asset: %@", asset.description);
                [self setImageForCellImageViewWithAsset:asset imageView:spotMediaCellImageView];
        }
        
        //***********************************************************************************************

        
    return spotMediaCell;
    }
    
}

-(IBAction)deleteSelectedSpotMedia:(id)sender event:(id)event {
    
    //Gets position of touch in the collectionView. This is used to grab the indexPath
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_mediaCollectionView];
    
    NSIndexPath *indexPath = [_mediaCollectionView indexPathForItemAtPoint: currentTouchPosition];
    
    [_spotMediaItems removeObjectAtIndex:indexPath.item];
    [_mediaCollectionView reloadData];
}

#pragma mark IBActions

//This creates the spot by calling the createSpotWithUsername func.
- (IBAction)createSpotButtonPressed:(id)sender {
    
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    NSMutableArray *imageURLArray = [NSMutableArray arrayWithCapacity:[_spotMediaItems count]];
    NSString *latAsString = [NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.latitude];
    NSString *longAsString = [NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.longitude];
    
    PHImageRequestOptions *fetchOptions = [PHImageRequestOptions new];
    fetchOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    fetchOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    for (PHAsset *asset in _spotMediaItems) {
        
        [_manager requestImageForAsset:asset
            targetSize:PHImageManagerMaximumSize
           contentMode:PHImageContentModeAspectFill
               options:fetchOptions
         resultHandler:^(UIImage *result, NSDictionary *info) {
             
             if (result.size.width > 750 && result.size.height > 1334) {
                 UIImage *resizedImage = [self image:result scaledToSize:CGSizeMake(result.size.width/10, result.size.height/10)];
                 NSData *imageData = UIImagePNGRepresentation(resizedImage);
                 [firebaseOperation uploadToFirebase:imageData completion:^(NSString *imageDownloadURL) {
                     [imageURLArray addObject:imageDownloadURL];
                     
                     if (imageURLArray.count == _spotMediaItems.count) {
                         NSLog(@"Image Array Count - 1: %lu", imageURLArray.count);
                         [self createSpotWithMessage:_messageTF.text imageURLArray: imageURLArray latitude: latAsString longitude:longAsString];
                     }
                     
                 }];
             } else {
                 UIImage *resizedImage = [self image:result scaledToSize:CGSizeMake(result.size.width/4, result.size.height/4)];
                 NSData *imageData = UIImagePNGRepresentation(resizedImage);
                 [firebaseOperation uploadToFirebase:imageData completion:^(NSString *imageDownloadURL) {
                     [imageURLArray addObject:imageDownloadURL];
                     
                     if (imageURLArray.count == _spotMediaItems.count) {
                         NSLog(@"Image Array Count - 2: %lu", imageURLArray.count);
                         [self createSpotWithMessage:_messageTF.text imageURLArray: imageURLArray latitude: latAsString longitude:longAsString];
                     }
                 }];
             }
         }];
    }
}

- (IBAction)cameraButtonPressed:(id)sender {
    
    [self presentCamera];
}


@end
