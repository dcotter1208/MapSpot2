//
//  EditProfileTVC.m
//  MapSpot
//
//  Created by DetroitLabs on 7/6/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "EditProfileTVC.h"
#import "FirebaseOperation.h"
#import "CurrentUser.h"
#import "ImageProcessor.h"
#import "AlertView.h"
#import "UIImageView+AFNetworking.h"

@import FirebaseAuth;

@interface EditProfileTVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

#pragma mark IBOutlets
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundProfilePhotoImageView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *locationTF;
@property (weak, nonatomic) IBOutlet UITextField *DOBTF;

#pragma mark Properties
@property (nonatomic, strong) CurrentUser *currentUser;
@property (nonatomic, strong) FirebaseOperation *firebaseOperation;
@property (nonatomic, strong) AlertView *alertView;
@property (nonatomic, strong) NSData *profilePhotoData;
@property (nonatomic, strong) NSData *backgroundPhotoData;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) ImageProcessor *imageProcessor;
@property (nonatomic) BOOL profilePhotoSelected;
@property (nonatomic) BOOL profilePhotoChanged;
@property (nonatomic) BOOL backgroundProfilePhotoChanged;

@end

@implementation EditProfileTVC

#pragma mark Lifecycle Methods
- (void)viewDidLoad {
    _currentUser = [CurrentUser sharedInstance];
    [self setUserProfileFields:_currentUser];
    _firebaseOperation = [[FirebaseOperation alloc]init];
    [self listenForChangesToUserProfileOnFirebase:_currentUser];
    _alertView = [[AlertView alloc]init];
    _imageProcessor = [[ImageProcessor alloc]init];
    [super viewDidLoad];
    
    //This creates a whie space at the bottom where there are no more cells so there are no ghost cells present.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark View Helper Methods
//Configure the profile photos.
-(void)viewWillLayoutSubviews {
    _profilePhotoImageView.layer.borderWidth = 4.0;
    _profilePhotoImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
    _profilePhotoImageView.layer.cornerRadius = _profilePhotoImageView.frame.size.height/2;
    _profilePhotoImageView.layer.masksToBounds = TRUE;
    _backgroundProfilePhotoImageView.layer.masksToBounds = TRUE;
}

//Sets textfields, textview and UIImageViews with the user's profile info.
-(void)setUserProfileFields:(CurrentUser *)currentUser {
    _usernameTF.text = currentUser.username;
    _nameTF.text = currentUser.fullName;
    _locationTF.text = currentUser.location;
    _bioTextView.text = currentUser.bio;
    _DOBTF.text = currentUser.DOB;
    
    if (currentUser.profilePhoto != nil) {
        _profilePhotoImageView.image = currentUser.profilePhoto;
        _backgroundProfilePhotoImageView.image = currentUser.backgroundProfilePhoto;
    }
}

//Removes all whitespace or only leading and trailing of a given string.
-(NSString *)removeLeadingAndTrailingWhitespace:(NSString *)string removeAllWhiteSpace:(BOOL)removeAllWhiteSpace {
    
    if (removeAllWhiteSpace) {
        NSString *newString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *noWhiteSpaceString = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
        return noWhiteSpaceString;
    } else {
        NSString *newString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return newString;
    }
    
}


//Displays the action sheet to choose between taking a photo or selecting one from the photo library.
-(void)displayChangePhotoActionSheetWithTitle:(NSString *)title {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [self presentViewController:actionSheet animated:TRUE completion:nil];
    
    UIAlertAction *presentCamera = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self presentCamera];
    }];
    
    UIAlertAction *presentPhotoLibrary = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self presentPhotoLibrary];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [actionSheet addAction:presentCamera];
    [actionSheet addAction:presentPhotoLibrary];
    [actionSheet addAction:cancel];
    
}

#pragma mark Networking Methods
//Updates the user profile on Firebase,
-(void)listenForChangesToUserProfileOnFirebase:(CurrentUser *)user {
    
    [_firebaseOperation listenForChildNodeChanges:@"users" completion:^(CurrentUser *updatedCurrentUser) {
        [self setUserProfileFields:updatedCurrentUser];
    }];
}

