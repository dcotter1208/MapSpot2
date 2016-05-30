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

    NSDate *now = [NSDate date];
    
    _spot = [Spot initWithSpotCoordinates: CLLocationCoordinate2DMake(_coordinatesForCreatedSpot.latitude, _coordinatesForCreatedSpot.longitude) user:@"donovancotter" createdAt:now];
    _spot.message = @"Hello! I'm Donovan!";
    
    NSLog(@"Spot Coordinates: %f and %f", _spot.spotCoordinates.latitude, _spot.spotCoordinates.longitude);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)performDelegateForCreateingSpot {
    NSDate *now = [NSDate date];
    [self.delegate createSpotWithUser:_spot.user message:_spot.message coordinates:(_coordinatesForCreatedSpot) createdAt:now];
    NSLog(@"SPOT DELEGATE:: %f, %f", _coordinatesForCreatedSpot.latitude, _coordinatesForCreatedSpot.longitude);
}

- (IBAction)createSpotButtonPressed:(id)sender {
    
    [self performDelegateForCreateingSpot];
    
}

@end
