//
//  UserSpotCreationVC.m
//  MapSpot
//
//  Created by DetroitLabs on 5/29/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "UserSpotCreationVC.h"

@interface UserSpotCreationVC ()
@property (weak, nonatomic) IBOutlet UITextView *messageTF;

@end

@implementation UserSpotCreationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Lat: %f Long: %f", _coordinatesForCreatedSpot.latitude, _coordinatesForCreatedSpot.longitude);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createSpotWithUsername:(NSString *)username message:(NSString *)message latitude:(NSString *)latitude longitude:(NSString *)longitude {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *createdAt = [dateFormatter stringFromDate:now];
    
    FIRAuth *auth = [FIRAuth auth];
    FIRUser *currentUser = [auth currentUser];
    
    FBDataService *fbDataService = [[FBDataService alloc]init];
    FIRDatabaseReference *spotRef = [fbDataService.ref child:@"spots"].childByAutoId;
    
    NSDictionary *spot = @{@"userID": currentUser.uid, @"username": username, @"email": currentUser.email, @"latitude":latitude, @"longitude": longitude, @"message": message, @"createdAt": createdAt};
    
    [spotRef setValue:spot];
}

-(void)performDelegateForCreateingSpot {
    NSDate *now = [NSDate date];
    [self.delegate createSpotWithUser:_spot.user message:_messageTF.text coordinates:(_coordinatesForCreatedSpot) createdAt:now];
}

- (IBAction)createSpotButtonPressed:(id)sender {
    
    NSString *latAsString = [NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.latitude];
    NSString *longAsString = [NSString stringWithFormat:@"%f", _coordinatesForCreatedSpot.longitude];

    [self createSpotWithUsername:@"DonovanCotter" message:_messageTF.text latitude: latAsString longitude:longAsString];
    
}

@end
