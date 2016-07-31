//
//  Spot.m
//  MapSpot
//
//  Created by DetroitLabs on 5/29/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "Spot.h"

@implementation Spot

-(instancetype)initWithSpotCoordinates:(CLLocationCoordinate2D)spotCoordinates userID:(NSString *)userID createdAt:(NSString *)createdAt
{
    self = [super init];
    
    if (self) {
        _spotCoordinates = spotCoordinates;
        _userID = userID;
        _createdAt = createdAt;
        _spotImages = [[NSMutableArray alloc]init];
        _likes = [[NSMutableArray alloc]init];
    }
    return self;
}

+(instancetype)initWithSpotCoordinates:(CLLocationCoordinate2D)spotCoordinates userID:(NSString *)userID createdAt:(NSString *)createdAt
{
    return [[self alloc]initWithSpotCoordinates:spotCoordinates userID:userID createdAt:createdAt];
}

@end
