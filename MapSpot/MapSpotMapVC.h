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
#import "UserSpotCreationVC.h"

@interface MapSpotMapVC : UIViewController <CreateSpotDelegate>

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) NSMutableArray *spots;

@end

