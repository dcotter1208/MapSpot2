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
#import "UserSpotCreationVC.h"
#import "Spot.h"
#import "FirebaseDatabaseService.h"
#import "UserSpotCreationVC.h"
#import "Annotation.h"
@import FirebaseAuth;
@import FirebaseDatabase;
@import MapKit;
@import CoreLocation;

@interface MapSpotMapVC () <MKMapViewDelegate, CLLocationManagerDelegate>

#pragma mark Properties
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapStyleNavBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *quickSpotNavBarButton;
@property (nonatomic, strong) IBOutlet UILongPressGestureRecognizer *longPressGesture;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *newestLocation;
@property(nonatomic) MKCoordinateRegion userLocation;
@property(nonatomic)CLLocationCoordinate2D longPressCoordinates;

@end


@implementation MapSpotMapVC

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self querySpotsFromFirebase];
    [self mapSetup];
    [self setUpLongPressGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Helper Methods
//Sets up the MKMapView and calls the getUserLocation function.
-(void)mapSetup {
    [_mapView setDelegate:self];
    [_mapView setShowsPointsOfInterest:false];
    [_mapView setMapType:MKMapTypeHybridFlyover];
    [_mapView setShowsUserLocation:true];
    [self getUserLocation];
}

#pragma mark CLLocation Help Methods

//Gets the user's current location.
-(void)getUserLocation {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc]init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager setDistanceFilter:50];
        [_locationManager startUpdatingLocation];
        _newestLocation = _locationManager.location;
    }
}

//Updates the user's location.
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    _newestLocation = [locations lastObject];
    
    _userLocation = MKCoordinateRegionMakeWithDistance(_newestLocation.coordinate, 300.0, 300.0);
    [_mapView setRegion:_userLocation animated:YES];
    
}


#pragma mark Map Actions Help Method

/*
 Sets longPressGesture's duration and maximum movement
 of the fingers on the view before the gesture fails.
*/
 -(void)setUpLongPressGesture {
    _longPressGesture.minimumPressDuration = 2;
    _longPressGesture.allowableMovement = 100.0f;
}

//Determines what occurs when there is a UILongPressGesture detected.
- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender {
    if ([sender isEqual:_longPressGesture]) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            [self performSegueWithIdentifier:@"segueToUserSpotCreationVC" sender:self];
        }
    }
}

/*
 Creates an instance of Annotation,
 sets the annotation title, subtitle and adds it to the map.
 This is called in querySpotsFromFirebase Function and the spots
 from Firebase are passed into it as an argument.
*/
 -(void)addSpotToMap:(Spot *)spot {
    Annotation *annotation = [Annotation initWithAnnotationSpot:spot coordinate:CLLocationCoordinate2DMake(spot.spotCoordinates.latitude, spot.spotCoordinates.longitude)];
    annotation.title = spot.user;
    annotation.subtitle = [NSString stringWithFormat:@"%@", spot.message];
    [_mapView addAnnotation:annotation];
}


#pragma mark Firebase Helper Method

//Queries ALL the spots from Firebase
-(void)querySpotsFromFirebase {
    FirebaseDatabaseService *firebaseDatabaseService = [FirebaseDatabaseService sharedInstance];
    [firebaseDatabaseService initWithReference];
    
    FIRDatabaseReference *spotRef = [firebaseDatabaseService.ref child:@"spots"];
    
    [spotRef observeEventType:FIRDataEventTypeChildAdded
        withBlock:^(FIRDataSnapshot *snapshot) {
            Spot *spot = [[Spot alloc]
                          initWithSpotCoordinates:CLLocationCoordinate2DMake([snapshot.value[@"latitude"] doubleValue], [snapshot.value[@"longitude"] doubleValue])
                          user:snapshot.value[@"username"]
                          createdAt:snapshot.value[@"createdAt"]];
            spot.message = snapshot.value[@"message"];
            
            [self addSpotToMap:spot];
        }];
}

#pragma mark Navigation:
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueToUserSpotCreationVC"]) {
        UserSpotCreationVC *destionationVC = [segue destinationViewController];
        
        /*
         Using the _quickSpotNavBarButton's tag to identify if the segue is being triggered by the button of the longPressGesture. This is used to set the coordinatesForCreatedSpot property on the destionationVC.
         */
        if (_quickSpotNavBarButton.tag == 1) {
            [destionationVC setCoordinatesForCreatedSpot:CLLocationCoordinate2DMake(_userLocation.center.latitude, _userLocation.center.longitude)];
        } else {
            [destionationVC setCoordinatesForCreatedSpot:_longPressCoordinates];
        }
    }
}


#pragma mark IBActions

/*
 Used to take the user's press on the screen and turn them into map coordinates.
 These are used to set the coordinatesForCreatedSpot property on the destionationVC.
*/
- (IBAction)longPressToGetCoordinates:(UILongPressGestureRecognizer *)sender {
    [_quickSpotNavBarButton setTag:0];
    _longPressGesture = sender;
    CGPoint touchPoint = [sender locationInView:self.mapView];
   _longPressCoordinates = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    [self handleLongPressGestures:sender];
    
}

//Changes the map's style from MKMapTypeStandard to MKMapTypeHybridFlyover and vice versa.
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

//Reset's the map's region to the user's current location.
- (IBAction)goBackToMyLocation:(id)sender {

    [_mapView setRegion:_userLocation animated:true];
    
}

/*
 When the annotation at the bottom center of the MapSpotMapVC is pressed it segues to the UserSpotCreationVC.
 In the prepareForSegue method this takes the user's current location
 in coordinates and sets the coordinatesForCreatedSpot property on the destionationVC (UserSpotCreationVC).
 */
- (IBAction)quickSpotButtonPressed:(id)sender {
    _quickSpotNavBarButton.tag = 1;
    [self performSegueWithIdentifier:@"segueToUserSpotCreationVC" sender:self];
}





@end
