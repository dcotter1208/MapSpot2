//
//  FirebaseOperation.h
//  MapSpot
//
//  Created by DetroitLabs on 7/12/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirebaseDatabaseService.h"
@import Firebase;
@import FirebaseDatabase;

@interface FirebaseOperation : NSObject

@property (nonatomic, strong) FirebaseDatabaseService *firebaseDatabaseService;

-(void)queryFirebaseWithNoConstraintsForChild:(NSString *)child andFIRDataEventType:(FIRDataEventType)FIRDataEventType completion:(void(^)(FIRDataSnapshot *snapshot))completion;

-(void)queryFirebaseWithConstraintsForChild:(NSString *)child queryOrderedByChild:(NSString *)childKey queryEqualToValue:(NSString *)value andFIRDataEventType:(FIRDataEventType)FIRDataEventType completion:(void(^)(FIRDataSnapshot *snapshot))completion;

-(instancetype)init;

@end
