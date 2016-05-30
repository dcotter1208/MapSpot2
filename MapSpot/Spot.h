//
//  Spot.h
//  MapSpot
//
//  Created by DetroitLabs on 5/29/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Spot : NSObject

@property(nonatomic, strong) NSString *user;
@property(nonatomic, strong) NSDate *createdAt;
@property(nonatomic) CLLocationCoordinate2D spotCoordinates;
@property(nonatomic, strong) NSString *message;

-(id)initWithSpotCoordinates:(CLLocationCoordinate2D)spotCoordinates user:(NSString *)user createdAt:(NSDate *)createdAt;
+(id)initWithSpotCoordinates:(CLLocationCoordinate2D)spotCoordinates user:(NSString *)user createdAt:(NSDate *)createdAt;



@end
