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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addUserProfileInfo {
    
    
}

- (IBAction)signUpNewUser:(id)sender {
    
    //Use REGEX for user sign up.
    
    //https://firebase.google.com/docs/auth/ios/manage-users#get_the_currently_signed-in_user
    if ([_passwordTF.text isEqualToString:_passwordConfirmationTF.text]) {
        [[FIRAuth auth]createUserWithEmail:_emailTF.text password:_passwordTF.text completion:^(FIRUser *user, NSError *error) {
            
            if (error) {
                NSLog(@"ERROR: %@", error);
            } else {
                
            }
            
        }];
    }
    

    

}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];

}

@end
