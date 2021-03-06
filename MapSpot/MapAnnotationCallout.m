//
//  MapAnnotationCallout.m
//  MapSpot
//
//  Created by DetroitLabs on 7/14/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "MapAnnotationCallout.h"
#import "UIImageView+AFNetworking.h"
#import "Photo.h"

@implementation MapAnnotationCallout

-(id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {

        [[NSBundle mainBundle]loadNibNamed:@"MapAnnotationCalloutView" owner:self options:nil];
        
        [_mediaCollectionView registerNib:[UINib nibWithNibName:@"MediaPreviewCell" bundle:nil] forCellWithReuseIdentifier:@"mediaCell"];
        
        _mediaCollectionView.backgroundColor = [UIColor clearColor];
        _view.layer.borderColor = [[UIColor grayColor]CGColor];
        _view.layer.borderWidth = 1.0;
        self.layer.backgroundColor = [[UIColor clearColor]CGColor];
        
        self.bounds = _view.bounds;
        
        [self addSubview:_view];
       
    }
    return self;
}

-(void)layoutSubviews {
    _userProfileImageView.layer.cornerRadius = _userProfileImageView.layer.frame.size.height/2;
    _userProfileImageView.layer.borderWidth = 1.0;
    _userProfileImageView.layer.borderColor = [[UIColor blackColor]CGColor];
    _userProfileImageView.layer.masksToBounds = TRUE;
    _messageTextView.layer.borderWidth = 1.0;
    _messageTextView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    _messageTextView.layer.cornerRadius = 10.0;
}

#pragma mark : Collection View Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_previewImages count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = _mediaCollectionView.frame.size.height;

    return CGSizeMake(cellHeight, cellHeight);
}

- (MediaPreviewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MediaPreviewCell *cell = [_mediaCollectionView dequeueReusableCellWithReuseIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.clipsToBounds = TRUE;
    Photo *photo = _previewImages[indexPath.item];
    
    UIImageView *mediaImageView = (UIImageView *)[cell viewWithTag:100];
    mediaImageView.layer.masksToBounds = TRUE;
    
    [mediaImageView setImageWithURL:[NSURL URLWithString:photo.downloadURL]];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if ([_previewImages count] <= 4) {
        _mediaCollectionView.scrollEnabled = FALSE;
        NSInteger viewWidth = _mediaCollectionView.frame.size.width;
        NSInteger totalCellWidth = _mediaCollectionView.frame.size.height * [_previewImages count];
        NSInteger totalSpacingWidth = 10 * (_previewImages.count -1);
        NSInteger leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2;
        NSInteger rightInset = leftInset;
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    } else {
        _mediaCollectionView.scrollEnabled = TRUE;
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate performSegueWithIdentifier];
}


- (IBAction)moreButtonPressed:(id)sender {
    [self.delegate moreButtonPressed:self];
}

- (IBAction)likeButtonPressed:(id)sender {
    [self.delegate likeButtonPressed:self];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
