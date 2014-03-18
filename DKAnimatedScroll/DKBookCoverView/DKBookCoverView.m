//
//  DKBookCoverView.m
//  DKAnimatedScroll
//
//  Created by Damien Kan on 3/10/14.
//  Copyright (c) 2014 Damien Kan. All rights reserved.
//

#import "DKBookCoverView.h"

@implementation DKBookCoverView

@synthesize coverImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        self.coverImage.clipsToBounds = YES;
        self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.coverImage];
        UITapGestureRecognizer *selectCoverRecognizer = [[UITapGestureRecognizer alloc]
                                                         initWithTarget:self
                                                         action:@selector(handleCoverSelection)];
        [self addGestureRecognizer:selectCoverRecognizer];
    }
    return self;
}

- (void)handleCoverSelection
{
    if ([self.delegate respondsToSelector:@selector(collectionDidSelectCover:)])
        [self.delegate collectionDidSelectCover:self];
}

@end
