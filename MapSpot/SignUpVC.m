//
//  SignUpVC.m
//  MapSpot
//
//  Created by DetroitLabs on 6/2/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "SignUpVC.h"

@interface SignUpVC ()

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

- (IBAction)signUpNewUser:(id)sender {
    
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://mapspotios.firebaseio.com"];
    [ref createUser:@"donovan.cotter@yahoo.com" password:@"password123"
withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
    
    if (error) {
        NSLog(@"Error: %@", error);
        // There was an error creating the account
    } else {
        NSString *uid = [result objectForKey:@"uid"];
        NSLog(@"Successfully created user account with uid: %@", uid);
    }
}];
    
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];

}

@end
