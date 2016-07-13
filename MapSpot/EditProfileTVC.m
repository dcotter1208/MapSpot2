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
#import "AlertView.h"
@import FirebaseAuth;

@interface EditProfileTVC ()

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

@end

@implementation EditProfileTVC

#pragma mark Lifecycle Methods
- (void)viewDidLoad {
    _currentUser = [CurrentUser sharedInstance];
    [self setUserProfileFields:_currentUser];
    _firebaseOperation = [[FirebaseOperation alloc]init];
    [self listenForChangesToUserProfileOnFirebase:_currentUser];
    _alertView = [[AlertView alloc]init];
    [super viewDidLoad];
    
    //This creates a whie space at the bottom where there are no more cells so there are no ghost cells present.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Helper Methods

//Configure the profile photos.
-(void)viewWillLayoutSubviews {
    _profilePhotoImageView.layer.borderWidth = 4.0;
    _profilePhotoImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
    _profilePhotoImageView.layer.cornerRadius = _profilePhotoImageView.frame.size.height/2;
    _profilePhotoImageView.layer.masksToBounds = TRUE;
    _backgroundProfilePhotoImageView.layer.masksToBounds = TRUE;
}

//Updates the user profile on Firebase,
-(void)listenForChangesToUserProfileOnFirebase:(CurrentUser *)user {
    
    [_firebaseOperation listenForChildNodeChanges:@"users" completion:^(CurrentUser *updatedCurrentUser) {
            [self setUserProfileFields:updatedCurrentUser];
    }];
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

/*
 -Validates if the username exists
 */
-(void)validateUsernameUniqueness:(NSString *)username completion:(void(^)(FIRDataSnapshot *snapshot))completion {
    
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    
    [firebaseOperation queryFirebaseWithConstraintsForChild:@"users" queryOrderedByChild:@"username" queryEqualToValue:username andFIRDataEventType:FIRDataEventTypeValue completion:^(FIRDataSnapshot *snapshot) {
        completion(snapshot);
    }];
    
}

#pragma mark IBActions

- (IBAction)profilePhotoSelected:(id)sender {
    NSLog(@"Profile Photo");
}


- (IBAction)backgroundProfilePhotoSelected:(id)sender {
    NSLog(@"Background Phaoto");
}

- (IBAction)signOutPressed:(id)sender {
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    if (error) {
        NSLog(@"Sign Out Error: %@", error.description);
    }
}

//saves the profile changes.
- (IBAction)savePressed:(id)sender {
    
    [self validateUsernameUniqueness:_usernameTF.text completion:^(FIRDataSnapshot *snapshot) {
        
        NSString *snapshotUserId;
        
        for (FIRDataSnapshot *child in snapshot.children) {
            snapshotUserId = child.value[@"userId"];
        }
        
        if ([snapshot exists] && (![snapshotUserId isEqualToString:_currentUser.userId])) {
            [_alertView genericAlert:@"Whoops!" message:[NSString stringWithFormat:@"The username '%@' is taken.", _usernameTF.text] presentingViewController:self];
        } else if (_usernameTF.text.length < 5 || [_usernameTF.text containsString:@" "]) {
            [_alertView genericAlert:@"Whoops!" message:@"Username must be at least 5 characters (no white space.)" presentingViewController:self];
        } else {
            NSDictionary *userProfileToUpdate = @{@"username": _usernameTF.text,
                                                  @"email": _currentUser.email,
                                                  @"userId": _currentUser.userId,
                                                  @"fullName": _nameTF.text,
                                                  @"bio": _bioTextView.text,
                                                  @"location": _locationTF.text,
                                                  @"DOB": _DOBTF.text};
            
            [_firebaseOperation updateChildNode:@"users" nodeToUpdate:userProfileToUpdate];
        }
    }];
    
}





@end
