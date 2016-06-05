//
//  FBDataService.h
//  MapSpot
//
//  Created by DetroitLabs on 6/5/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface FBDataService : NSObject

@property(nonatomic, strong) FIRDatabaseReference *ref;


@end
