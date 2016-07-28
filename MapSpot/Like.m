//
//  Like.m
//  MapSpot
//
//  Created by DetroitLabs on 7/27/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "Like.h"
#import "FirebaseOperation.h"

@implementation Like

-(instancetype)initWithUserID:(NSString *)userID andSpotReference:(NSString *)spotReference {
    self = [super init];
    
    if (self) {
        _likeID = [[NSUUID UUID]UUIDString];
        _userID = userID;
        _spotReference = spotReference;
    }
    return self;
}

@end
