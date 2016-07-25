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
#import "ImageProcessor.h"
#import "Photo.h"
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
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonnull, strong) ImageProcessor *imageProcessor;

@end

@implementation UserSpotCreationVC

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
    [self.navigationController setNavigationBarHidden:FALSE];
    _manager = [[PHImageManager alloc] init];
    _spotMediaItems = [[NSMutableArray alloc]init];
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [self checkForPhotoLibraryPermission];
    [self collectionViewSetUp];
    
    _imageProcessor = [[ImageProcessor alloc]init];
    
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

//Creates a dictionary from an array of imageURLs.
-(NSDictionary *)createPhotoRefDict:(NSMutableArray *)photoArray {
    NSMutableDictionary *photoRefDict = [[NSMutableDictionary alloc]init];
    
    for (Photo *photo in photoArray) {
        NSString *key = [[NSNumber numberWithUnsignedInteger:[photoArray indexOfObject:photo]]stringValue];
        
        [photoRefDict setValue:photo.photoReference forKey:key];
    }
    return photoRefDict;
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


//Sets up Photo Library's Collection View
-(void)collectionViewSetUp {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setSectionInset: UIEdgeInsetsMake(20, 0, 10, 0)];
    [_photoLibraryCollectionView setCollectionViewLayout:flowLayout];
    _photoLibraryCollectionView.allowsMultipleSelection = TRUE;
}

//Sets up imageView for the UICollectionViewCell
-(UIImageView *)setUpImageViewForCell:(UICollectionViewCell *)cell withTag:(NSInteger)tag {
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:tag];
    cellImageView.layer.masksToBounds = TRUE;
    return cellImageView;
}

//Checks the capacity of my spot media's array.
-(BOOL)checkMediaArrayCapacity {
    if ([_spotMediaItems count] == 10) {
        return TRUE;
    } else {
        return FALSE;
    }
}

/*
 this is used to check if the imageURLArray is at its capacity.
 This is necessary to make sure we have all of our downloadImageURLs back
 from Firebase before creating a spot.
 */
-(BOOL)arrayIsAtCapacity:(NSMutableArray *)array {
    if (array.count == _spotMediaItems.count) {
        return TRUE;
    } else {
        return FALSE;
    }
}


#pragma mark Image Processing Methods

//Determine if the image to upload is was a screenshot from the phone or not.
-(BOOL)imageIsiPhoneScreenShot:(UIImage *)image {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    if (image.size.width <= (screenSize.size.width * 2) && image.size.height <= (screenSize.size.height * 2)) {
        return TRUE;
    } else {
        return FALSE;
    }
}

//Establish PHImageRequestOptions
-(PHImageRequestOptions *)setPHImageRequestOptions {
    PHImageRequestOptions *fetchOptions = [[PHImageRequestOptions alloc]init];
    fetchOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    fetchOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    return fetchOptions;
}

//Checks if the user has given permission to access the device's photo library.
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

/*
 Fetchs the photos from the device's library and sorts them by most recent creationDate.
 Called in 'checkForPhotoLibraryPermission'.
 */
-(void)accessDevicePhotoLibrary:(void(^)(PHFetchResult *cameraRollAssets))completion {
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:FALSE]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:fetchOptions];
    
    completion(allPhotos);
    
}

#pragma mark Camera Methods

//Sets up the image picker to present the camera. Called in the IBAction for the camera button.
-(void)presentCamera {
    _imagePicker = [[UIImagePickerController alloc] init];
    [_imagePicker setDelegate:self];
    [_imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:_imagePicker animated:TRUE completion:nil];
}

/*
 Once the camera finishes taking the photo then the photo's NSData is turned into a UIImage.
 This image is then added to the _spotMediaItems array. This array is used to populate the UICollectionView
 that contains the media the user will post to their spot.
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
    
    NSData *imageData = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 1);
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    [_spotMediaItems addObject:image];
    [_mediaCollectionView reloadData];
    
}

#pragma mark Networking Methods

/*Takes an image and uploads it to Firebase storage with the correct size.
 if we have all of our imageDownloadURLs back from Firebase then we
 create the spot using the 'createSpotWithMessage' function and perform the unwindSegue back to the MapSpotMapVC.
 */
