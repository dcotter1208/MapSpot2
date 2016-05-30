//
//  Spot.m
//  MapSpot
//
//  Created by DetroitLabs on 5/29/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "Spot.h"

@implementation Spot

-(id)initWithSpotCoordinates:(CLLocationCoordinate2D)spotCoordinates user:(NSString *)user createdAt:(NSDate *)createdAt
{
    self = [super init];
    
    if (self) {
        _spotCoordinates = spotCoordinates;
        _user = user;
        _createdAt = createdAt;
    }
    return self;
}

+(id)initWithSpotCoordinates:(CLLocationCoordinate2D)spotCoordinates user:(NSString *)user createdAt:(NSDate *)createdAt
{
    return [[self alloc]initWithSpotCoordinates:spotCoordinates user:user createdAt:createdAt];
}

@end
