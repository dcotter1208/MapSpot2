//
//  FirebaseDatabaseService.m
//  MapSpot
//
//  Created by DetroitLabs on 6/29/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "FirebaseDatabaseService.h"

@implementation FirebaseDatabaseService

+ (instancetype)sharedInstance {
    static FirebaseDatabaseService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FirebaseDatabaseService alloc] initPrivately];
    });
    return sharedInstance;
}

- (instancetype)initPrivately {
    self = [super init];
//    if (self) {
//        _ref = [[FIRDatabase database] reference];
//    }
    return self;
}

-(void)initWithReference {
    _ref = [[FIRDatabase database] reference];
}

@end
