//
//  FirebaseOperation.m
//  MapSpot
//
//  Created by DetroitLabs on 7/12/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "FirebaseOperation.h"

@implementation FirebaseOperation

-(instancetype)init {
    self = [super init];
    if (self) {
        _firebaseDatabaseService = [[FirebaseDatabaseService alloc]init];
        [_firebaseDatabaseService initWithReference];
    }
    return self;
}

-(void)queryFirebaseWithNoConstraintsForChild:(NSString *)child andFIRDataEventType:(FIRDataEventType)FIRDataEventType completion:(void(^)(FIRDataSnapshot *snapshot))completion {
    
    FIRDatabaseReference *childRef = [_firebaseDatabaseService.ref child:child];
    [childRef observeEventType:FIRDataEventType withBlock:^(FIRDataSnapshot *snapshot) {
        completion(snapshot);
    }];
}

@end
