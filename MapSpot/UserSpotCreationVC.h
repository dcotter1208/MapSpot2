//
//  UserSpotCreationVC.h
//  MapSpot
//
//  Created by DetroitLabs on 5/29/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//
@import FirebaseAuth;
@import FirebaseDatabase;
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Spot.h"

@interface UserSpotCreationVC : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic) CLLocationCoordinate2D coordinatesForCreatedSpot;

@end
