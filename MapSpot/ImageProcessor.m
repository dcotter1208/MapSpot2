//
//  ImageProcessor.m
//  MapSpot
//
//  Created by DetroitLabs on 7/25/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "ImageProcessor.h"

@implementation ImageProcessor
/*
 Reduces the image's size. If the size to scale down to is the size of
 the original image then just return the original image.
 */
-(UIImage *)scaleImage:(UIImage*)originalImage ToSize:(CGSize)size {
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size)) {
        return originalImage;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

//converts an image to NSData
-(NSData *)convertImageToNSData:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    return imageData;
}

//Accepts a PHAsset and gets the UIImage from it.
-(void)getImageFromPHAsset:(PHAsset *)asset withPHImageManager:(PHImageManager *)manager andTargetSize:(CGSize)targetSize andContentMode:(PHImageContentMode)contentMode andRequestOptions:(PHImageRequestOptions *)requestOptions completion:(void(^)(UIImage *image))completion{
    [manager requestImageForAsset:asset
                        targetSize:targetSize
                       contentMode:contentMode
                           options:requestOptions
                     resultHandler:^(UIImage *result, NSDictionary *info) {
                         completion(result);
                     }];
}

@end