-(void)uploadImageToFirebase:(UIImage *)image withIndex:(int)index withSize:(CGSize)size withFirebaseOperation:(FirebaseOperation *)firebaseOperation {

    NSData *imageData = [_imageProcessor convertImageToNSData:[_imageProcessor scaleImage:image ToSize:size]];
    [firebaseOperation uploadToFirebase:imageData completion:^(NSString *imageDownloadURL) {

        Photo *photo = [[Photo alloc]initWithDownloadURL:imageDownloadURL andIndex:index];
        [_photoArray addObject:photo];
        
        if ([self arrayIsAtCapacity:_photoArray]) {
            
            [self createSpotWithMessage:_messageTF.text photoArray:_photoArray latitude:[NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.latitude] longitude:[NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.longitude]completion:^(NSString *spotReference) {
                
                for (Photo *photo in _photoArray) {
                    photo.spotReference = spotReference;
                    [self savePhotoToFirebaseDatabase:photo];
                }
            }];
        }
    }];
}

-(void)savePhotoToFirebaseDatabase:(Photo *)photo {
    
    NSNumber *photoIndex = [NSNumber numberWithUnsignedInteger:photo.index];
    
    NSDictionary *photoToSave = @{@"downloadURL": photo.downloadURL,
                            @"index":photoIndex,
                            @"spot": photo.spotReference};
    
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    [firebaseOperation setValueForFirebaseChild:@"photos" value:photoToSave];
}

/*
 Used to create a spot when the createSpotButton is pressed.
 It then saves the spot to Firebase.
*/
-(void)createSpotWithMessage:(NSString *)message photoArray:(NSMutableArray *)photoArray latitude:(NSString *)latitude longitude:(NSString *)longitude completion:(void(^)(NSString *spotReference))completion {
    NSDate *now = [NSDate date];

    FIRUser *currentUserAuth = [[FIRAuth auth]currentUser];
    CurrentUser *currentUser = [CurrentUser sharedInstance];

    NSString *spotReference = [[NSUUID UUID]UUIDString];
    
    NSDictionary *spot = @{@"userId": currentUserAuth.uid,
                           @"username": currentUser.username,
                           @"email": currentUserAuth.email,
                           @"latitude":latitude,
                           @"longitude": longitude,
                           @"message": message,
                           @"spotReference": spotReference,
                           @"createdAt": [self dateToStringFormatter:now],
                           @"images": [self createPhotoRefDict:photoArray]};

    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    [firebaseOperation setValueForFirebaseChild:@"spots" value:spot];
    
    completion(spotReference);
    
}

#pragma mark UICollectionView DataSource

//sets the size of the cells in both collection views.
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (collectionView.tag == 1) {
        return CGSizeMake(_photoLibraryCollectionView.frame.size.width/3, _photoLibraryCollectionView.frame.size.width/3);
    } else {
        return CGSizeMake(_mediaCollectionView.frame.size.width/3.5, _mediaCollectionView.frame.size.width/3.5);
    }

}

//numberOfItemsInSection
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView.tag == 1) {
        return [_imageAssests count];
    } else {
        return [_spotMediaItems count];
    }
    
}

