//
//  LoginVC.m
//  MapSpot
//
//  Created by DetroitLabs on 6/2/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "LoginVC.h"
#import "CurrentUser.h"
#import "FirebaseDatabaseService.h"
@import FirebaseAuth;

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

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

-(void)getCurrentUserInfoFromFirebaseDatabaseWithCompletion:(void(^)(FIRDataSnapshot *snapshot))completion {
    FirebaseDatabaseService *firebaseDatabaseService = [FirebaseDatabaseService sharedInstance];
    [firebaseDatabaseService initWithReference];
    FIRDatabaseQuery *currentUserQuery = [[[firebaseDatabaseService.ref child:@"users"]queryOrderedByChild:@"userID"]queryEqualToValue:[FIRAuth auth].currentUser.uid];
    [currentUserQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        completion(snapshot);
    } withCancelBlock:^(NSError *error) {
        NSLog(@"Error***ERROR***ERROR*****ERROR: %@", error);
    }];
}

-(void)setCurrentUser:(FIRDataSnapshot *)snapshot {
    CurrentUser *currentUser = [CurrentUser sharedInstance];
    
    for (FIRDataSnapshot *child in snapshot.children) {
        [currentUser initWithUsername:child.value[@"username"] fullName:child.value[@"fullName"] email:child.value[@"email"] userId:child.value[@"userID"]];
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
            if (error.code == 17999) {
                [self loginFailedAlertView:@"Login Failed" message:[NSString stringWithFormat:@"%@ doesn't appear to be an existing email", _emailTF.text]];
            } else if (error.code == 17009) {
                [self loginFailedAlertView:@"Login Failed" message:@"Your password doesn't appear to be correct. Please try again."];
            } else {
                [self loginFailedAlertView:@"Login Failed" message:@"Please try again."];
            }
        } else {
            [self getCurrentUserInfoFromFirebaseDatabaseWithCompletion:^(FIRDataSnapshot *snapshot) {
                [self setCurrentUser:snapshot];
            }];
        }
    }];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self loginUserWithFirebaseAuth];
}



@end
