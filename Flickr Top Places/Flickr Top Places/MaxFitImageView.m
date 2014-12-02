//
//  MaxFitImageView.m
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 12/1/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import "MaxFitImageView.h"

@implementation MaxFitImageView


- (CGSize)sizeThatFits:(CGSize)size {
    if(self.image) {
    CGSize viewSize = self.superview.bounds.size;
    CGSize imageSize = self.image.size;
    CGFloat scaleFactorWidth = viewSize.width/imageSize.width;
    CGFloat scaleFactorHeight = viewSize.height/imageSize.height;
    
    CGFloat scaleFactor = MAX(scaleFactorWidth, scaleFactorHeight);
    CGSize fitSize = CGSizeMake(imageSize.width * scaleFactor, imageSize.height * scaleFactor);
        return fitSize;
    } else {
        return [super sizeThatFits:size];
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
