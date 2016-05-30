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

    //This creates a fake spot for testing and will be deleted when the user can input a spot to create.
    [self produceTESTSpot];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//**************************************************************************
//You will delete this.
-(void)produceTESTSpot {
    NSDate *now = [NSDate date];
    _spot = [Spot initWithSpotCoordinates: CLLocationCoordinate2DMake(_coordinatesForCreatedSpot.latitude, _coordinatesForCreatedSpot.longitude) user:@"donovancotter" createdAt:now];
    NSLog(@"Spot Message:%@", _spot.message);
    NSLog(@"Spot Coordinates: %f and %f", _spot.spotCoordinates.latitude, _spot.spotCoordinates.longitude);
//**************************************************************************
}

-(void)performDelegateForCreateingSpot {
    NSDate *now = [NSDate date];
    [self.delegate createSpotWithUser:_spot.user message:_messageTF.text coordinates:(_coordinatesForCreatedSpot) createdAt:now];
    NSLog(@"SPOT DELEGATE:: %f, %f", _coordinatesForCreatedSpot.latitude, _coordinatesForCreatedSpot.longitude);
}

- (IBAction)createSpotButtonPressed:(id)sender {
    
    [self performDelegateForCreateingSpot];
    
}

@end
