//
//  SignUpVC.m
//  MapSpot
//
//  Created by DetroitLabs on 6/2/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "SignUpVC.h"
#import "FirebaseDatabaseService.h"
#import "CurrentUser.h"
@import FirebaseDatabase;
@import Firebase;
@import FirebaseAuth;

@interface SignUpVC ()

#pragma mark Properties

@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;

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
-(void)addUserProfileInfo:(NSString *)userID username:(NSString *)username fullName:(NSString *)fullName email:(NSString *)email {
    
    FirebaseDatabaseService *firebaseDatabaseService = [FirebaseDatabaseService sharedInstance];
    [firebaseDatabaseService initWithReference];
    
    FIRDatabaseReference *userRef = [firebaseDatabaseService.ref child:@"users"].childByAutoId;
    NSDictionary *userProfile = @{@"userID": userID,
                                  @"username": username,
                                  @"fullName": fullName,
                                  @"email": email};
    
    [userRef setValue:userProfile];

}

//Signs up the user for Firebase email/password auth.
-(void)signUpUserWithFirebase {
    
    if ([_passwordTF.text isEqualToString:_repeatPasswordTF.text]) {
        [[FIRAuth auth]createUserWithEmail:_emailTF.text password:_passwordTF.text completion:^(FIRUser *user, NSError *error) {
            
            if (error) {
                NSLog(@"ERROR: %@", error);
            } else {
                [self addUserProfileInfo:user.uid username:_usernameTF.text fullName:_nameTF.text email:_emailTF.text];
                [self setCurrentUser];
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

-(void)setCurrentUser {
    CurrentUser *currentUser = [CurrentUser sharedInstance];
    [currentUser initWithUsername:_usernameTF.text fullName:_nameTF.text email:_emailTF.text userId:[FIRAuth auth].currentUser.uid];
}

/*
 -this is validating if the username exists but
 if it doesn't it was not hitting the ELSE statement in the signUpNewUser IBAction.
 Need to set Firebase security rules to coorelate with this method.
 */
-(void)validateUsernameUniqueness:(NSString *)username completion:(void(^)(FIRDataSnapshot *snapshot))completion {
    FirebaseDatabaseService *firebaseDatabaseService = [FirebaseDatabaseService sharedInstance];
    [firebaseDatabaseService initWithReference];
    
    FIRDatabaseReference *userRef = [firebaseDatabaseService.ref child:@"users"];
    FIRDatabaseQuery *usernameUniquenessQuery = [[userRef queryOrderedByChild:@"username"]queryEqualToValue:username];
    [usernameUniquenessQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        completion(snapshot);
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark Sign Up IBAction

- (IBAction)signUpNewUser:(id)sender {
    
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
    } else if ([_nameTF.text isEqualToString:@""]) {
        [self signUpFailedAlertView:@"Sign Up Failed" message:@"Please enter your name."];
    } else {
        [self validateUsernameUniqueness:_usernameTF.text completion:^(FIRDataSnapshot *snapshot) {
            if ([snapshot exists]) {
                [self signUpFailedAlertView:@"Sign Up Failed" message:[NSString stringWithFormat:@"The username '%@' is taken.", _usernameTF.text]];
            } else {
                [self signUpUserWithFirebase];
            }
        }];
    }
    
}

@end
