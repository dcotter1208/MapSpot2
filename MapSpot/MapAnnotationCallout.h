//
//  MapAnnotationCallout.h
//  MapSpot
//
//  Created by DetroitLabs on 7/14/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaPreviewCell.h"

@protocol CustomCalloutDelegate <NSObject>

-(void)moreButtonPressed:(id)sender;
-(void)likeButtonPressed:(id)sender;

@end

@interface MapAnnotationCallout : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;
@property (nonatomic, strong) NSMutableArray *previewImages;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;

@property(nonatomic, weak) id<CustomCalloutDelegate>delegate;

@end
