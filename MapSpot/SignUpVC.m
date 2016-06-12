//
//  SignUpVC.m
//  MapSpot
//
//  Created by DetroitLabs on 6/2/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "SignUpVC.h"

@interface SignUpVC ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmationTF;

@end

@implementation SignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)addUserProfileInfo:(NSString *)userID username:(NSString *)username email:(NSString *)email {
    FBDataService *fbDataService = [[FBDataService alloc]init];
    FIRDatabaseReference *userRef = [fbDataService.ref child:@"users"].childByAutoId;
    NSDictionary *userProfile = @{@"userID": userID, @"username": username, @"email": email};
    [userRef setValue:userProfile];

}

- (IBAction)signUpNewUser:(id)sender {
    
    //Use REGEX for user sign up.
    
    NSString *username = _usernameTF.text;
    NSString *email = _emailTF.text;
    
    if ([_passwordTF.text isEqualToString:_passwordConfirmationTF.text]) {
        [[FIRAuth auth]createUserWithEmail:email password:_passwordTF.text completion:^(FIRUser *user, NSError *error) {
            
            if (error) {
                NSLog(@"ERROR: %@", error);
            } else {
                [self addUserProfileInfo:user.uid username:username email:email];
            }
        }];
    }
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];

}

@end
