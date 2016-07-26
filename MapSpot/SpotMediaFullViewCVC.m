//
//  SpotMediaFullViewCVC.m
//  MapSpot
//
//  Created by DetroitLabs on 7/26/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "SpotMediaFullViewCVC.h"
#import "Photo.h"
#import "UIImageView+AFNetworking.h"

@interface SpotMediaFullViewCVC ()
@property (strong, nonatomic) IBOutlet UICollectionView *fullViewCollectionView;

@end

@implementation SpotMediaFullViewCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Spot Images: %@", _spotMediaItems.description);
    NSLog(@"Passed Index: %lu", _passedIndex);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_spotMediaItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Photo *photo = _spotMediaItems[indexPath.item];

    UICollectionViewCell *cell = [_fullViewCollectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:300];
    
    NSLog(@"IMAGEVIEW TAG: %lu", cellImageView.tag);
    
    [cellImageView setImageWithURL:[NSURL URLWithString:photo.downloadURL]];

    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
