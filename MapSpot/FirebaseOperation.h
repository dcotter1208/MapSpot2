//
//  FirebaseOperation.h
//  MapSpot
//
//  Created by DetroitLabs on 7/12/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirebaseDatabaseService.h"
#import "CurrentUser.h"
@import Firebase;
@import FirebaseDatabase;

@interface FirebaseOperation : NSObject

@property (nonatomic, strong) FirebaseDatabaseService *firebaseDatabaseService;
@property (nonatomic, strong) NSString *childID;

//Queries all child nodes of a specified reference with no constraints.
-(void)queryFirebaseWithNoConstraintsForChild:(NSString *)child andFIRDataEventType:(FIRDataEventType)FIRDataEventType completion:(void(^)(FIRDataSnapshot *snapshot))completion;

//Used to query a child node with the constraints of orderByChild and queryEqualToValue
-(void)queryFirebaseWithConstraintsForChild:(NSString *)child queryOrderedByChild:(NSString *)childKey queryEqualToValue:(NSString *)value andFIRDataEventType:(FIRDataEventType)FIRDataEventType observeSingleEventType:(BOOL)observeSingleEventType completion:(void(^)(FIRDataSnapshot *snapshot))completion;

//Used to create a child node.
-(void)setValueForFirebaseChild:(NSString *)child value:(NSDictionary *)value;

-(void)listenForChildNodeChanges:(NSString *)child completion:(void(^)(CurrentUser *updatedCurrentUser))completion;

-(void)updateChildNode:(NSString *)child nodeToUpdate:(NSDictionary *)nodeToUpdate;

-(void)uploadToFirebase:(NSData *)imageData completion:(void(^)(NSString *imageDownloadURL))completion;

-(instancetype)init;

@end
