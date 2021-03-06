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
    
    [self scrollToSelectedPhoto];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollToSelectedPhoto {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_passedIndex inSection:0];
    
    [UIView animateWithDuration:0
                     animations: ^{ [self.collectionView reloadData]; }
                     completion:^(BOOL finished) {
                         [_fullViewCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                     }];

}

-(BOOL)isImageLandscape:(UIImage *)image {
    if (image.size.width > image.size.height) {
        return TRUE;
    } else {
        return FALSE;
    }
}

-(UIImage *)rotateImage:(UIImage *)image {
    UIImage *newImage = [[UIImage alloc] initWithCGImage: image.CGImage
                                                   scale: 1.0
                                             orientation: UIImageOrientationRight];
    
    return newImage;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_spotMediaItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Photo *photo = _spotMediaItems[indexPath.item];

    UICollectionViewCell *cell = [_fullViewCollectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:300];
    
    [cellImageView setImageWithURL:[NSURL URLWithString:photo.downloadURL]];
    
    //Checks if the image is in landscape. if it is then rotate the image.
    
    if ([self isImageLandscape:cellImageView.image]) {
        UIImage *rotatedImage = [self rotateImage:cellImageView.image];
        cellImageView.contentMode = UIViewContentModeScaleAspectFit;
        cellImageView.image = rotatedImage;
    } else {
        cellImageView.contentMode = UIViewContentModeScaleAspectFill;
    }

    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_fullViewCollectionView.frame.size.width, _fullViewCollectionView.frame.size.height);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.navigationController.navigationBarHidden == TRUE) {
        self.navigationController.navigationBarHidden = FALSE;
    } else {
        self.navigationController.navigationBarHidden = TRUE;
    }
}

@end
