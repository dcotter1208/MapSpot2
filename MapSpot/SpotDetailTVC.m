//
//  SpotDetailVC.m
//  MapSpot
//
//  Created by DetroitLabs on 7/25/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "SpotDetailTVC.h"
#import "SpotMediaFullViewCVC.h"
#import "Photo.h"
#import "FirebaseOperation.h"
#import "UIImageView+AFNetworking.h"

@interface SpotDetailTVC () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundProfileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *username;

@property (nonatomic, strong) NSArray *spotPhotoArray;
@property (nonatomic, strong) FirebaseOperation *firebaseOperation;
@property (nonatomic) NSInteger indexOfSelectedCell;

@end

@implementation SpotDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _firebaseOperation = [[FirebaseOperation alloc]init];
    [self setSpotDetails];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews {
    _profileImageView.layer.borderWidth = 4.0;
    _profileImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
    _profileImageView.layer.cornerRadius = _profileImageView.layer.frame.size.height/2;
    _profileImageView.layer.masksToBounds = TRUE;
    _backgroundProfileImageView.layer.masksToBounds = TRUE;
    _username.layer.borderWidth = 1.0;
    _username.layer.masksToBounds = TRUE;
    _username.layer.cornerRadius = 8.0;
}

//Sets the spot's details.
-(void)setSpotDetails {
    
    _messageTextView.text = _spot.message;
    
    [self downloadSpotUserProfile:^(FIRDataSnapshot *snapshot) {
        
        for (FIRDataSnapshot *child in snapshot.children) {
            _username.text = child.value[@"username"];
            [_profileImageView setImageWithURL:[NSURL URLWithString:child.value[@"profilePhotoDownloadURL"]]];
            [_backgroundProfileImageView setImageWithURL:[NSURL URLWithString:child.value[@"backgroundProfilePhotoDownloadURL"]]];
        }
    }];

}

/*
 Downloads the displayed spot's user profile. 
 This contains the username and profile downloadURLs.
 */
-(void)downloadSpotUserProfile:(void(^)(FIRDataSnapshot *snapshot))completion {
    [_firebaseOperation queryFirebaseWithConstraintsForChild:@"users" queryOrderedByChild:@"userId" queryEqualToValue:_spot.userID andFIRDataEventType:FIRDataEventTypeValue observeSingleEventType:TRUE completion:^(FIRDataSnapshot *snapshot) {
        
        completion(snapshot);
    }];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_spot.spotImages count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    Photo *photo = _spot.spotImages[indexPath.item];
    
    UICollectionViewCell *cell = [_mediaCollectionView dequeueReusableCellWithReuseIdentifier:@"spotMediaCell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 10.0;

    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];

    cellImageView.layer.masksToBounds = TRUE;
    
    [cellImageView setImageWithURL:[NSURL URLWithString:photo.downloadURL]];
    
    return cell;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((_mediaCollectionView.frame.size.width/2)-10, (_mediaCollectionView.frame.size.width/2)-10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    _indexOfSelectedCell = indexPath.item;
    [self performSegueWithIdentifier:@"FullViewSegue" sender:self];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SpotMediaFullViewCVC *destionationVC = [segue destinationViewController];
    destionationVC.spotMediaItems = _spot.spotImages;
    destionationVC.passedIndex = _indexOfSelectedCell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}


@end
