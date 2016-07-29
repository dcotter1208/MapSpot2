//
//  SearchTVC.m
//  MapSpot
//
//  Created by DetroitLabs on 7/28/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "SearchTVC.h"


@interface SearchTVC ()

@end

@implementation SearchTVC

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchBarText = searchController.searchBar.text;
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.naturalLanguageQuery = searchBarText;
    request.region = _mapView.region;
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        _matchingSearchItems = response.mapItems;

        [self.tableView reloadData];
    }];
}

-(NSString *)parseAddress:(MKPlacemark *)selectedItem {
    NSDictionary *searchDict = [selectedItem addressDictionary];
    NSString *street = [searchDict objectForKey:@"Street"];
    NSString *city = [searchDict objectForKey:@"City"];
    NSString *state = [searchDict objectForKey:@"State"];
    NSString *countryCode = [searchDict objectForKey:@"CountryCode"];
    
    NSString *fullAddress = [NSString stringWithFormat:@"%@, %@, %@, %@", street, city, state, countryCode];
    
    return fullAddress;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_matchingSearchItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    MKMapItem *selectedItem = _matchingSearchItems[indexPath.row];

    cell.textLabel.text = selectedItem.placemark.name;
    cell.detailTextLabel.text = [self parseAddress:selectedItem.placemark];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKMapItem *selectedItem = [_matchingSearchItems objectAtIndex:indexPath.row];
    [self dismissViewControllerAnimated:TRUE completion:nil];
    [self.delegate dropPinForSelectedPlace:selectedItem.placemark];
    
    NSLog(@"SELECTED ITEM: %f, %f", selectedItem.placemark.coordinate.latitude, selectedItem.placemark.coordinate.latitude);
}


@end
