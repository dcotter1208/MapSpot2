//
//  CurrentUser.m
//  MapSpot
//
//  Created by DetroitLabs on 7/11/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "CurrentUser.h"
#import "AFNetworking.h"

@implementation CurrentUser

+ (instancetype)sharedInstance {
    static CurrentUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CurrentUser alloc] initPrivately];
    });
    return sharedInstance;
}

- (instancetype)initPrivately {
    self = [super init];
    return self;
}

-(void)initWithUsername:(NSString *)username fullName:(NSString *)fullName email:(NSString *)email userId:(NSString *)userId {
    _username = username;
    _fullName = fullName;
    _email = email;
    _userId = userId;
}

-(void)updateCurrentUser:(FIRDataSnapshot *)snapshot {
    self.username = snapshot.value[@"username"];
    self.fullName = snapshot.value[@"fullName"];
    self.bio = snapshot.value[@"bio"];
    self.location = snapshot.value[@"location"];
    self.DOB = snapshot.value[@"DOB"];
    self.email = snapshot.value[@"email"];
    self.userId = snapshot.value[@"userId"];
    self.profilePhotoDownloadURL = snapshot.value[@"profilePhotoDownloadURL"];
    self.backgroundProfilePhotoDownloadURL = snapshot.value[@"backgroundProfilePhotoDownloadURL"];
    self.profileKey = snapshot.key;
    
    //WILL HAVE TO UPDATE PHOTOS AND URLS HERE TOO...
    
}

//Downloads the photo using AFNetworking. returns a UIImage in the completion handler.
-(void)downloadImageFromFirebaseWithAFNetworking:(NSString *)imageURL completion:(void(^)(UIImage *image))completion {
    NSURL *url = [NSURL URLWithString:imageURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    [manager GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, UIImage *responseData) {
        completion(responseData);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
