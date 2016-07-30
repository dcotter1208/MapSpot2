//
//  ViewController.m
//  MapSpot
//
//  Created by DetroitLabs on 5/27/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "MapSpotMapVC.h"
#import "SearchTVC.h"
#import "UserSpotCreationVC.h"
#import "SpotDetailTVC.h"
#import "MapAnnotationCallout.h"
#import "Spot.h"
#import "Like.h"
#import "FirebaseOperation.h"
#import "AFNetworkingOp.h"
#import "Annotation.h"
#import "CurrentUser.h"
#import "Photo.h"
#import "UIImageView+AFNetworking.h"
@import FirebaseAuth;
@import FirebaseDatabase;
@import MapKit;
@import CoreLocation;

@interface MapSpotMapVC () <MKMapViewDelegate, CLLocationManagerDelegate>

#pragma mark Outlets

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapStyleNavBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *quickSpotNavBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapModeBarItemLabel;
@property (nonatomic, strong) IBOutlet UILongPressGestureRecognizer *longPressGesture;

#pragma mark Properties

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *newestLocation;
@property(nonatomic) MKCoordinateRegion userLocation;
@property(nonatomic)CLLocationCoordinate2D longPressCoordinates;
@property(nonatomic, strong) MapAnnotationCallout *mapAnnotationCallout;
@property (nonatomic, strong) Annotation *selectedAnnotation;
@property (nonnull, strong) NSMutableArray *photoArray;
@property (nonatomic) BOOL spotLikedByCurrentUser;
@property(nonatomic, strong) NSString *likeToBeRemovedKey;
@property(nonatomic, strong) NSMutableArray *likeUserIDArray;
@property(nonatomic, strong) UISearchController *resultSearchController;
@property(nonatomic, strong) MKPlacemark *selectedPlace;

@end
SearchTVC *searchTVC;

@implementation MapSpotMapVC

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
    _mapAnnotationCallout = [[MapAnnotationCallout alloc]init];
    [_mapAnnotationCallout setDelegate:self];
    _photoArray = [[NSMutableArray alloc]init];
    [self checkForCurrentUserValue];
    [super viewDidLoad];
    [self querySpotsFromFirebase];
    [self mapSetup];
    [self setUpLongPressGesture];
    
    _likeUserIDArray = [[NSMutableArray alloc]init];
    
    searchTVC = [[SearchTVC alloc]init];
    [self istantiateSearchTable];
    [self configureSearchBar];
        
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

-(void)istantiateSearchTable{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SearchTVC *searchTable = (SearchTVC *)[storyboard instantiateViewControllerWithIdentifier:@"SearchTVC"];
    [searchTable setDelegate:self];
    searchTable.mapView = _mapView;
    _resultSearchController = [[UISearchController alloc] initWithSearchResultsController:searchTable];
    _resultSearchController.searchResultsUpdater = searchTable;

}

-(void)configureSearchBar {
    UISearchBar *searchBar = _resultSearchController.searchBar;
    [searchBar sizeToFit];
    searchBar.placeholder = @"Search For Places";
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.navigationItem.titleView = _resultSearchController.searchBar;
    _resultSearchController.hidesNavigationBarDuringPresentation = FALSE;
    _resultSearchController.dimsBackgroundDuringPresentation = TRUE;
    self.definesPresentationContext = TRUE;
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

-(void)dropPinForSelectedPlace:(MKPlacemark *)placemark {
    _selectedPlace = placemark;
    MKPointAnnotation *selectedPlaceAnnotation = [[MKPointAnnotation alloc]init];
    selectedPlaceAnnotation.coordinate = placemark.coordinate;
    [_mapView addAnnotation:selectedPlaceAnnotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 500.0, 500.0);
    [_mapView setRegion:region animated:TRUE];
}

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
    [_mapView addAnnotation:annotation];
}

/*
 Presents the custom callout when an annotation is selected.
 This is called in the didSelectAnnotationView method.
 */
