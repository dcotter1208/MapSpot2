//
//  FirebaseOperation.m
//  MapSpot
//
//  Created by DetroitLabs on 7/12/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "FirebaseOperation.h"
#import "CurrentUser.h"
@import FirebaseAuth;

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

-(void)queryFirebaseWithConstraintsForChild:(NSString *)child queryOrderedByChild:(NSString *)childKey queryEqualToValue:(NSString *)value andFIRDataEventType:(FIRDataEventType)FIRDataEventType completion:(void(^)(FIRDataSnapshot *snapshot))completion {
    
    FIRDatabaseQuery *query = [[[_firebaseDatabaseService.ref child:child]queryOrderedByChild:childKey] queryEqualToValue:value];
    
    [query observeSingleEventOfType:FIRDataEventType withBlock:^(FIRDataSnapshot *snapshot) {
        completion(snapshot);
    }];
}

-(void)setValueForFirebaseChild:(NSString *)child value:(NSDictionary *)value {
    
    FIRDatabaseReference *childRef = [_firebaseDatabaseService.ref child:child].childByAutoId;

    [childRef setValue:value];
    
}

@end
