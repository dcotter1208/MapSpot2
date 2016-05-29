//
//  ViewController.m
//  MapSpot
//
//  Created by DetroitLabs on 5/27/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

/*
 
 MKAnnotationView.image is that image property that will return whatver image we want and not the pin. This is what we can set to the user's selected pin image.
 
 */

#import "MapSpotMapVC.h"

@interface MapSpotMapVC () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapStyleNavBarButton;

@end

CLLocation *newLocation, *oldLocation;

@implementation MapSpotMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self mapSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mapSetup {
    [_mapView setDelegate:self];
    [_mapView setShowsPointsOfInterest:false];
    [_mapView setMapType:MKMapTypeStandard];
    [_mapView setShowsUserLocation:true];
    [self getUserLocation];
}

-(void)getUserLocation {

    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc]init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager setDistanceFilter:50];
        [_locationManager startUpdatingLocation];
        newLocation = _locationManager.location;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    newLocation = [locations lastObject];
    
    if (locations.count > 1) {
        NSUInteger newLocationIndex = [locations indexOfObject:newLocation];
        oldLocation = [locations objectAtIndex:newLocationIndex];
    } else {
        oldLocation = nil;
    }
    
    MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
    [_mapView setRegion:userLocation animated:YES];
    
}

- (IBAction)changeMapStyle:(id)sender {
    
    if (_mapView.mapType == MKMapTypeStandard) {
        [_mapView setMapType:MKMapTypeHybridFlyover];
        [_mapView setShowsCompass:true];
        _mapStyleNavBarButton.title = @"Standard";
    } else {
        [_mapView setMapType:MKMapTypeStandard];
        _mapStyleNavBarButton.title = @"3D";
    }
}

- (IBAction)goBackToMyLocation:(id)sender {
    MKCoordinateRegion usersCurrentLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);

    [_mapView setRegion:usersCurrentLocation animated:true];
    
}

@end