//Updates if both user profile photo and background profile changed.
-(void)updateUserProfileWithChangedProfileAndBackgroundProfilePhotos {
    [_firebaseOperation uploadToFirebase:_profilePhotoData completion:^(NSString *imageDownloadURL) {
        
        NSString *profilePhotoDownloadURL = imageDownloadURL;
        
        [_firebaseOperation uploadToFirebase:_backgroundPhotoData completion:^(NSString *imageDownloadURL) {
            
            NSString *backgroundProfilePhotoDownloadURL = imageDownloadURL;
            
            NSDictionary *userProfile = [self createUserProfileToUpdate:profilePhotoDownloadURL backgroundProfilePhotoDownloadURL:backgroundProfilePhotoDownloadURL];
            
            [_firebaseOperation updateChildNode:@"users" nodeToUpdate:userProfile];
        }];
    }];
}


//Updates only if user profile photo changed.
-(void)updateUserProfileIfOnlyProfilePhotoChanged {
    [_firebaseOperation uploadToFirebase:_profilePhotoData completion:^(NSString *imageDownloadURL) {
        
        NSDictionary *userProfile = [self createUserProfileToUpdate:imageDownloadURL backgroundProfilePhotoDownloadURL:_currentUser.backgroundProfilePhotoDownloadURL];
        
        [_firebaseOperation updateChildNode:@"users" nodeToUpdate:userProfile];
    }];
}

//updates only if background profile photo changed.
-(void)updateUserProfileIfOnlyBackgroundProfilePhotoChanged {
    [_firebaseOperation uploadToFirebase:_backgroundPhotoData completion:^(NSString *imageDownloadURL) {
        
        NSDictionary *userProfile = [self createUserProfileToUpdate:_currentUser.profilePhotoDownloadURL backgroundProfilePhotoDownloadURL:imageDownloadURL];
        
        [_firebaseOperation updateChildNode:@"users" nodeToUpdate:userProfile];
    }];
}

//Updates if no profile photos were changed.
-(void)updateIfNoProfilePhotosChanged {
    NSDictionary *userProfile = [self createUserProfileToUpdate:_currentUser.profilePhotoDownloadURL backgroundProfilePhotoDownloadURL:_currentUser.backgroundProfilePhotoDownloadURL];
    [_firebaseOperation updateChildNode:@"users" nodeToUpdate:userProfile];
}

/*
 -Validates if the username exists
 */
-(void)validateUsernameUniqueness:(NSString *)username completion:(void(^)(FIRDataSnapshot *snapshot))completion {
    
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    
    [firebaseOperation queryFirebaseWithConstraintsForChild:@"users" queryOrderedByChild:@"userId" queryEqualToValue:[FIRAuth auth].currentUser.uid andFIRDataEventType:FIRDataEventTypeValue observeSingleEventType:TRUE completion:^(FIRDataSnapshot *snapshot) {
        completion(snapshot);
    }];
    
}

#pragma mark Helper Methods

//Creates a dictionary for the user profile that we will update on Firebase.
-(NSDictionary *)createUserProfileToUpdate:(NSString *)profilePhotoDownloadURL backgroundProfilePhotoDownloadURL:(NSString *)backgroundProfilePhotoDownloadURL {
    NSString *username = [self removeLeadingAndTrailingWhitespace:_usernameTF.text removeAllWhiteSpace:false];
    NSString *fullName = [self removeLeadingAndTrailingWhitespace:_nameTF.text removeAllWhiteSpace:false];
    NSString *location = [self removeLeadingAndTrailingWhitespace:_locationTF.text removeAllWhiteSpace:false];
    NSString *DOB = [self removeLeadingAndTrailingWhitespace:_DOBTF.text removeAllWhiteSpace:true];
    NSString *bio = [self removeLeadingAndTrailingWhitespace:_bioTextView.text removeAllWhiteSpace:false];
    
    NSDictionary *userProfileToUpdate = @{@"username": username,
                                          @"email": _currentUser.email,
                                          @"userId": _currentUser.userId,
                                          @"fullName": fullName,
                                          @"bio": bio,
                                          @"location": location,
                                          @"DOB": DOB,
                                          @"profilePhotoDownloadURL": profilePhotoDownloadURL,
                                          @"backgroundProfilePhotoDownloadURL": backgroundProfilePhotoDownloadURL};
    
    return userProfileToUpdate;
}

