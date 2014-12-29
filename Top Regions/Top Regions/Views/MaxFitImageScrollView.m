//
//  MaxFitImageScrollView.m
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 12/1/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "MaxFitImageScrollView.h"

@implementation MaxFitImageScrollView


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.delegateForLayoutChanges) {
        [self.delegateForLayoutChanges layoutChanged];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
