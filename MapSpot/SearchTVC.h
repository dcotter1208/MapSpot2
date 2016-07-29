//
//  SearchTVC.h
//  MapSpot
//
//  Created by DetroitLabs on 7/28/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SearchTVC : UITableViewController <UISearchResultsUpdating>

@property (nonatomic, strong) NSArray *matchingSearchItems;
@property (nonatomic, strong) MKMapView *mapView;

@end
