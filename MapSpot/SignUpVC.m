//
//  SignUpVC.m
//  MapSpot
//
//  Created by DetroitLabs on 6/2/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "SignUpVC.h"
#import "FirebaseDatabaseService.h"

@interface SignUpVC ()

#pragma mark Properties

@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTF;

@end

@implementation SignUpVC

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Firebase Helper Methods

//Creates a user profile on Firebase Database.
-(void)addUserProfileInfo:(NSString *)userID username:(NSString *)username email:(NSString *)email {
    
    FirebaseDatabaseService *firebaseDatabaseService = [FirebaseDatabaseService sharedInstance];
    [firebaseDatabaseService initWithReference];
    FIRDatabaseReference *userRef = [firebaseDatabaseService.ref child:@"users"].childByAutoId;
    NSDictionary *userProfile = @{@"userID": userID,
                                  @"username": username,
                                  @"email": email};
    [userRef setValue:userProfile];

}

//Signs up the user for Firebase email/password auth.
-(void)signUpUserWithFirebase {
    NSString *username = _usernameTF.text;
    NSString *email = _emailTF.text;
    
    if ([_passwordTF.text isEqualToString:_repeatPasswordTF.text]) {
        [[FIRAuth auth]createUserWithEmail:email password:_passwordTF.text completion:^(FIRUser *user, NSError *error) {
            
            if (error) {
                NSLog(@"ERROR: %@", error);
            } else {
                [self addUserProfileInfo:user.uid username:username email:email];
            }
        }];
    }
}

#pragma mark Validation Helper Methods

//Alert Message function.
-(void)signUpFailedAlertView:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController =[UIAlertController
                                         alertControllerWithTitle:title
                                         message:message
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:true completion:nil];
    
}

//Validates the user's email with regex.
-(BOOL)validateEmail:(NSString *)email {
    
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"self matches %@", emailRegEx];
    BOOL result = [emailTest evaluateWithObject:email];
    
    return result;
}

//validates the user's password with regex.
-(BOOL)validatePassword:(NSString *)password {
    NSString    *regex = @"^(?=.*[a-zA-Z])(?=.*[0-9])[a-zA-Z0-9]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidPassword = [predicate evaluateWithObject:password];
    return isValidPassword;
}

-(void)validateUsernameUniqueness:(NSString *)username {
    FirebaseDatabaseService *firebaseDatabaseService = [FirebaseDatabaseService sharedInstance];
    [firebaseDatabaseService initWithReference];
    
    FIRDatabaseReference *userRef = [firebaseDatabaseService.ref child:@"users"];
    [userRef observeEventType:FIRDataEventTypeChildAdded
        withBlock:^(FIRDataSnapshot *snapshot) {
            
        }];

}

#pragma mark Sign Up IBAction

- (IBAction)signUpNewUser:(id)sender {
    
    [self validateUsernameUniqueness:_usernameTF.text];
    
    //email valid but password fields don't match
    if ([self validateEmail:_emailTF.text] && ![_passwordTF.text isEqualToString:_repeatPasswordTF.text]) {
        [self signUpFailedAlertView:@"Sign Up Failed" message:@"Please make sure your passwords match."];
        //email is not valid but password fields match
    }else if (![self validateEmail:_emailTF.text] && [_passwordTF.text isEqualToString:_repeatPasswordTF.text]) {
        [self signUpFailedAlertView:@"Sign Up Failed" message:@"Please make sure you put in a valid email."];
        //BOTH email and password are not validated
    } else if (![self validateEmail:_emailTF.text] && ![self validatePassword:_passwordTF.text]) {
        [self signUpFailedAlertView:@"Sign Up Failed" message:@"Your email and password aren't valid"];
        //email is valid but password is not.
    } else if ([self validateEmail:_emailTF.text] && ![self validatePassword:_passwordTF.text]) {
        [self signUpFailedAlertView:@"Sign Up Failed" message:@"password must contain letters and numbers"];
    } else if (_usernameTF.text.length < 5 && ![_usernameTF.text containsString:@" "]) {
        [self signUpFailedAlertView:@"Sign Up Failed" message:@"Username must be at least 5 characters (no white space.)"];
    } else {
        [self signUpUserWithFirebase];
    }
    
}

@end
