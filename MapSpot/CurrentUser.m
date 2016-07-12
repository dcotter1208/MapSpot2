//
//  CurrentUser.m
//  MapSpot
//
//  Created by DetroitLabs on 7/11/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser

+ (instancetype)sharedInstance {
    static CurrentUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CurrentUser alloc] initPrivately];
    });
    return sharedInstance;
}

- (instancetype)initPrivately {
    self = [super init];
    return self;
}

-(void)initWithUsername:(NSString *)username fullName:(NSString *)fullName email:(NSString *)email userId:(NSString *)userId {
    _username = username;
    _fullName = fullName;
    _email = email;
    _userId = userId;
}

-(void)updateCurrentUser:(FIRDataSnapshot *)snapshot {
    self.username = snapshot.value[@"username"];
    self.fullName = snapshot.value[@"fullName"];
    self.bio = snapshot.value[@"bio"];
    self.location = snapshot.value[@"location"];
    self.DOB = snapshot.value[@"DOB"];
    self.profileKey = snapshot.key;
    
    //WILL HAVE TO UPDATE PHOTOS AND URLS HERE TOO...
    
}

@end
