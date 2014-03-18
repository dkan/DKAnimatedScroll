//
//  DKScrollViewController.h
//  DKAnimatedScroll
//
//  Created by Damien Kan on 3/7/14.
//  Copyright (c) 2014 Damien Kan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DKBookCoverView.h"

typedef enum {
    UIModalTransitionStyleOpenBooks = 0x01 << 7,
    
} UIModalTransitionStyleCustom;

@interface DKScrollViewController : UIViewController <UIScrollViewDelegate, DKBookCoverViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong)UIImageView *transitionCover;
@property (nonatomic, strong)UIView *transitionBack;

@end
