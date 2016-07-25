//
//  AlertView.m
//  MapSpot
//
//  Created by DetroitLabs on 7/12/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "AlertView.h"

@implementation AlertView

-(void)genericAlert:(NSString *)title message:(NSString *)message presentingViewController:(UIViewController *)viewController {
    UIAlertController *alertController =[UIAlertController
                                         alertControllerWithTitle:title
                                         message:message
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:ok];
    [viewController presentViewController:alertController animated:true completion:nil];
}


@end
