//
//  UserSpotCreationVC.h
//  MapSpot
//
//  Created by DetroitLabs on 5/29/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Spot.h"

@interface UserSpotCreationVC : UIViewController

@property(nonatomic) CLLocationCoordinate2D coordinatesForCreatedSpot;
@property(nonatomic, strong) Spot *spot;

@end
