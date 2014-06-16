//
//  BVTabBarController.m
//  BurnettVodka
//
//  Created by admin on 7/13/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVTabBarController.h"
#import "UtilityManager.h"
#import "Constants.h"
#import "BVHomeViewController.h"


#define kLoadingViewYCoordinateFor3Point5InchScreen 20
#define kLoadingViewYCoordinateFor4InchScreen 0

#define kGapBetweenLoadingIndicatorAndTitle 5


#define kAlertViewNewFeaturedRecipes 1


@interface BVTabBarController ()

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@end

@implementation BVTabBarController

@synthesize viewControllers = _viewControllers;
@synthesize controllerDelegate;
@synthesize tabBar = _tabBar;

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if(self)
    {
        _viewControllers = [viewControllers retain];
        
        if([_viewControllers count] > 0)
        {
            _selectedViewController = [_viewControllers objectAtIndex:0];
        }
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    
    NSMutableArray *arrayOfTabBarItems = [[NSMutableArray alloc] initWithCapacity:[_viewControllers count]];
    for(UIViewController *viewController in _viewControllers)
    {
        UITabBarItem *item = viewController.tabBarItem;
        if(item == nil)
        {
            item = [[[UITabBarItem alloc] initWithTitle:nil image:nil tag:[_viewControllers indexOfObject:viewController]] autorelease];
        }
        
        if(item)
            [arrayOfTabBarItems addObject:item];
    }
    
    
    _tabBar = [[BVTabBar alloc] initWithTabBarItems:arrayOfTabBarItems];
    [arrayOfTabBarItems release];
    
    _tabBar.viewDelegate = self;
    _tabBar.frame = CGRectMake(0,
                               self.view.frame.size.height - _tabBar.frame.size.height,
                               _tabBar.frame.size.width,
                               _tabBar.frame.size.height);
    [self.view addSubview:_tabBar];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newFeaturedRecipesDonwloaded:)
                                                 name:kNotificationNewFeaturedRecipesDownloaded
                                               object:nil];
    
    
    
//    for(UIViewController *controller in _viewControllers)
//    {
//        [self addChildViewController:controller];
//        [controller didMoveToParentViewController:self];
//    }
//    
//    
//    
//    
//    // Set the first tab selected by default
//    if([_viewControllers count] > 0)
//    {
//        UIViewController *controller = [_viewControllers objectAtIndex:0];
//        
//        controller.view.frame = CGRectMake(0,
//                                           0,
//                                           self.view.frame.size.width,
//                                           self.view.frame.size.height - _tabBar.frame.size.height);
//
//        
//        [self.view addSubview:controller.view];
//    }
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	if(_selectedViewController.parentViewController == self)
	{
		// nowthing to do
		return;
	}
    
    

    
	// adjust the frame to fit in the container view
	_selectedViewController.view.frame = CGRectMake(0,
                                                    0,
                                                    self.view.frame.size.width,
                                                    self.view.frame.size.height - _tabBar.frame.size.height);
    
    
	// make sure that it resizes on rotation automatically
	_selectedViewController.view.autoresizingMask = self.view.autoresizingMask;
    
    
	// add as child VC
	[self addChildViewController:_selectedViewController];
    

	// add it to container view, calls willMoveToParentViewController for us
	[self.view addSubview:_selectedViewController.view];
    
    
	// notify it that move is done
	[_selectedViewController didMoveToParentViewController:self];
    
    
    
    // If the Loading Screen has already been added to the view of TabBarController, then bring that view on top.
    if(_loadingView && _loadingView.superview == self.view)
    {
        [self.view bringSubviewToFront:_loadingView];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [_tabBar release];
    _tabBar = nil;
}

- (void)dealloc {
    
    [_loadingViewUpperHalfImageView release];
    [_loadingViewLowerHalfImageView release];
    [_loadingView release];
    [_viewControllers release];
    [_tabBar release];
    [super dealloc];
}





