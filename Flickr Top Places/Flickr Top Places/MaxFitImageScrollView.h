//
//  MaxFitImageScrollView.h
//  Flickr Top Places
//
//  Created by Parmesh Bayappu on 12/1/14.
//  Copyright (c) 2014 Parmesh Bayappu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotifyLayoutChanges <NSObject>

- (void)layoutChanged;

@end

@interface MaxFitImageScrollView : UIScrollView

@property (nonatomic) id<NotifyLayoutChanges> delegateForLayoutChanges;

@end
