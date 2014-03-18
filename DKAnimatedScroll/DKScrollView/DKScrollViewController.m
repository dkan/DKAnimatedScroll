//
//  DKScrollViewController.m
//  DKAnimatedScroll
//
//  Created by Damien Kan on 3/7/14.
//  Copyright (c) 2014 Damien Kan. All rights reserved.
//

#import "DKScrollViewController.h"
#import "DKScrollViewMask.h"
#import "DKBookNavigationViewController.h"
#import "DKBookViewController.h"
#import "DKPageViewController.h"

@interface DKScrollViewController ()
{
    UIModalTransitionStyle modalTransitionStyle;
}

@property (nonatomic, strong)NSArray *imageArray;
@property (nonatomic, strong)NSMutableArray *pageViews;
@property (nonatomic, strong)NSMutableArray *xPosArray;
@property (nonatomic)DKBookCoverView *bookToOpen;

@property (nonatomic, strong)IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong)IBOutlet DKScrollViewMask *scrollViewMask;

@end

@implementation DKScrollViewController

@synthesize scrollView = _scrollView;
@synthesize pageViews = _pageViews;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.imageArray = [self findImages];
        self.pageViews = [[NSMutableArray alloc] init];
        self.xPosArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    for (NSInteger i = 0; i < self.imageArray.count; i++) {
        [self.pageViews addObject:[NSNull null]];
    }

    [self loadVisiblePages];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.scrollView.contentSize = CGSizeMake(self.imageArray.count * self.scrollView.frame.size.width, 0.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSArray *)findImages
{
    // Dummy images
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 6; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", i]];
        [images addObject:image];
    }
    return images;
}

#pragma mark - Lazy loading pages

- (void)loadVisiblePages {
    int page = (int)self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;

    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 2;

    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        if (i < self.imageArray.count) {
            [self loadPage:i];
        }
    }

    [self setAngles:self.scrollView withPage:page];

    for (NSInteger i=lastPage+1; i<self.imageArray.count; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.imageArray.count) {
        return;
    }

    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = kPageFrame;
        frame.origin.x = page * self.scrollView.frame.size.width + (self.scrollView.frame.size.width - kPageFrame.size.width)/2;

        DKBookCoverView *newPageView = [[DKBookCoverView alloc] initWithFrame:frame];
        newPageView.coverImage.image = [self.imageArray objectAtIndex:page];
        newPageView.delegate = self;
        newPageView.tag = page;
        [self.scrollView addSubview:newPageView];

        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.imageArray.count) {
        return;
    }
    
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

#pragma mark - UIScrollView Delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self loadVisiblePages];
}

- (void)setAngles:(UIScrollView *)scrollView withPage:(int)page
{
    float offset = ((int)scrollView.contentOffset.x % (int)self.scrollView.bounds.size.width) / self.scrollView.bounds.size.width;
    float gap = (kPageFrame.size.width - self.scrollView.frame.size.width)/2 + 46.0;
    
    DKBookCoverView *current = (DKBookCoverView *)self.pageViews[page];
    [current.superview bringSubviewToFront:current];

    float currentX = page * self.scrollView.frame.size.width + (self.scrollView.frame.size.width - kPageFrame.size.width)/2;

    if (offset <= 0.5) {
        current.frame = CGRectMake(currentX - offset * gap, kPageFrame.origin.y, kPageFrame.size.width, kPageFrame.size.height);
    } else {
        current.frame = CGRectMake(currentX - ((1 - offset) * gap), kPageFrame.origin.y, kPageFrame.size.width, kPageFrame.size.height);
    }
    
    if (self.imageArray.count - 1 > page) {
        DKBookCoverView *next = (DKBookCoverView *)self.pageViews[page + 1];
        float nextX = (page + 1) * self.scrollView.frame.size.width + (self.scrollView.frame.size.width - kPageFrame.size.width)/2;
        if (offset <= 0.5) {
            next.frame = CGRectMake(nextX + offset * gap, kPageFrame.origin.y, kPageFrame.size.width, kPageFrame.size.height);
        } else {
            next.frame = CGRectMake(nextX + ((1 - offset) * gap), kPageFrame.origin.y, kPageFrame.size.width, kPageFrame.size.height);
        }
    }

    for (DKBookCoverView *bookView in self.pageViews) {
        if ((NSNull*)bookView != [NSNull null]) {
            bookView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            
            int imageIndex = (int)[self.pageViews indexOfObject:bookView];
            CALayer *layer = bookView.layer;
            
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = 1.0 / -500;
            float angle = ((page - imageIndex + offset) * 15.0 / self.scrollView.bounds.size.width) * 360.0;
            
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, angle * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
            layer.transform = rotationAndPerspectiveTransform;
        }
    }
}

#pragma mark - DKBookCoverViewDelegate