-(void)showCustomMapCallout {
    _mapAnnotationCallout.backgroundColor = [UIColor whiteColor];
   _mapAnnotationCallout.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2.5);
    [self.view addSubview:_mapAnnotationCallout];
    //This is important otherwise the callout's collectionview won't reload.
     [_mapAnnotationCallout.mediaCollectionView reloadData];
}

//Sets the custom callout's attributes such as the username label, message and collectionView's datasource.
-(void)setCustomMapCalloutAttributes:(Spot *)spot {

    _mapAnnotationCallout.previewImages = [[NSMutableArray alloc]initWithArray:spot.spotImages];
    _mapAnnotationCallout.messageTextView.text = spot.message;
    
    [self downloadSpotUserProfileForSpot:spot withCompletion:^(FIRDataSnapshot *snapshot) {
        
        for (FIRDataSnapshot *child in snapshot.children) {
            _mapAnnotationCallout.usernameLabel.text = child.value[@"username"];
            [_mapAnnotationCallout.userProfileImageView setImageWithURL:[NSURL URLWithString:child.value[@"profilePhotoDownloadURL"]]];
        }
    }];
    
    [self setLikeButton];

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

#pragma mark Networking Methods
/*
 Downloads the userprofile information to display in the callout.
 The userprofile contains the username and downloadURLs for the profile photos.
 */
-(void)downloadSpotUserProfileForSpot:(Spot *)spot withCompletion:(void(^)(FIRDataSnapshot *snapshot))completion {
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];

    [firebaseOperation queryFirebaseWithConstraintsForChild:@"users" queryOrderedByChild:@"userId" queryEqualToValue:spot.userID andFIRDataEventType:FIRDataEventTypeValue observeSingleEventType:TRUE completion:^(FIRDataSnapshot *snapshot) {
        
        completion(snapshot);
    }];
}

//Accepts a current user as an argument and then sets the profile photos for the current user.
-(void)setProfilePhotosForCurrentUser:(CurrentUser *)currentUser {
    
    AFNetworkingOp *afnetworkingOp = [[AFNetworkingOp alloc]init];
    
    [afnetworkingOp downloadImageFromFirebaseWithAFNetworking:currentUser.profilePhotoDownloadURL completion:^(UIImage *image) {
        currentUser.profilePhoto = image;
    }];
    [afnetworkingOp downloadImageFromFirebaseWithAFNetworking:currentUser.backgroundProfilePhotoDownloadURL completion:^(UIImage *image) {
        currentUser.backgroundProfilePhoto = image;
    }];
}

/*
 ************************************************************
 Called in setCustomMapCalloutAttributes to set the likeButton
 and to start detecting likes being added and removed.
 ************************************************************
 1) Checks if there are any likes for the spot.
    If there aren't any likes yet (no snapshot) then likes count label
    is set to "0 likes" the heart is black ('unLike').
 2) If a snapshot exists then query the likes (detectLikeAdded).
 3) Call detectLikeRemove to start detecting when likes are removed.
 */
-(void)setLikeButton {
    
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    // (1)
    [firebaseOperation queryFirebaseWithConstraintsForChild:@"likes" queryOrderedByChild:@"spotReference" queryEqualToValue:_selectedAnnotation.spotAtAnnotation.spotReference andFIRDataEventType:FIRDataEventTypeValue observeSingleEventType:TRUE completion:^(FIRDataSnapshot *snapshot) {

        if (!snapshot.exists) {
            _mapAnnotationCallout.likeCountLabel.text = @"0 likes";
            [_mapAnnotationCallout.likeButton setImage:[UIImage imageNamed:@"unLike"] forState:UIControlStateNormal];
        }
    }];
    // (2)
    [self detectLikeAdded:firebaseOperation];
    [self detectLikeRemoved:firebaseOperation];
    
}

