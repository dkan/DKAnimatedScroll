//
//  DKScrollViewMask.m
//  DKAnimatedScroll
//
//  Created by Damien Kan on 3/10/14.
//  Copyright (c) 2014 Damien Kan. All rights reserved.
//

#import "DKScrollViewMask.h"

@implementation DKScrollViewMask

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self)
        return [self subviews][0];
    
    return view;
}

@end
