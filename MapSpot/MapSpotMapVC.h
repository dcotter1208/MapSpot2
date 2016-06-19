//
//  ViewController.h
//  MapSpot
//
//  Created by DetroitLabs on 5/27/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import "UserSpotCreationVC.h"
#import "Annotation.h"

@interface MapSpotMapVC : UIViewController

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) NSMutableArray *spots;

@end

