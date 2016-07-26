//
//  FullImageVC.h
//  MapSpot
//
//  Created by DetroitLabs on 7/26/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@interface FullImageVC : UIViewController

@property(nonatomic, strong) UIImage *passedImage;
@property(nonatomic, strong) PHAsset *passedAsset;
@property(nonatomic) BOOL imageIsPHAsset;

@end
