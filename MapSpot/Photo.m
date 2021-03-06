//
//  Photo.m
//  MapSpot
//
//  Created by DetroitLabs on 7/23/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "Photo.h"

@implementation Photo

-(instancetype)initWithDownloadURL:(NSString *)downloadURL andIndex:(int)index {
    self = [super init];
    if (self) {
        _downloadURL = downloadURL;
        _index = index;
        _photoReference = [[NSUUID UUID]UUIDString];
    }
    return self;
}

@end
