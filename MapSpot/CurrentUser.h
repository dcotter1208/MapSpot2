//
//  CurrentUser.h
//  MapSpot
//
//  Created by DetroitLabs on 7/11/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CurrentUser : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *DOB;
@property (nonatomic, strong) NSString *profilePhotoDownloadURL;
@property (nonatomic, strong) NSString *backgroundProfilePhotoDownloadURL;
@property (nonatomic, strong) UIImage *profilePhoto;
@property (nonatomic, strong) UIImage *backgroundProfilePhoto;
@property (nonatomic, strong) NSString *profileKey;

-(void)initWithUsername:(NSString *)username fullName:(NSString *)fullName email:(NSString *)email userId:(NSString *)userId;

+(instancetype)sharedInstance;

@end