- (void)collectionDidSelectCover:(id)bookCoverView
{
    self.bookToOpen = (DKBookCoverView *)bookCoverView;
    DKPageViewController *currentPageViewController = [[DKPageViewController alloc] init];
    DKBookViewController *bookViewController = [[DKBookViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{@"UIPageViewControllerOptionSpineLocationKey" : @1}];
    bookViewController.delegate = self;
    bookViewController.dataSource = self;
    NSArray *vcs = @[currentPageViewController];
    [bookViewController setViewControllers:vcs direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    bookViewController.modalTransitionStyle = UIModalTransitionStyleOpenBooks;
    [self presentViewController:bookViewController animated:YES completion:nil];

//    self.bookToOpen = (DKBookCoverView *)bookCoverView;
//    DKPageViewController *currentPageViewController = [[DKPageViewController alloc] init];
//    DKBookNavigationViewController *bookViewController = [[DKBookNavigationViewController alloc] initWithRootViewController:currentPageViewController];
//    [bookViewController setNavigationBarHidden:YES animated:NO];
//    bookViewController.modalTransitionStyle = UIModalTransitionStyleOpenBooks;
//    [self presentViewController:bookViewController animated:YES completion:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControwController:(UIViewController *)viewController
{
    DKPageViewController *currentPageViewController = [[DKPageViewController alloc] init];

    return currentPageViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    DKPageViewController *currentPageViewController = [[DKPageViewController alloc] init];

    return currentPageViewController;
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    modalTransitionStyle = modalViewController.modalTransitionStyle;
    if (modalTransitionStyle == UIModalTransitionStyleOpenBooks) {
        [self presentViewController:modalViewController animated:animated completion:nil];
    } else {
        [super presentModalViewController:modalViewController animated:animated];
    }
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    modalTransitionStyle = viewControllerToPresent.modalTransitionStyle;
    if (modalTransitionStyle == UIModalTransitionStyleOpenBooks) {

        CGRect bookFrame = CGRectMake(self.bookToOpen.superview.frame.origin.x + (self.scrollView.frame.size.width - kPageFrame.size.width)/2, self.bookToOpen.frame.origin.y + self.bookToOpen.superview.frame.origin.y, self.bookToOpen.frame.size.width, self.bookToOpen.frame.size.height);
        CGFloat scaleX = bookFrame.size.width / self.view.bounds.size.width;
        CGFloat scaleY = bookFrame.size.height / self.view.bounds.size.height;

        UIView *pageView = viewControllerToPresent.view;
        pageView.frame = CGRectMake(bookFrame.origin.x, bookFrame.origin.y, 1024.0, 768.0);
        pageView.transform = CGAffineTransformMakeScale(scaleX, scaleY);
        pageView.frame = CGRectMake(bookFrame.origin.x, bookFrame.origin.y, pageView.frame.size.width, pageView.frame.size.height);

        [self.view addSubview:pageView];

        self.transitionBack = [[UIView alloc] initWithFrame:bookFrame];
        self.transitionBack.backgroundColor = [UIColor grayColor];
        self.transitionBack.layer.anchorPoint = CGPointMake(0.0, 0.5);
        self.transitionBack.center = CGPointMake(bookFrame.origin.x, bookFrame.origin.y + bookFrame.size.height/2.0);
        [self.view addSubview:self.transitionBack];

        self.transitionCover = [[UIImageView alloc] initWithFrame:bookFrame];
        self.transitionCover.contentMode = UIViewContentModeScaleAspectFill;
        self.transitionCover.clipsToBounds = YES;
        self.transitionCover.image = [self.imageArray objectAtIndex:[self.pageViews indexOfObject:self.bookToOpen]];
        self.transitionCover.layer.anchorPoint = CGPointMake(0.0, 0.5);
        self.transitionCover.center = CGPointMake(bookFrame.origin.x, bookFrame.origin.y + bookFrame.size.height/2.0);
        [self.view addSubview:self.transitionCover];

        double delayInSeconds = 0.23;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.view bringSubviewToFront:self.transitionBack];
        });

        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^(void){
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = -1.0 / 500;
            float angle = 180;
            
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, angle * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
            self.transitionCover.layer.transform = rotationAndPerspectiveTransform;
            self.transitionBack.layer.transform = rotationAndPerspectiveTransform;

        } completion:^(BOOL complete) {
        }];

        [UIView animateWithDuration:0.5 delay:0.45 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
            self.transitionCover.frame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
            self.transitionBack.frame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
            pageView.frame = CGRectMake(pageView.frame.origin.x, (pageView.frame.size.height/2.0) * (1.0/scaleY - 1), pageView.frame.size.width, pageView.frame.size.height);

            pageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL complete){
            viewControllerToPresent.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:viewControllerToPresent animated:NO completion:nil];
        }];
    } else {
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

@end
