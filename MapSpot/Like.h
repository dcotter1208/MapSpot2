//
//  Like.h
//  MapSpot
//
//  Created by DetroitLabs on 7/27/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spot.h"
#import "CurrentUser.h"

@interface Like : NSObject

@property(nonatomic, strong) NSString *userID;
@property(nonatomic, strong) NSString *likeID;
@property(nonatomic, strong) NSString *spotReference;

-(instancetype)initWithUserID:(NSString *)userID andSpotReference:(NSString *)spotReference;

@end
