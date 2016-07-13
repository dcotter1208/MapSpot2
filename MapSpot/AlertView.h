//
//  AlertView.h
//  MapSpot
//
//  Created by DetroitLabs on 7/12/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertView : NSObject

-(void)genericAlert:(NSString *)title message:(NSString *)message presentingViewController:(UIViewController *)viewController;


@end