#pragma mark Camera Methods
//Presents the camera
-(void)presentCamera {
    _imagePicker = [[UIImagePickerController alloc] init];
    [_imagePicker setDelegate:self];
    [_imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:_imagePicker animated:TRUE completion:nil];
}

//Presents the photo library
-(void)presentPhotoLibrary {
    _imagePicker = [[UIImagePickerController alloc] init];
    [_imagePicker setDelegate:self];
    [_imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:_imagePicker animated:TRUE completion:nil];
}

/*
 Once the user is finished picking an image then it
 determines if that image was for the profile photo or background profile photo
 and sets the imageView along with the imageData appropriately. That imageData is then used to
 save the image on Firebase.
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:TRUE completion:nil];

    NSData *imageData = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 1);
    UIImage *image = [UIImage imageWithData:imageData];
    UIImage *resizedImage = [_imageProcessor scaleImage:image ToSize:CGSizeMake(image.size.width / 5, image.size.height/5)];
    NSData *resizedImageData = [_imageProcessor convertImageToNSData:resizedImage];
    
    if (_profilePhotoSelected) {
        _profilePhotoChanged = TRUE;
        _profilePhotoData = resizedImageData;
        _profilePhotoImageView.image = resizedImage;
    } else {
        _backgroundProfilePhotoChanged = TRUE;
        _backgroundPhotoData = resizedImageData;
        _backgroundProfilePhotoImageView.image = resizedImage;
    }

}

#pragma mark IBActions

/*
 Displays the action sheet with the appropriate title as well as
 sets the property 'profilePhotoSelected' to TRUE. This BOOL property is used
 in the 'didFinishPickingMediaWithInfo' method to determine which image to set.
 */
- (IBAction)profilePhotoSelected:(id)sender {
    _profilePhotoSelected = TRUE;
    [self displayChangePhotoActionSheetWithTitle:@"Edit Profile Photo"];
}

/*
 Displays the action sheet with the appropriate title as well as
 sets the property 'profilePhotoSelected' to FALSE. This BOOL property is used
 in the 'didFinishPickingMediaWithInfo' method to determine which image to set.
 */
- (IBAction)backgroundProfilePhotoSelected:(id)sender {
    _profilePhotoSelected = FALSE;
    [self displayChangePhotoActionSheetWithTitle:@"Edit Background Profile Photo"];
}

//Signs the user out of the app by logging them out of Firebase.
- (IBAction)signOutPressed:(id)sender {
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    if (error) {
        NSLog(@"Sign Out Error: %@", error.description);
    }
}


//saves the profile changes.
- (IBAction)savePressed:(id)sender {
    NSString *username = [self removeLeadingAndTrailingWhitespace:_usernameTF.text removeAllWhiteSpace:false];

    _currentUser.profilePhoto = _profilePhotoImageView.image;
    _currentUser.backgroundProfilePhoto = _backgroundProfilePhotoImageView.image;

    [self validateUsernameUniqueness:username completion:^(FIRDataSnapshot *snapshot) {
        
        NSString *snapshotUserId;
        
        for (FIRDataSnapshot *child in snapshot.children) {
            snapshotUserId = child.value[@"userId"];
        }
        
        if ([snapshot exists] && (![snapshotUserId isEqualToString:_currentUser.userId])) {
            [_alertView genericAlert:@"Whoops!" message:[NSString stringWithFormat:@"The username '%@' is taken.", username] presentingViewController:self];
        } else if (username.length < 5 || [username containsString:@" "]) {
            [_alertView genericAlert:@"Whoops!" message:@"Username must be at least 5 characters (no white space.)" presentingViewController:self];
        } else {
            if (_profilePhotoChanged && _backgroundProfilePhotoChanged) {
                [self updateUserProfileWithChangedProfileAndBackgroundProfilePhotos];
            } else if (_profilePhotoChanged) {
                [self updateUserProfileIfOnlyProfilePhotoChanged];
            } else if (_backgroundProfilePhotoChanged) {
                [self updateUserProfileIfOnlyBackgroundProfilePhotoChanged];
            } else {
                [self updateIfNoProfilePhotosChanged];
            }
        }
    }];
    
}





@end
