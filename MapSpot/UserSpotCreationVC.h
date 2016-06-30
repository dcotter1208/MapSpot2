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

@protocol CreateSpotDelegate <NSObject>

-(void)createSpotWithUser:(NSString *)user message:(NSString *)message coordinates:(CLLocationCoordinate2D)coordinates createdAt:(NSDate *)createdAt;

@end

@interface UserSpotCreationVC : UIViewController
@property(nonatomic, weak) id<CreateSpotDelegate>delegate;

@property(nonatomic) CLLocationCoordinate2D coordinatesForCreatedSpot;
@property(nonatomic, strong) Spot *spot;

@end
