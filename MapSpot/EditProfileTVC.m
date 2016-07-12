//
//  EditProfileTVC.m
//  MapSpot
//
//  Created by DetroitLabs on 7/6/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "EditProfileTVC.h"
#import "FirebaseDatabaseService.h"
#import "CurrentUser.h"
@import FirebaseAuth;

@interface EditProfileTVC ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundProfilePhotoImageView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *locationTF;
@property (weak, nonatomic) IBOutlet UITextField *DOBTF;

@end

@implementation EditProfileTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Configre the profile photos.
-(void)viewWillLayoutSubviews {
    _profilePhotoImageView.layer.borderWidth = 4.0;
    _profilePhotoImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
    _profilePhotoImageView.layer.cornerRadius = _profilePhotoImageView.frame.size.height/2;
    _profilePhotoImageView.layer.masksToBounds = TRUE;
    _backgroundProfilePhotoImageView.layer.masksToBounds = TRUE;
}

-(void)updateCurrentUserProfileOnFirebase:(CurrentUser *)user {
    
    FirebaseDatabaseService *firebaseDatabaseService = [FirebaseDatabaseService sharedInstance];
    [firebaseDatabaseService initWithReference];
    
}

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

- (IBAction)savePressed:(id)sender {
    
    
    
}





@end
