//
//  User.h
//  MapSpot
//
//  Created by DetroitLabs on 6/2/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *profilePhotoDownloadURL;
@property (nonatomic, strong) NSString *backgroundProfilePhotoDownloadURL;
@property (nonatomic, strong) UIImage *profilePhoto;
@property (nonatomic, strong) UIImage *backgroundProfilePhoto;

-(instancetype)initWithUsername:(NSString *)username fullName:(NSString *)fullName email:(NSString *)email userId:(NSString *)userId;

@end