/*
 ****************************************
 Detects when a like is added to Firebase.
 ****************************************
 1) If a like is added then the whole snapshot is added to an NSArray (snapshotArray).
 2) This array is looped through and a string for the value of userID is created (NSString *userID)
 3) If a userID is not in the _likeUserIDArray then it is added to the _likeUserIDArray.
 4) If the snapshot's value for "userID" is equaled to the current user's userId then the
    _likeToBeRemovedKey(NSString) is assigned that snapshot's key. The key is referring to the child node key (childByAutoID)
    and is used to remove the like from Firebase if the current user unlikes that spot.
 5) The callout's like label is then set to the count of _likeUserIDArray.
 6) If the _likeUserIDArray contains the current user's userID then the callout's
    like button (heart) is set to 'like', which is the red heart. Then the BOOL '_spotLikedByCurrentUser' is set to TRUE.
    This BOOL is determine if a like is removed from Firebase in the 'likeButtonPressed' function.
 
 */
-(void)detectLikeAdded:(FirebaseOperation *)firebaseOperation {
    
    [firebaseOperation queryFirebaseWithConstraintsForChild:@"likes" queryOrderedByChild:@"spotReference" queryEqualToValue:_selectedAnnotation.spotAtAnnotation.spotReference andFIRDataEventType:FIRDataEventTypeChildAdded observeSingleEventType:FALSE completion:^(FIRDataSnapshot *snapshot) {
        // (1)
        NSArray *snapshotArray = [NSArray arrayWithObject:snapshot];
        
        // (2)
        for (FIRDataSnapshot *snap in snapshotArray) {
            NSString *userID = snap.value[@"userID"];
            // (3)
            if (![_likeUserIDArray containsObject:userID]) {
                [_likeUserIDArray addObject:userID];
                // (4)
                if ([snap.value[@"userID"] isEqualToString:[CurrentUser sharedInstance].userId]) {
                    _likeToBeRemovedKey = snap.key;
                }
            }
        }
        // (5)
        _mapAnnotationCallout.likeCountLabel.text = [NSString stringWithFormat:@"%lu likes", _likeUserIDArray.count];
        // (6)
        if ([_likeUserIDArray containsObject:[CurrentUser sharedInstance].userId]) {
            [_mapAnnotationCallout.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
            _spotLikedByCurrentUser = TRUE;
        }
    }];
}
/*
 ******************************************
 Detects if a like is removed from Firebase.
 ******************************************
 1) If a like is removed from Firebase it returns the snapshot of the removed like.
 2) If the _likeUserIDArray contains the snapshot.value[@"userID"],
    meaning the like that was removed has a userID in that _likeUserIDArray, then remove it from the _likeUserIDArray.
 3) The callout's like label is then set to the count of _likeUserIDArray.
 4) If the the removed like's snapshot's value for userID is equaled to the current user's userID then
    change the like image to 'unLike' (black heart) and then the BOOL '_spotLikeByCurrentUser' is set to FALSE.
    '_spotLikeByCurrentUser' is used to determine if a like is removed from Firebase in the 'likeButtonPressed' function.
 
 */
-(void)detectLikeRemoved:(FirebaseOperation *)firebaseOperation {
    // (1)
    [firebaseOperation queryFirebaseWithConstraintsForChild:@"likes" queryOrderedByChild:@"spotReference" queryEqualToValue:_selectedAnnotation.spotAtAnnotation.spotReference andFIRDataEventType:FIRDataEventTypeChildRemoved observeSingleEventType:FALSE completion:^(FIRDataSnapshot *snapshot) {
        // (2)
        if ([_likeUserIDArray containsObject:snapshot.value[@"userID"]]) {
            [_likeUserIDArray removeObject:snapshot.value[@"userID"]];
            // (3)
            _mapAnnotationCallout.likeCountLabel.text = [NSString stringWithFormat:@"%lu likes", _likeUserIDArray.count];
            if ([snapshot.value[@"userID"] isEqualToString:[CurrentUser sharedInstance].userId]) {
                [_mapAnnotationCallout.likeButton setImage:[UIImage imageNamed:@"unLike"] forState:UIControlStateNormal];
                _spotLikedByCurrentUser = FALSE;
            }
        }
    }];
    
//    FIRDatabaseReference *likesRef = [firebaseOperation.firebaseDatabaseService.ref child:@"likes"];
//    FIRDatabaseQuery *query = [[likesRef queryOrderedByChild:@"spotReference"]queryEqualToValue:_selectedAnnotation.spotAtAnnotation.spotReference];
//    // (1)
//    [query observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot) {
//
//    }];
}

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
                      userID:snapshot.value[@"userId"]
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
        [self setProfilePhotosForCurrentUser:currentUser];
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
    } else if ([segue.identifier isEqualToString:@"segueToSpotDetailVC"]){
        SpotDetailTVC *destionationVC = [segue destinationViewController];
        destionationVC.spot = _selectedAnnotation.spotAtAnnotation;
    }
}

