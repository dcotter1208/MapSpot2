//
//  FirebaseDatabaseService.h
//  MapSpot
//
//  Created by DetroitLabs on 6/29/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@import FirebaseDatabase;
@import FirebaseStorage;

@interface FirebaseDatabaseService : NSObject

@property (nonatomic, strong) FIRDatabaseReference *ref;
@property (nonatomic, strong) FIRStorageReference *firebaseStorageRef;
@property (nonatomic, strong) FIRStorage *firebaseStorage;

+(instancetype)sharedInstance;
-(void)initWithReference;

@end
