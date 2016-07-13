//
//  LoginVC.m
//  MapSpot
//
//  Created by DetroitLabs on 6/2/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "LoginVC.h"
#import "CurrentUser.h"
#import "FirebaseOperation.h"
#import "AlertView.h"
@import FirebaseAuth;

@interface LoginVC ()

#pragma mark IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

#pragma mark Properties
@property (nonatomic, strong) AlertView *alertView;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Gets the current user's profile from Firebase.
-(void)getCurrentUserProfileFromFirebase {
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    [firebaseOperation queryFirebaseWithConstraintsForChild:@"users" queryOrderedByChild:@"userId" queryEqualToValue:[FIRAuth auth].currentUser.uid andFIRDataEventType:FIRDataEventTypeValue completion:^(FIRDataSnapshot *snapshot) {
        [self setCurrentUser:snapshot];
    }];
}

//Sets the CurrentUser singleton once the user profile is returned from Firebase.
-(void)setCurrentUser:(FIRDataSnapshot *)snapshot {
    CurrentUser *currentUser = [CurrentUser sharedInstance];
    
    for (FIRDataSnapshot *child in snapshot.children) {
        [currentUser updateCurrentUser:child]; 
    }
}

//Used to display alert for failed login.
-(void)loginFailedAlertView:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController =[UIAlertController
                                         alertControllerWithTitle:title
                                         message:message
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:true completion:nil];
    
}

//Logs the user into Firebase or displays an error message using the loginFailedAlerView func if there was an error.
-(void)loginUserWithFirebaseAuth {
    [[FIRAuth auth] signInWithEmail:_emailTF.text password:_passwordTF.text completion:^(FIRUser *user, NSError *error) {
        if (error) {
            
            //Not a valid email.
            if (error.code == 17999) {
                [_alertView genericAlert:@"Login Failed" message:[NSString stringWithFormat:@"%@ doesn't appear to be an existing email", _emailTF.text] presentingViewController:self];
                
                //Password incorrect
            } else if (error.code == 17009) {
                [_alertView genericAlert:@"Login Failed" message:@"Your password doesn't appear to be correct. Please try again." presentingViewController:self];
                //Generic Failure.
            } else {
                [_alertView genericAlert:@"Login Failed" message:@"Please try again." presentingViewController:self];
            }
        } else {
            [self getCurrentUserProfileFromFirebase];
        }
    }];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self loginUserWithFirebaseAuth];
}



@end
