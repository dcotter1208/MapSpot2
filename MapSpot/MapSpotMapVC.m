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
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface MapSpotMapVC () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapStyleNavBarButton;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;

@end

CLLocation *newLocation, *oldLocation;
MKCoordinateRegion userLocation;
CLLocationCoordinate2D longPressCoordinates;

@implementation MapSpotMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self querySpotsFromFirebase];
    [self mapSetup];
    [self setUpLongPressGesture];
    [self checkIfCurrentUserIsLoggedIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mapSetup {
    [_mapView setDelegate:self];
    [_mapView setShowsPointsOfInterest:false];
    [_mapView setMapType:MKMapTypeHybridFlyover];
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
    
    userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 300.0, 300.0);
    [_mapView setRegion:userLocation animated:YES];
    
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender {
    if ([sender isEqual:_longPressGesture]) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            [self performSegueWithIdentifier:@"segueToUserSpotCreationVC" sender:self];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToUserSpotCreationVC"]) {
        UserSpotCreationVC *destionationVC = [segue destinationViewController];
        [destionationVC setDelegate:self];
        [destionationVC setCoordinatesForCreatedSpot:longPressCoordinates];
    }
}


-(void)createSpotWithUser:(NSString *)user message:(NSString *)message coordinates:(CLLocationCoordinate2D)coordinates createdAt:(NSDate *)createdAt {
    
    //WE WILL ADD THE ANNOTATION WITH THE LISTENER METHOD THAT FIREBASE PROVIDES...ONCE A CHILD IS ADDED THEN WE WILL CALL THE "addAnnotation" method.
    
    Spot *spot = [Spot initWithSpotCoordinates:CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude) user:user createdAt:createdAt];
    spot.message = message;
    NSLog(@"Spot: User: %@, Message: %@, CreatedAt: %@", spot.user, spot.message, spot.createdAt);
    
}


-(void)setUpLongPressGesture {
    _longPressGesture.minimumPressDuration = 2;
    _longPressGesture.allowableMovement = 100.0f;
}

-(void)checkIfCurrentUserIsLoggedIn {
    FIRUser *user = [FIRAuth auth].currentUser;
    
    if (user != nil) {
        NSLog(@"CURRENT USER: %@", user.email);
    } else {
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
    }
}

-(void)querySpotsFromFirebase {
    FBDataService *fbDataService = [[FBDataService alloc]init];
    FIRDatabaseReference *spotRef = [fbDataService.ref child:@"spots"];

    [spotRef observeEventType:FIRDataEventTypeChildAdded
     withBlock:^(FIRDataSnapshot *snapshot) {
         NSDate *createdAt = [self convertStringToDate:snapshot.value[@"createdAt"]];
         
         Spot *spot = [[Spot alloc]
                    initWithSpotCoordinates:CLLocationCoordinate2DMake([snapshot.value[@"latitude"] doubleValue], [snapshot.value[@"longitude"] doubleValue])
                         user:snapshot.value[@"username"]
                         createdAt:createdAt];
         spot.message = snapshot.value[@"message"];
         
         [self addSpotToMap:spot];

     }];
}

-(void)addSpotToMap:(Spot *)spot {
    Annotation *annotation = [Annotation initWithAnnotationSpot:spot coordinate:CLLocationCoordinate2DMake(spot.spotCoordinates.latitude, spot.spotCoordinates.longitude)];
    annotation.title = spot.user;
    annotation.subtitle = (NSString *)spot.createdAt;
    [_mapView addAnnotation:annotation];
}

-(NSDate *)convertStringToDate:(NSString *)dateAsString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:dateAsString];
    
    return date;
}

- (IBAction)longPressToGetCoordinates:(UILongPressGestureRecognizer *)sender {
    _longPressGesture = sender;

    CGPoint touchPoint = [sender locationInView:self.mapView];
    longPressCoordinates = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    [self handleLongPressGestures:sender];
    
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

    [_mapView setRegion:userLocation animated:true];
    
}



@end
