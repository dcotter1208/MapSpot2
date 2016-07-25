//
//  ImageProcessor.h
//  MapSpot
//
//  Created by DetroitLabs on 7/25/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import Photos;

@interface ImageProcessor : NSObject

-(UIImage *)scaleImage:(UIImage*)originalImage ToSize:(CGSize)size;

-(NSData *)convertImageToNSData:(UIImage *)image;

-(void)getImageFromPHAsset:(PHAsset *)asset withPHImageManager:(PHImageManager *)manager andTargetSize:(CGSize)targetSize andContentMode:(PHImageContentMode)contentMode andRequestOptions:(PHImageRequestOptions *)requestOptions completion:(void(^)(UIImage *image))completion;



@end
