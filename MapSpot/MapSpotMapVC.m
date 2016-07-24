//
//  ViewController.m
//  MapSpot
//
//  Created by DetroitLabs on 5/27/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "MapSpotMapVC.h"
#import "UserSpotCreationVC.h"
#import "MapAnnotationCallout.h"
#import "Spot.h"
#import "FirebaseOperation.h"
#import "Annotation.h"
#import "CurrentUser.h"
#import "Photo.h"
@import FirebaseAuth;
@import FirebaseDatabase;
@import MapKit;
@import CoreLocation;

@interface MapSpotMapVC () <MKMapViewDelegate, CLLocationManagerDelegate>

#pragma mark Outlets

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapStyleNavBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *quickSpotNavBarButton;
@property (nonatomic, strong) IBOutlet UILongPressGestureRecognizer *longPressGesture;

#pragma mark Properties

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *newestLocation;
@property(nonatomic) MKCoordinateRegion userLocation;
@property(nonatomic)CLLocationCoordinate2D longPressCoordinates;
@property(nonatomic, strong) MapAnnotationCallout *mapAnnotationCallout;
@property (nonatomic, strong) Annotation *selectedAnnotation;
@property (nonnull, strong) NSMutableArray *photoArray;

@end


@implementation MapSpotMapVC

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
    _mapAnnotationCallout = [[MapAnnotationCallout alloc]init];
    _photoArray = [[NSMutableArray alloc]init];
    [self checkForCurrentUserValue];
    [super viewDidLoad];
    [self querySpotsFromFirebase];
    [self mapSetup];
    [self setUpLongPressGesture];

}


-(void)viewDidDisappear:(BOOL)animated {
    [_mapAnnotationCallout removeFromSuperview];
    [_mapView deselectAnnotation:_selectedAnnotation animated:FALSE];
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

#pragma mark Map Actions Help Methods

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

-(void)showCustomMapCallout {
    _mapAnnotationCallout.backgroundColor = [UIColor whiteColor];
   _mapAnnotationCallout.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3);
    [self.view addSubview:_mapAnnotationCallout];
    //This is important otherwise the callout's collectionview won't reload.
     [_mapAnnotationCallout.mediaCollectionView reloadData];
}

-(void)setCustomMapCalloutAttributes:(Spot *)spot {
    _mapAnnotationCallout.previewImages = [[NSMutableArray alloc]initWithArray:spot.spotImages];
    _mapAnnotationCallout.usernameLabel.text = spot.user;
    _mapAnnotationCallout.messageTextView.text = spot.message;

}

//centers map when an annotation is selected. Called in didSelectAnnotation method.
-(void)centerMapOnSelectedAnnotation:(Annotation *)annotation {
    //Gets the current region of the mapView.
    MKCoordinateRegion currentRegion = _mapView.region;

    //sets the center of the current region to the selected annotation's coordinate so the map will center on that coordinate
    currentRegion.center = _selectedAnnotation.coordinate;
    
    //sets the map's region to the current region.
    [_mapView setRegion:currentRegion animated:true];
}

#pragma mark Firebase Helper Methods

/*
 Makes a call to the photos in the Firebase database based on which spot is passed in.
 It then obtains the downloadURLs from those photo objects and adds them to the spotImagesURLs array.
 */
-(void)queryPhotosFromFirebaseForSpot:(Spot *)spot {
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    
    [firebaseOperation queryFirebaseWithConstraintsForChild:@"photos" queryOrderedByChild:@"spot" queryEqualToValue:spot.spotReference andFIRDataEventType:FIRDataEventTypeChildAdded observeSingleEventType:FALSE completion:^(FIRDataSnapshot *snapshot) {

        Photo *photo = [[Photo alloc]initWithDownloadURL:snapshot.value[@"downloadURL"] andIndex:(int)snapshot.value[@"index"]];
        
        [spot.spotImages addObject:photo];
        
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        [spot.spotImages sortUsingDescriptors:[NSArray arrayWithObject:sorter]];

    }];

}

//Queries ALL the spots from Firebase
-(void)querySpotsFromFirebase {
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    [firebaseOperation queryFirebaseWithNoConstraintsForChild:@"spots" andFIRDataEventType:FIRDataEventTypeChildAdded completion:^(FIRDataSnapshot *snapshot) {
        Spot *spot = [[Spot alloc]
                      initWithSpotCoordinates:CLLocationCoordinate2DMake([snapshot.value[@"latitude"] doubleValue], [snapshot.value[@"longitude"] doubleValue])
                      user:snapshot.value[@"username"]
                      createdAt:snapshot.value[@"createdAt"]];
        spot.message = snapshot.value[@"message"];
        spot.spotReference = snapshot.value[@"spotReference"];
        
        [self queryPhotosFromFirebaseForSpot:spot];

        [self addSpotToMap:spot];
    }];
}

/*
 Checks if the CurrentUser singleton is already set.
 If it isn't then it calls 'getCurrentUserInfoFromFirebaseDatabaseWithCompletion',
 which then calls 'setCurrentUser' and sets the CurrentUser singleton.
 */
-(void)checkForCurrentUserValue {
    if ([CurrentUser sharedInstance].username == nil) {
        [self getCurrentUserProfileFromFirebase];
    }
}

/*
 Makes a Firebase query to get the currently logged in user's userprofile.
 It then calls the setCurrentUser function, which sets the CurrentUser singleton.
 */
-(void)getCurrentUserProfileFromFirebase {
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    
    [firebaseOperation queryFirebaseWithConstraintsForChild:@"users" queryOrderedByChild:@"userId" queryEqualToValue:[FIRAuth auth].currentUser.uid andFIRDataEventType:FIRDataEventTypeValue observeSingleEventType:TRUE completion:^(FIRDataSnapshot *snapshot) {
        [self setCurrentUser:snapshot];
    }];
}

//Sets the CurrentUser singleton
-(void)setCurrentUser:(FIRDataSnapshot *)snapshot {

    CurrentUser *currentUser = [CurrentUser sharedInstance];
    
    for (FIRDataSnapshot *child in snapshot.children) {
        [currentUser updateCurrentUser:child];
    }
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

#pragma mark MapKit Delegate Methods

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[Annotation class]]) {

        static NSString *const identifier = @"customAnnotation";
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

        if (annotationView) {
            annotationView.annotation = annotation;
        } else {
            annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:(identifier)];
        }
        annotationView.image = [UIImage imageNamed:@"pin"];
        annotationView.canShowCallout = FALSE;
        
        return annotationView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    _selectedAnnotation = view.annotation;
    
    if (![_selectedAnnotation isEqual: _mapView.userLocation]) {
        [self setCustomMapCalloutAttributes:_selectedAnnotation.spotAtAnnotation];
        [self.navigationController setNavigationBarHidden:TRUE];
        [self centerMapOnSelectedAnnotation:_selectedAnnotation];
        [self showCustomMapCallout];
    }
    
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    [self.navigationController setNavigationBarHidden:FALSE];
    [_mapAnnotationCallout removeFromSuperview];
    
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

-(IBAction)unwindToMapSpotMapVC:(UIStoryboardSegue *)segue {
    
}


@end
