//
//  FullImageVC.m
//  MapSpot
//
//  Created by DetroitLabs on 7/26/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "FullImageVC.h"
#import "ImageProcessor.h"

@interface FullImageVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) PHImageManager *manager;

@end

@implementation FullImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _manager = [[PHImageManager alloc] init];
    [self setImageViewWithImageOrAsset];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(PHImageRequestOptions *)setPHImageRequestOptions {
    PHImageRequestOptions *fetchOptions = [[PHImageRequestOptions alloc]init];
    fetchOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    fetchOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    return fetchOptions;
}

-(void)setImageViewWithImageOrAsset {
    if (_imageIsPHAsset) {
        
        PHImageRequestOptions *requestOptions = [self setPHImageRequestOptions];
        
        ImageProcessor *imageProcessor = [[ImageProcessor alloc]init];
        [imageProcessor getImageFromPHAsset:_passedAsset withPHImageManager:_manager andTargetSize:PHImageManagerMaximumSize andContentMode:PHImageContentModeAspectFill andRequestOptions:requestOptions completion:^(UIImage *image) {
            _imageView.image = image;
        }];
    } else {
        _imageView.image = _passedImage;
    }
}


- (IBAction)dismissView:(id)sender {
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}



@end
