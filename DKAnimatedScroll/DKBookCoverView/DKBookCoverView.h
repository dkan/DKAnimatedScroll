//
//  DKBookCoverView.h
//  DKAnimatedScroll
//
//  Created by Damien Kan on 3/10/14.
//  Copyright (c) 2014 Damien Kan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKBookCoverView.h"

@protocol DKBookCoverViewDelegate <NSObject>

- (void)collectionDidSelectCover:(id)bookCoverView;

@end

@interface DKBookCoverView : UIView

@property (nonatomic, strong)UIImageView *coverImage;
@property (nonatomic) id<DKBookCoverViewDelegate> delegate;

@end
