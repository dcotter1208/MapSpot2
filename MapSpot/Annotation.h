//
//  Annotation.h
//  MapSpot
//
//  Created by DetroitLabs on 5/30/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Spot.h"

@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic, strong) Spot *spotAtAnnotation;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;

-(instancetype)initWithAnnotationSpot:(Spot *)spot coordinate:(CLLocationCoordinate2D)coordinate;
+(instancetype)initWithAnnotationSpot:(Spot *)spot coordinate:(CLLocationCoordinate2D)coordinate;

@end