/*
 didSelectRow - Takes the selected PHAsset from the device's photo library,
 checks if it is already in the array for the Spot's Media Items and if it isn't then
 it adds it to the array.
 */
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView.tag == 1) {
        PHAsset *selectedImage = [_imageAssests objectAtIndex:indexPath.item];
        
        if (![self checkMediaArrayCapacity]) {
            if (![_spotMediaItems containsObject:selectedImage]) {
                [_spotMediaItems addObject:selectedImage];
                [_mediaCollectionView reloadData];
            }
        }
        
    } else { //Will use this else statement to see the photo in full view.
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
        
        UIImageView *photoLibraryCellImageView = [self setUpImageViewForCell:photoLibraryCell withTag:200];
        
        [_imageProcessor getImageFromPHAsset:asset withPHImageManager:_manager andTargetSize:_assetThumbnailSize andContentMode:PHImageContentModeAspectFill andRequestOptions:nil completion:^(UIImage *image) {
            photoLibraryCellImageView.image = image;
        }];
        

    return photoLibraryCell;

    } else { //do the _mediaCollectionView

        UICollectionViewCell *spotMediaCell = [_mediaCollectionView dequeueReusableCellWithReuseIdentifier:@"spotMediaCell" forIndexPath:indexPath];
        
        UIImageView *spotMediaCellImageView = [self setUpImageViewForCell:spotMediaCell withTag:100];
        spotMediaCellImageView.layer.cornerRadius = spotMediaCellImageView.frame.size.height/2;
        
        UIButton *mediaCellButton = (UIButton *)[spotMediaCell viewWithTag:201];
        [mediaCellButton addTarget:self action:@selector(deleteSelectedSpotMedia:event:) forControlEvents:UIControlEventTouchUpInside];

        id image = _spotMediaItems[indexPath.item];
        
            if ([image isMemberOfClass:[UIImage class]]) {
                UIImage *image = _spotMediaItems[indexPath.item];
                spotMediaCellImageView.image = image;
            } else {
                PHAsset *asset = _spotMediaItems[indexPath.item];
                
                [_imageProcessor getImageFromPHAsset:asset withPHImageManager:_manager andTargetSize:_assetThumbnailSize andContentMode:PHImageContentModeAspectFill andRequestOptions:nil completion:^(UIImage *image) {
                    spotMediaCellImageView.image = image;
                }];
        }
    return spotMediaCell;
    }
    
}

#pragma mark IBActions

//Called when the spotMediaCell's delete button is pressed. This removes that selected cell from the array.
-(IBAction)deleteSelectedSpotMedia:(id)sender event:(id)event {
    
    //Gets position of touch in the collectionView. This is used to grab the indexPath
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_mediaCollectionView];
    
    NSIndexPath *indexPath = [_mediaCollectionView indexPathForItemAtPoint: currentTouchPosition];
    
    [_spotMediaItems removeObjectAtIndex:indexPath.item];
    [_mediaCollectionView reloadData];
}

//This creates the spot by calling the createSpotWithUsername func.
- (IBAction)createSpotButtonPressed:(id)sender {

    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    _photoArray = [NSMutableArray arrayWithCapacity:[_spotMediaItems count]];
    
    if (_spotMediaItems.count == 0) {
        [self createSpotWithMessage:_messageTF.text photoArray:nil latitude:[NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.latitude] longitude:[NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.longitude] completion:^(NSString *spotReference) {

        }];
    }
    
    PHImageRequestOptions *fetchOptions = [self setPHImageRequestOptions];

    for (id photo in _spotMediaItems) {
        
        int index = (int)[_spotMediaItems indexOfObject:photo];
        
        if ([photo isMemberOfClass:[PHAsset class]]) {
            
            [_manager requestImageForAsset:photo
                    targetSize:PHImageManagerMaximumSize
                   contentMode:PHImageContentModeAspectFill
                       options:fetchOptions
                 resultHandler:^(UIImage *result, NSDictionary *info) {
                     
                     if ([self imageIsiPhoneScreenShot:result]) {

                         [self uploadImageToFirebase:result withIndex:index withSize:CGSizeMake(result.size.width/4, result.size.height/4) withFirebaseOperation:firebaseOperation];
                     } else {

                         [self uploadImageToFirebase:result withIndex:index withSize:CGSizeMake(result.size.width/10, result.size.height/10) withFirebaseOperation:firebaseOperation];
                     }
                 }];
            
        } else {
            UIImage *image = photo;

            [self uploadImageToFirebase:image withIndex:index withSize:CGSizeMake(image.size.width/10, image.size.height/10) withFirebaseOperation:firebaseOperation];
        }
    }
    [self performSegueWithIdentifier:@"unwindToMapSpotMapVCSegue" sender:self];
}

- (IBAction)cameraButtonPressed:(id)sender {
    
    [self presentCamera];
}


@end
