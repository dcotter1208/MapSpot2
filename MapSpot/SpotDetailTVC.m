//
//  SpotDetailVC.m
//  MapSpot
//
//  Created by DetroitLabs on 7/25/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "SpotDetailTVC.h"
#import "Photo.h"
#import "FirebaseOperation.h"
#import "UIImageView+AFNetworking.h"

@interface SpotDetailTVC () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundProfileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (nonatomic, strong) FirebaseOperation *firebaseOperation;

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
    _usernameLabel.layer.borderWidth = 1.0;
    _usernameLabel.layer.masksToBounds = TRUE;
    _usernameLabel.layer.cornerRadius = 8.0;
}

-(void)setSpotDetails {
    
    _messageTextView.text = _spot.message;
    
    [self downloadSpotUserProfile:^(FIRDataSnapshot *snapshot) {
        
        for (FIRDataSnapshot *child in snapshot.children) {
            _usernameLabel.text = child.value[@"username"];
            [_profileImageView setImageWithURL:[NSURL URLWithString:child.value[@"profilePhotoDownloadURL"]]];
            [_backgroundProfileImageView setImageWithURL:[NSURL URLWithString:child.value[@"backgroundProfilePhotoDownloadURL"]]];
        }
    }];

}

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
    
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    
    [cellImageView setImageWithURL:[NSURL URLWithString:photo.downloadURL] placeholderImage:[UIImage imageNamed: @"placeholder"]];
    
    return cell;
    
}


@end
