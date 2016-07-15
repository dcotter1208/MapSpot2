//
//  MapAnnotationCallout.h
//  MapSpot
//
//  Created by DetroitLabs on 7/14/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapAnnotationCallout : UIView
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIView *view;

@end
