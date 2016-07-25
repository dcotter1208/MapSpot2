//
//  SpotDetailVC.m
//  MapSpot
//
//  Created by DetroitLabs on 7/25/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "SpotDetailTVC.h"
#import "Photo.h"
#import "UIImageView+AFNetworking.h"

@interface SpotDetailTVC () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundProfileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;

@end

@implementation SpotDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setSpotDetails {
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_spot.spotImages count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    Photo *photo = _spot.spotImages[indexPath.item];
    
    UICollectionViewCell *cell = [_mediaCollectionView dequeueReusableCellWithReuseIdentifier:@"spotMediaCell" forIndexPath:indexPath];
    
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    
    [cellImageView setImageWithURL:[NSURL URLWithString:photo.downloadURL] placeholderImage:[UIImage imageNamed: @"placeholder"]];
    
    return cell;
    
}


@end
