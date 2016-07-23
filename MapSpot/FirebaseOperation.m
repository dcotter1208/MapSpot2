//
//  FirebaseOperation.m
//  MapSpot
//
//  Created by DetroitLabs on 7/12/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "FirebaseOperation.h"
#import "CurrentUser.h"
@import FirebaseAuth;

@implementation FirebaseOperation

-(instancetype)init {
    self = [super init];
    if (self) {
        _firebaseDatabaseService = [[FirebaseDatabaseService alloc]init];
        [_firebaseDatabaseService initWithReference];
    }
    return self;
}

-(void)queryFirebaseWithNoConstraintsForChild:(NSString *)child andFIRDataEventType:(FIRDataEventType)FIRDataEventType completion:(void(^)(FIRDataSnapshot *snapshot))completion {
    
    FIRDatabaseReference *childRef = [_firebaseDatabaseService.ref child:child];
    [childRef observeEventType:FIRDataEventType withBlock:^(FIRDataSnapshot *snapshot) {
        completion(snapshot);
    }];
}

-(void)queryFirebaseWithConstraintsForChild:(NSString *)child queryOrderedByChild:(NSString *)childKey queryEqualToValue:(NSString *)value andFIRDataEventType:(FIRDataEventType)FIRDataEventType completion:(void(^)(FIRDataSnapshot *snapshot))completion {
    
    FIRDatabaseQuery *query = [[[_firebaseDatabaseService.ref child:child]queryOrderedByChild:childKey] queryEqualToValue:value];
    
    [query observeSingleEventOfType:FIRDataEventType withBlock:^(FIRDataSnapshot *snapshot) {
        completion(snapshot);
    }];
}

-(void)setValueForFirebaseChild:(NSString *)child value:(NSDictionary *)value {
    
    FIRDatabaseReference *childRef = [_firebaseDatabaseService.ref child:child].childByAutoId;
    
    NSString *childRefString = [NSString stringWithFormat:@"%@", childRef];
    _childID = [childRefString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"https://mapspotios.firebaseio.com/%@/", child] withString:@""];
    
    [childRef setValue:value];
    
}

-(void)listenForChildNodeChanges:(NSString *)child completion:(void(^)(CurrentUser *updatedCurrentUser))completion {
    if ([child isEqualToString:@"users"]) {
        [self queryUpdatedUserProfile:child completion:^(FIRDataSnapshot *snapshot) {
            completion([self updateCurrentUserInfo:snapshot]);
        }];
    } else {
        //We will query changes to spots...
    }
}

//Used to detect changes to the user profile. Called in 'listenForChildNodeChanges'
-(void)queryUpdatedUserProfile:(NSString *)child completion:(void(^)(FIRDataSnapshot *snapshot))completion {
    FIRDatabaseQuery *query = [[[_firebaseDatabaseService.ref child:child]queryOrderedByChild:@"userId"] queryEqualToValue:[FIRAuth auth].currentUser.uid];
    [query observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot) {
        completion(snapshot);
    }];
}


-(void)updateChildNode:(NSString *)child nodeToUpdate:(NSDictionary *)nodeToUpdate {
    FIRDatabaseReference *childRef = [_firebaseDatabaseService.ref child:child];
    NSDictionary *childUpdates;
    
    if ([child isEqualToString:@"users"]) {
        childUpdates = @{[CurrentUser sharedInstance].profileKey: nodeToUpdate};
        [childRef updateChildValues:childUpdates];
    }
}

-(CurrentUser *)updateCurrentUserInfo:(FIRDataSnapshot *)snapshot {
    CurrentUser *currentUser = [CurrentUser sharedInstance];
    [currentUser initWithUsername:snapshot.value[@"username"]
                         fullName:snapshot.value[@"fullName"]
                            email:snapshot.value[@"email"]
                           userId:snapshot.value[@"userId"]];
                currentUser.bio = snapshot.value[@"bio"];
                currentUser.location = snapshot.value[@"location"];
                currentUser.DOB = snapshot.value[@"DOB"];
    
    return currentUser;
}

-(void)uploadToFirebase:(NSData *)imageData completion:(void(^)(NSString *imageDownloadURL))completion {
    //Create a uniqueID for the image and add it to the end of the images reference.
    NSString *uniqueID = [[NSUUID UUID]UUIDString];
    NSString *newImageReference = [NSString stringWithFormat:@"images/%@.jpg", uniqueID];
    //imagesRef creates a reference for the images folder and then adds a child to that folder, which will be every time a photo is taken.
    FIRStorageReference *imagesRef = [_firebaseDatabaseService.firebaseStorageRef child:newImageReference];
    //This uploads the photo's NSData onto Firebase Storage.
    FIRStorageUploadTask *uploadTask = [imagesRef putData:imageData metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error.description);
        } else {
            completion([metadata.downloadURL absoluteString]);
        }
    }];
    [uploadTask resume];
}

@end
