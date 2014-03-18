//
//  DKPageViewController.m
//  DKAnimatedScroll
//
//  Created by Damien Kan on 3/12/14.
//  Copyright (c) 2014 Damien Kan. All rights reserved.
//

#import "DKPageViewController.h"
#import "DKScrollViewController.h"

@interface DKPageViewController ()
{
    UIModalTransitionStyle modalTransitionStyle;
}

@property (nonatomic, strong)IBOutlet UIButton *closeButton;

@end

@implementation DKPageViewController

@synthesize closeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        [self.closeButton addTarget:self
//                             action:@selector(closeBook)
//                   forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextPage
{
    NSLog(@"NEXT PAGE");
    DKPageViewController *nextPageViewController = [[DKPageViewController alloc] init];
    [self.navigationController pushViewController:nextPageViewController animated:YES];
}

- (IBAction)lastPage
{
    NSLog(@"LAST PAGE");
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)closeBook
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    DKScrollViewController *presentingViewController = (DKScrollViewController *)self.presentingViewController;
    UIView *pageView = self.view;
    [presentingViewController.view addSubview:pageView];
    [super dismissViewControllerAnimated:NO completion:nil];

    [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionShowHideTransitionViews animations:^{
        
        pageView.frame = CGRectMake(pageView.frame.origin.x, (kPageFrame.origin.y + 20.0)-(768.0 - kPageFrame.size.height)/2, pageView.frame.size.width, pageView.frame.size.height);
        pageView.transform = CGAffineTransformMakeScale(kPageFrame.size.width/1024.0, kPageFrame.size.height/768.0);

        presentingViewController.transitionBack.frame = CGRectMake(pageView.frame.origin.x, (kPageFrame.origin.y + 20.0), pageView.frame.size.width, pageView.frame.size.height);
        presentingViewController.transitionCover.frame = CGRectMake(pageView.frame.origin.x, (kPageFrame.origin.y + 20.0), pageView.frame.size.width, pageView.frame.size.height);
        
    } completion:nil];
    
    double delayInSeconds = 0.68;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [presentingViewController.view bringSubviewToFront:presentingViewController.transitionCover];
    });

    [UIView animateWithDuration:0.5 delay:0.45 options:UIViewAnimationOptionCurveLinear animations:^(void){
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = -1.0 / 5500;
        float angle = 0;
        
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, angle * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        
        presentingViewController.transitionCover.layer.transform = rotationAndPerspectiveTransform;
        presentingViewController.transitionBack.layer.transform = rotationAndPerspectiveTransform;
        
    } completion:^(BOOL complete) {
        [presentingViewController.transitionCover removeFromSuperview];
        [presentingViewController.transitionBack removeFromSuperview];
        [pageView removeFromSuperview];
    }];

}
@end
