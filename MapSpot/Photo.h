//
//  Photo.h
//  MapSpot
//
//  Created by DetroitLabs on 7/23/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spot.h"

@interface Photo : NSObject

@property (nonatomic, strong) NSString *downloadURL;
@property (nonatomic) int index;
@property (nonatomic, strong) NSString *photoReference;
@property (nonatomic, strong) NSString *spotReference;

-(instancetype)initWithDownloadURL:(NSString *)downloadURL andIndex:(int)index;



@end
