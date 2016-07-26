//
//  Spot.h
//  MapSpot
//
//  Created by DetroitLabs on 5/29/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


/*

 MAKE A SPOT PROTOCOL. THIS WILL BE SOMETHING THAT ALL SPOTS HAVE AND WORK ACROSS THE USER SPOTS, BUSINESS SPOTS, POINTS OF INTEREST SPOTS... IT WILL BE MORE EXPANSIVE.
 
*/

@interface Spot : NSObject

@property(nonatomic, strong) NSString *userID;
@property(nonatomic, strong) NSString *createdAt;
@property(nonatomic) CLLocationCoordinate2D spotCoordinates;
@property(nonatomic, strong) NSString *message;
@property(nonatomic, strong) NSMutableArray *spotImages;
@property(nonatomic, strong) NSString *spotReference;

-(instancetype)initWithSpotCoordinates:(CLLocationCoordinate2D)spotCoordinates userID:(NSString *)userID createdAt:(NSString *)createdAt;
+(instancetype)initWithSpotCoordinates:(CLLocationCoordinate2D)spotCoordinates userID:(NSString *)userID createdAt:(NSString *)createdAt;


@end
