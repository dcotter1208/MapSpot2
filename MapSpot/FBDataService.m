//
//  FBDataService.m
//  MapSpot
//
//  Created by DetroitLabs on 6/5/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "FBDataService.h"

@implementation FBDataService

- (id)init {
    self = [super init];
    if (self) {
        self.ref = [[FIRDatabase database] reference];
    }
    return self;
}

@end
