//
//  MediaPreviewCell.m
//  MapSpot
//
//  Created by DetroitLabs on 7/16/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "MediaPreviewCell.h"

@implementation MediaPreviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = self.layer.frame.size.height/2;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [[UIColor blackColor]CGColor];
    
}

@end
