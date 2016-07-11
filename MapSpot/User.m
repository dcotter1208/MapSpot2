//
//  User.m
//  MapSpot
//
//  Created by DetroitLabs on 6/2/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype)initWithUsername:(NSString *)username fullName:(NSString *)fullName email:(NSString *)email userId:(NSString *)userId {
    self = [super init];
    
    if (self) {
        _username = username;
        _fullName = fullName;
        _email = email;
        _userId = userId;
    }
    return self;
}

@end
