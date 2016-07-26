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
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (nonatomic, strong) NSArray *spotPhotoArray;
@property (nonatomic, strong) FirebaseOperation *firebaseOperation;
@property (nonatomic) NSInteger indexOfSelectedCell;

@end

@implementation SpotDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _firebaseOperation = [[FirebaseOperation alloc]init];
    [self setSpotDetails];
//    [self setupDataForEndlessScrollingCollectionView];
    
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

//Sets the spot's details.
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
    cell.layer.cornerRadius = cell.layer.frame.size.height/2;

    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];

    cellImageView.layer.masksToBounds = TRUE;
    
    [cellImageView setImageWithURL:[NSURL URLWithString:photo.downloadURL]];
    
    return cell;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_mediaCollectionView.frame.size.width/2, _mediaCollectionView.frame.size.width/2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
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

//-(void)setupDataForEndlessScrollingCollectionView {
//    Photo *firstPhoto = _spot.spotImages[0];
//    Photo *lastPhoto = [_spot.spotImages lastObject];
//
//    NSMutableArray *endlessScrollingArray = [_spot.spotImages mutableCopy];
//    [endlessScrollingArray insertObject:lastPhoto atIndex:0];
//    [endlessScrollingArray addObject:firstPhoto];
//
//    _spotPhotoArray = [NSArray arrayWithArray:endlessScrollingArray];
//
//}


//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(0, 5, 0, 5);
//}

//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    // Calculate where the collection view should be at the right-hand end item
//    float contentOffsetWhenFullyScrolledRight = _mediaCollectionView.frame.size.width/2 * ([_spotPhotoArray count] - 1);
//    
//    if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
//        // user is scrolling to the right from the last item to the 'fake' item 1.
//        // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
//         NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
//        [_mediaCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
//    } else if (scrollView.contentOffset.x == 0) {
//        // user is scrolling to the left from the first item to the fake 'item N'.
//        // reposition offset to show the 'real' item N at the right end end of the collection view
//        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([_spotPhotoArray count] -2) inSection:0];
//        [_mediaCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
//    }
//}


@end
