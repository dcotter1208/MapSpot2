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
@property (nonatomic, strong) NSMutableArray *imageURLArray;

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
-(NSDictionary *)createImageURLDict:(NSMutableArray *)imageURLArray {
    NSMutableDictionary *imageURLDict = [[NSMutableDictionary alloc]init];
    
    for (NSString *imageURLString in imageURLArray) {
        NSString *key = [[NSNumber numberWithUnsignedInteger:[imageURLArray indexOfObject:imageURLString]]stringValue];
        
        [imageURLDict setValue:imageURLString forKey:key];
    }
    return imageURLDict;
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
//converts an image to NSData
-(NSData *)convertImageToNSData:(UIImage *)image {
    NSData *imageData = UIImagePNGRepresentation(image);
    return imageData;
}

//Determine if the image to upload is was a screenshot from the phone or not.
-(BOOL)imageIsiPhoneScreenShot:(UIImage *)image {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    if (image.size.width <= (screenSize.size.width * 2) && image.size.height <= (screenSize.size.height * 2)) {
        return TRUE;
    } else {
        return FALSE;
    }
}

/*
 Sets the image view for the cell by turning a PHAsset
 into a UIImage.
 */
-(void)setImageForCellImageViewWithAsset:(PHAsset *)asset imageView:(UIImageView *)imageView {
    
    [_manager requestImageForAsset:asset
                        targetSize:_assetThumbnailSize
                       contentMode:PHImageContentModeAspectFill
                           options:nil
                     resultHandler:^(UIImage *result, NSDictionary *info) {
                         imageView.image = result;
                     }];
}

//Sets up imageView for the UICollectionViewCell
-(UIImageView *)setUpImageViewForCell:(UICollectionViewCell *)cell withTag:(NSInteger)tag {
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:tag];
    cellImageView.layer.masksToBounds = TRUE;
    return cellImageView;
}

//Establish PHImageRequestOptions
-(PHImageRequestOptions *)setPHImageRequestOptions {
    PHImageRequestOptions *fetchOptions = [[PHImageRequestOptions alloc]init];
    fetchOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    fetchOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    return fetchOptions;
}


-(BOOL)imageIsPortrait:(UIImage *)image {
    if (image.size.height > image.size.width) {
        return TRUE;
    } else {
        return FALSE;
    }
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

/*
 Reduces the image's size. If the size to scale down to is the size of
 the original image then just return the original image.
 */
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

#pragma mark Firebase Helper Methods

/*Takes an image and uploads it to Firebase storage with the correct size.
 if we have all of our imageDownloadURLs back from Firebase then we
 create the spot using the 'createSpotWithMessage' function and perform the unwindSegue back to the MapSpotMapVC.
 */
-(void)uploadImageToFirebase:(UIImage *)image withSize:(CGSize)size withFirebaseOperation:(FirebaseOperation *)firebaseOperation {
    NSData *imageData = [self convertImageToNSData:[self image:image scaledToSize:size]];
    [firebaseOperation uploadToFirebase:imageData completion:^(NSString *imageDownloadURL) {
        [_imageURLArray addObject:imageDownloadURL];
        if ([self arrayIsAtCapacity:_imageURLArray]) {
            [self createSpotWithMessage:_messageTF.text imageURLArray: _imageURLArray latitude:[NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.latitude] longitude:[NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.longitude]];
            [self performSegueWithIdentifier:@"unwindToMapSpotMapVCSegue" sender:self];
        }
    }];
}

/*
 Used to create a spot when the createSpotButton is pressed.
 It then saves the spot to Firebase.
*/
-(void)createSpotWithMessage:(NSString *)message imageURLArray:(NSMutableArray *)imageURLArray latitude:(NSString *)latitude longitude:(NSString *)longitude {
    NSDate *now = [NSDate date];

    FIRUser *currentUserAuth = [[FIRAuth auth]currentUser];
    CurrentUser *currentUser = [CurrentUser sharedInstance];

    NSDictionary *spot = @{@"userId": currentUserAuth.uid,
                           @"username": currentUser.username,
                           @"email": currentUserAuth.email,
                           @"latitude":latitude,
                           @"longitude": longitude,
                           @"message": message,
                           @"createdAt": [self dateToStringFormatter:now],
                           @"images": [self createImageURLDict:imageURLArray]};
    
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    [firebaseOperation setValueForFirebaseChild:@"spots" value:spot];

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
        
        [self setImageForCellImageViewWithAsset:asset imageView:photoLibraryCellImageView];

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
                [self setImageForCellImageViewWithAsset:asset imageView:spotMediaCellImageView];
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
    _imageURLArray = [NSMutableArray arrayWithCapacity:[_spotMediaItems count]];

    for (id photo in _spotMediaItems) {
        
        PHImageRequestOptions *fetchOptions = [self setPHImageRequestOptions];
        
        if ([photo isMemberOfClass:[PHAsset class]]) {
      
            [_manager requestImageForAsset:photo
                    targetSize:PHImageManagerMaximumSize
                   contentMode:PHImageContentModeAspectFill
                       options:fetchOptions
                 resultHandler:^(UIImage *result, NSDictionary *info) {
                     
                     if ([self imageIsiPhoneScreenShot:result]) {
                         [self uploadImageToFirebase:result withSize:CGSizeMake(result.size.width/4, result.size.height/4) withFirebaseOperation:firebaseOperation];
                     } else {
                         [self uploadImageToFirebase:result withSize:CGSizeMake(result.size.width/10, result.size.height/10) withFirebaseOperation:firebaseOperation];
                     }
                 }];
            
        } else {
            UIImage *image = photo;
            [self uploadImageToFirebase:image withSize:CGSizeMake(image.size.width/10, image.size.height/10) withFirebaseOperation:firebaseOperation];
        }
    }
}

- (IBAction)cameraButtonPressed:(id)sender {
    
    [self presentCamera];
}


@end