- (void)showLoadingScreenAnimated:(BOOL)animated
{
    if(_loadingView == nil)
    {
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                self.view.frame.size.width,
                                                                self.view.frame.size.height)];
        _loadingView.backgroundColor = [UIColor clearColor];
        
        
        
        
        NSString *upperHalfImageFileName = @"LoadingScreenUpperHalf";
        if([UtilityManager isThisDeviceA4InchIphone])
        {
            upperHalfImageFileName = @"LoadingScreenUpperHalf_4inch";
        }

        UIImage *upperHalfImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:upperHalfImageFileName ofType:@"png"]];
        _loadingViewUpperHalfImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                       0,
                                                                                       _loadingView.frame.size.width,
                                                                                       _loadingView.frame.size.height / 2)];
        _loadingViewUpperHalfImageView.image = upperHalfImage;
        [upperHalfImage release];
        
        mOriginalFrameForLoadingUpperImageView = _loadingViewUpperHalfImageView.frame;
        
        [_loadingView addSubview:_loadingViewUpperHalfImageView];
        
        
        
        
        
        NSString *lowerHalfImageFileName = @"LoadingScreenLowerHalf";
        if([UtilityManager isThisDeviceA4InchIphone])
        {
            lowerHalfImageFileName = @"LoadingScreenLowerHalf_4inch";
        }
        
        UIImage *lowerHalfImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:lowerHalfImageFileName ofType:@"png"]];
        _loadingViewLowerHalfImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                       _loadingView.frame.size.height / 2,
                                                                                       _loadingView.frame.size.width,
                                                                                       _loadingView.frame.size.height / 2)];
        _loadingViewLowerHalfImageView.image = lowerHalfImage;
        [lowerHalfImage release];
        
        mOriginalFrameForLoadingLowerImageView = _loadingViewLowerHalfImageView.frame;
        
        [_loadingView addSubview:_loadingViewLowerHalfImageView];

        
        
        
        CGFloat yCoordinate = kLoadingViewYCoordinateFor3Point5InchScreen;
        if([UtilityManager isThisDeviceA4InchIphone])
        {
            yCoordinate = kLoadingViewYCoordinateFor4InchScreen;
        }
        
        _loadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingActivityIndicator.frame = CGRectMake(roundf((_loadingViewLowerHalfImageView.frame.size.width - _loadingActivityIndicator.frame.size.width) / 2),
                                                     yCoordinate,
                                                     _loadingActivityIndicator.frame.size.width,
                                                     _loadingActivityIndicator.frame.size.height);
        [_loadingViewLowerHalfImageView addSubview:_loadingActivityIndicator];
        
        
        
        NSString *loadingString = @"Loading.....";
        UIFont *loadingFont = [UtilityManager fontGetRegularFontOfSize:20];
        CGSize loadingSize = [loadingString sizeWithFont:loadingFont];
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  _loadingActivityIndicator.frame.origin.y + _loadingActivityIndicator.frame.size.height + kGapBetweenLoadingIndicatorAndTitle,
                                                                  _loadingViewLowerHalfImageView.frame.size.width,
                                                                  loadingSize.height)];
        _loadingLabel.font = loadingFont;
        _loadingLabel.text = loadingString;
        _loadingLabel.backgroundColor = [UIColor clearColor];
        _loadingLabel.textColor = [UIColor colorWithRed:0 green:(73.0/256.0) blue:(144.0/256.0) alpha:1.0];
        _loadingLabel.textAlignment = UITextAlignmentCenter;
        [_loadingViewLowerHalfImageView addSubview:_loadingLabel];
    }
    
    [self.view addSubview:_loadingView];
    
    
    if(animated)
    {
        _loadingViewUpperHalfImageView.frame = CGRectMake(_loadingViewUpperHalfImageView.frame.origin.x,
                                                          -_loadingViewUpperHalfImageView.frame.size.height,
                                                          _loadingViewUpperHalfImageView.frame.size.width,
                                                          _loadingViewUpperHalfImageView.frame.size.height);
        
        _loadingViewLowerHalfImageView.frame = CGRectMake(_loadingViewLowerHalfImageView.frame.origin.x,
                                                          _loadingView.frame.size.height,
                                                          _loadingViewLowerHalfImageView.frame.size.width,
                                                          _loadingViewLowerHalfImageView.frame.size.height);
        
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             _loadingViewUpperHalfImageView.frame = mOriginalFrameForLoadingUpperImageView;
                             _loadingViewLowerHalfImageView.frame = mOriginalFrameForLoadingLowerImageView;
                         }
                         completion:^(BOOL finished) {
                             
                             [_loadingActivityIndicator startAnimating];
                         }];

    }
    else
    {
        [_loadingActivityIndicator startAnimating];
    }
    
}

