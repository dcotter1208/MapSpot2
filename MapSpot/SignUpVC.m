//
//  SignUpVC.m
//  MapSpot
//
//  Created by DetroitLabs on 6/2/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "SignUpVC.h"
#import "FirebaseOperation.h"
#import "CurrentUser.h"
#import "AlertView.h"
@import FirebaseDatabase;
@import Firebase;
@import FirebaseAuth;

@interface SignUpVC ()

#pragma mark IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;

#pragma mark Properties
@property (nonatomic, strong) AlertView *alertView;

@end

@implementation SignUpVC

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _alertView = [[AlertView alloc]init];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Firebase Helper Methods

//Creates a user profile on Firebase Database.
-(void)addUserProfileInfo:(NSString *)userId username:(NSString *)username fullName:(NSString *)fullName email:(NSString *)email {
    
    NSDictionary *userProfile = @{@"userId": userId,
                                  @"username": username,
                                  @"fullName": fullName,
                                  @"email": email};
    
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    
    [firebaseOperation setValueForFirebaseChild:@"users" value:userProfile];

}

//Signs up the user for Firebase email/password auth.
-(void)signUpUserWithFirebase {
    
    NSString *email = [self removeLeadingAndTrailingWhitespace: _emailTF.text removeAllWhiteSpace:true];
    NSString *password = [self removeLeadingAndTrailingWhitespace: _passwordTF.text removeAllWhiteSpace:true];
    NSString *repeatPassowrd = [self removeLeadingAndTrailingWhitespace:_repeatPasswordTF.text removeAllWhiteSpace:true];
    NSString *username = [self removeLeadingAndTrailingWhitespace:_usernameTF.text removeAllWhiteSpace:false];
    NSString *fullName = [self removeLeadingAndTrailingWhitespace:_nameTF.text removeAllWhiteSpace:false];
    
    if ([password isEqualToString:repeatPassowrd]) {
        [[FIRAuth auth]createUserWithEmail:email password:password completion:^(FIRUser *user, NSError *error) {
            
            if (error) {
                if (error.code == 17007) {
                    [_alertView genericAlert:@"Sign Up Failed" message:@"%@ is already in use." presentingViewController:self];
                } else if ((error.code == 1001) || error.code == 1009) {
                    [_alertView genericAlert:@"Sign Up Failed" message:@"Network Connection Failed." presentingViewController:self];
                } else {
                    NSLog(@"ERROR: %@", error);
                }
            } else {
                [self addUserProfileInfo:user.uid username:username fullName:fullName email:email];
                [self getCurrentUserProfileFromFirebase];
            }
        }];
    }
}

#pragma mark Validation Helper Methods

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


-(void)getCurrentUserProfileFromFirebase {
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    [firebaseOperation queryFirebaseWithConstraintsForChild:@"users" queryOrderedByChild:@"userId" queryEqualToValue:[FIRAuth auth].currentUser.uid andFIRDataEventType:FIRDataEventTypeValue completion:^(FIRDataSnapshot *snapshot) {
        [self setCurrentUser:snapshot];
    }];
}

-(void)setCurrentUser:(FIRDataSnapshot *)snapshot {
    CurrentUser *currentUser = [CurrentUser sharedInstance];
    
    for (FIRDataSnapshot *child in snapshot.children) {
        [currentUser updateCurrentUser:child];
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

#pragma mark Sign Up IBAction

- (IBAction)signUpNewUser:(id)sender {
    
    NSString *email = [self removeLeadingAndTrailingWhitespace: _emailTF.text removeAllWhiteSpace:true];
    NSString *password = [self removeLeadingAndTrailingWhitespace: _passwordTF.text removeAllWhiteSpace:true];
    NSString *repeatPassowrd = [self removeLeadingAndTrailingWhitespace:_repeatPasswordTF.text removeAllWhiteSpace:true];
    NSString *username = [self removeLeadingAndTrailingWhitespace:_usernameTF.text removeAllWhiteSpace:false];
    NSString *fullName = [self removeLeadingAndTrailingWhitespace:_nameTF.text removeAllWhiteSpace:false];

    //email valid but password fields don't match
    if ([self validateEmail:email] && ![password isEqualToString:repeatPassowrd]) {
        [_alertView genericAlert:@"Sign Up Failed." message:@"Please make sure your passwords match." presentingViewController:self];
        
        //email is not valid but password fields match
    }else if (![self validateEmail:email] && [password isEqualToString:repeatPassowrd]) {
        [_alertView genericAlert:@"Sign Up Failed." message:@"Please make sure you put in a valid email." presentingViewController:self];
        
        //BOTH email and password are not validated
    } else if (![self validateEmail:email] && ![self validatePassword:password]) {
        [_alertView genericAlert:@"Sign Up Failed" message:@"Your email and password aren't valid" presentingViewController:self];
        
        //email is valid but password is not.
    } else if ([self validateEmail:email] && ![self validatePassword:password]) {
        [_alertView genericAlert:@"Sign Up Failed" message:@"password must contain letters and numbers" presentingViewController:self];
        
        //Username has to be > 5 chars and no whitespace.
    } else if (username.length < 5 || [username containsString:@" "]) {
        [_alertView genericAlert:@"Sign Up Failed." message:@"Username must be at least 5 characters (no white space.)" presentingViewController:self];
        
        //Checks if the name textfield is empty.
    } else if ([fullName isEqualToString:@""]) {
        [_alertView genericAlert:@"Sign Up Failed." message:@"Please enter your name." presentingViewController:self];
        
        //Checks for username uniqueness
    } else {
        [self validateUsernameUniqueness:username completion:^(FIRDataSnapshot *snapshot) {
            if ([snapshot exists]) {
                [_alertView genericAlert:@"Sign Up Failed" message:@"The username '%@' is taken." presentingViewController:self];
                
                //If all conditions pass and the username is unique then the user is signed up with Firebase.
            } else {
                [self signUpUserWithFirebase];
            }
        }];
    }
    
}

@end
