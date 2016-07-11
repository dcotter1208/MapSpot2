//
//  User.m
//  MapSpot
//
//  Created by DetroitLabs on 6/2/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype)initWithUsername:(NSString *)username name:(NSString *)name email:(NSString *)email userId:(NSString *)userId {
    self = [super init];
    
    if (self) {
        _username = username;
        _name = name;
        _email = email;
        _userId = userId;
    }
    return self;
}

@end