- (void)hideLoadingScreenAnimated:(BOOL)animated
{
    if(animated)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             _loadingViewUpperHalfImageView.frame = CGRectMake(_loadingViewUpperHalfImageView.frame.origin.x,
                                                                               -_loadingViewUpperHalfImageView.frame.size.height,
                                                                               _loadingViewUpperHalfImageView.frame.size.width,
                                                                               _loadingViewUpperHalfImageView.frame.size.height);
                             
                             _loadingViewLowerHalfImageView.frame = CGRectMake(_loadingViewLowerHalfImageView.frame.origin.x,
                                                                               _loadingView.frame.size.height,
                                                                               _loadingViewLowerHalfImageView.frame.size.width,
                                                                               _loadingViewLowerHalfImageView.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             
                             [_loadingActivityIndicator stopAnimating];
                             [_loadingView removeFromSuperview];
                             [_loadingView release];
                             _loadingView = nil;
                         }];
    
    }
    else
    {
        [_loadingActivityIndicator stopAnimating];
        [_loadingView removeFromSuperview];
        [_loadingView release];
        _loadingView = nil;
    }
    
    
}




#pragma mark - FDSettingsTabBar Delegate Methods

- (void)settingsTabBar:(BVTabBar *)tabBar changeInSelectedFromIndex:(NSInteger)previousIndex toNewIndex:(NSInteger)newSelectedIndex
{
    NSString *title = @"";
    switch (newSelectedIndex)
    {
        case 0:
        {
            title = @"Home Tab: Appear";
            break;
        }
            
        case 1:
        {
            title = @"Flavors Tab: Appear";
            break;
        }
            
        case 2:
        {
            title = @"Recipes Tab: Appear";
            break;
        }
            
        case 3:
        {
            title = @"Top Rated Tab: Appear";
            break;
        }
            
        case 4:
        {
            title = @"My Faves Tab: Appear";
            break;
        }
            
            
        default:
            break;
    }
        
    UIViewController *previousViewController = [_viewControllers objectAtIndex:previousIndex];
    UIViewController *newViewController = [_viewControllers objectAtIndex:newSelectedIndex];
    //[newViewController retain];
    
    [self transitionFromViewController:previousViewController toViewController:newViewController];
}




- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
	if (fromViewController == toViewController)
	{
		// cannot transition to same
		return;
	}
    

    
    
	// animation setup
	toViewController.view.frame = CGRectMake(0,
                                             0,
                                             self.view.frame.size.width,
                                             self.view.frame.size.height - _tabBar.frame.size.height);
    
	toViewController.view.autoresizingMask = self.view.autoresizingMask;
    
	// notify
	[fromViewController willMoveToParentViewController:nil];
	[self addChildViewController:toViewController];
    
    
    // add it to container view, calls willMoveToParentViewController for us
	[self.view addSubview:toViewController.view];
    [toViewController didMoveToParentViewController:self];
    
    
    [fromViewController.view removeFromSuperview];
    [fromViewController removeFromParentViewController];
    
    
    _selectedViewController = toViewController;
    
    
    // If the Loading Screen has already been added to the view of TabBarController, then bring that view on top.
    if(_loadingView && _loadingView.superview == self.view)
    {
        [self.view bringSubviewToFront:_loadingView];
    }
}


- (void)newFeaturedRecipesDonwloaded:(NSNotification *)notification
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"New featued recipes have been downloaded. Do you want to reload home tab now to see new featured recipes or later on next app launch" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Now", nil];
    alertView.tag = kAlertViewNewFeaturedRecipes;
    [alertView show];
    [alertView release];
}


#pragma mark -
#pragma mark UIAlertView Delegate Methods


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kAlertViewNewFeaturedRecipes)
    {
        if(buttonIndex == 1)
        {
            [self showLoadingScreenAnimated:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                
                [self.tabBar setSelectedIndex:0];
                
                if([_selectedViewController isKindOfClass:[UINavigationController class]])
                {
                    if([[(UINavigationController *)_selectedViewController viewControllers] count] > 0)
                    {
                        if([[[(UINavigationController *)_selectedViewController viewControllers] objectAtIndex:0] isKindOfClass:[BVHomeViewController class]])
                        {
                            [(UINavigationController *)_selectedViewController popToRootViewControllerAnimated:NO];
                            
                            [(BVHomeViewController *)[[(UINavigationController *)_selectedViewController viewControllers] objectAtIndex:0] reload];
                        }
                    }
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                    
                    [self hideLoadingScreenAnimated:YES];
                });
            });
        }
    }
}

@end
