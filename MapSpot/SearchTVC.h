//
//  SearchTVC.h
//  MapSpot
//
//  Created by DetroitLabs on 7/28/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol HandleMapSearchDelegate <NSObject>

-(void)dropPinForSelectedPlace:(MKPlacemark *)placemark;

@end

@interface SearchTVC : UITableViewController <UISearchResultsUpdating>


@property (nonatomic, strong) NSArray *matchingSearchItems;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, weak) id<HandleMapSearchDelegate>delegate;

@end
