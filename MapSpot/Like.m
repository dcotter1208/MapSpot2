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

-(void)addLikeToSpot:(Spot *)spot {

}

-(void)removeLikeFromSpot:(Spot *)spot {

}

-(BOOL)currentUserAlreadyLikeSpot:(Spot *)spot currentUser:(CurrentUser *)currentUser {
    
    [self queryLikesForSpot:spot withValueFor:currentUser withCompletion:^(id response) {
        NSLog(@"RESPONSE: %@", response);
    }];
    
    return TRUE;
}

-(void)queryLikesForSpot:(Spot *)spot withValueFor:(CurrentUser *)currentUser withCompletion:(void(^)(id response))completion {
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    
    FIRDatabaseQuery *query = [[[[firebaseOperation.firebaseDatabaseService.ref child:@"likes"]queryOrderedByChild:@"spotReference"] queryEqualToValue:spot.spotReference]queryEqualToValue:currentUser.userId];
    
    
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        if ([snapshot exists]) {
            completion(snapshot.value);
//            NSLog(@"%@", snapshot.value);
        } else {
            completion(@"No such snapshot");
//            NSLog(@"No such snapshot");
        }
    }];
    

}

@end