#pragma mark MapKit Delegate Methods

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else if ([annotation isKindOfClass:[Annotation class]]) {

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
    } else {
        MKAnnotationView *searchedLocation = [_mapView dequeueReusableAnnotationViewWithIdentifier:@"searchedLocationAnnotation"];
        searchedLocation = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"searchedLocationAnnotation"];
        searchedLocation.annotation = annotation;
        searchedLocation.image = [UIImage imageNamed:@"pin"];
        return searchedLocation;
        
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    _selectedAnnotation = view.annotation;
    
    if (![_selectedAnnotation isEqual: _mapView.userLocation] && [_selectedAnnotation isKindOfClass:[Annotation class]]) {
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

//more button on callout pressed.
-(void)moreButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"segueToSpotDetailVC" sender:self];
}

/*
 ****************************************************
 This is the protocol defined in MapAnnotationCallout.
 ****************************************************
 
 IF:
 1) If the BOOL '_spotLikedByCurrentUser' is TRUE then
    remove the like from Firebase with the key assigned to _likeToBeRemovedKey (this is the key for the current user's like).
    This is done by calling the FirebaseOperation method 'removeChildNode'.
 2) Set the callout's like button's image to 'unLike'(black heart).
 3) Set the _spotLikeByCurrentUser from TRUE to FALSE - because the spot is no longer liked by the current user.
 
 ELSE:
 1) Else set the _spotLikedByCurrentUser to TRUE - because now the spot is liked by the CurrentUser.
 2) Create an instance of Like with a random likeID (generated in custom init method using NSUUID),
    spotReference (current spot's reference) and the userID (current user's userID).
 3) Send this like to Firebase by calling the FIrebaseOperation method 'setValueForFirebaseChild'.
 4) Set the callout's like button's image to 'like'(red heart).
 */
-(void)likeButtonPressed:(id)sender {
    
    FirebaseOperation *firebaseOperation = [[FirebaseOperation alloc]init];
    
    // (1)
    if (_spotLikedByCurrentUser) {
        [firebaseOperation removeChildNode:@"likes" nodeChildKey:_likeToBeRemovedKey];
        // (2)
        [_mapAnnotationCallout.likeButton setImage:[UIImage imageNamed:@"unLike"] forState:UIControlStateNormal];
        // (3)
        _spotLikedByCurrentUser = FALSE;
    } else {
        // (1)
        _spotLikedByCurrentUser = TRUE;

        // (2)
        Like *like = [[Like alloc]initWithUserID:[CurrentUser sharedInstance].userId andSpotReference:_selectedAnnotation.spotAtAnnotation.spotReference];

        NSDictionary *spotDict = @{@"likeID": like.likeID,
                                   @"spotReference": like.spotReference,
                                   @"userID": like.userID};
        // (3)
        [firebaseOperation setValueForFirebaseChild:@"likes" value:spotDict];
        
        // (4)
        [_mapAnnotationCallout.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }

}

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
        _mapStyleNavBarButton.image = [UIImage imageNamed:@"map"];
        _mapModeBarItemLabel.title = @"";
    } else {
        [_mapView setMapType:MKMapTypeStandard];
        _mapStyleNavBarButton.image = [UIImage imageNamed:@"3DCube"];
        _mapModeBarItemLabel.title = @"3D";
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
