//
//  Annotation.m
//  MapSpot
//
//  Created by DetroitLabs on 5/30/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

-(instancetype)initWithAnnotationSpot:(Spot *)spot coordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    
    if (self) {
        _spotAtAnnotation = spot;
        _title = spot.userID;
        _subtitle = spot.message;
        _coordinate = coordinate;
    }
    
    return self;
}

+(instancetype)initWithAnnotationSpot:(Spot *)spot coordinate:(CLLocationCoordinate2D)coordinate {
    return [[self alloc]initWithAnnotationSpot:spot coordinate:coordinate];
}

@end
