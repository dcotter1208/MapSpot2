//
//  MapAnnotationCallout.m
//  MapSpot
//
//  Created by DetroitLabs on 7/14/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "MapAnnotationCallout.h"

@implementation MapAnnotationCallout

-(id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {

        [[NSBundle mainBundle]loadNibNamed:@"MapAnnotationCalloutView" owner:self options:nil];
        
        [_mediaCollectionView registerNib:[UINib nibWithNibName:@"MediaPreviewCell" bundle:nil] forCellWithReuseIdentifier:@"mediaCell"];
        
        _mediaCollectionView.backgroundColor = [UIColor clearColor];
        
        
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

}

#pragma mark : Collection View Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_previewImages count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(65, 65);
}

- (MediaPreviewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MediaPreviewCell *cell = [_mediaCollectionView dequeueReusableCellWithReuseIdentifier:@"mediaCell" forIndexPath:indexPath];
    
     UIImageView *mediaImageView = (UIImageView *)[cell viewWithTag:100];

    mediaImageView.image = [_previewImages objectAtIndex:indexPath.item];
    
    return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
