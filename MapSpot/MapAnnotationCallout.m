//
//  MapAnnotationCallout.m
//  MapSpot
//
//  Created by DetroitLabs on 7/14/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "MapAnnotationCallout.h"

@implementation MapAnnotationCallout

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // 1. Load .xib
        
        [[NSBundle mainBundle]loadNibNamed:@"MapAnnotationCalloutView" owner:self options:nil];
        
        // 2. Adjust bounds - the bounds being loaded are from the xib file we created.
        self.bounds = _view.bounds;
        
        // 3. add as a subview.
        [self addSubview:_view];
        
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
