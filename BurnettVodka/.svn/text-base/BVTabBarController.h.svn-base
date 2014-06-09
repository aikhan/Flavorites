//
//  BVTabBarController.h
//  BurnettVodka
//
//  Created by admin on 7/13/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVTabBar.h"

@class BVTabBarController;


@protocol BVTabBarControllerDelegate <NSObject>



@end



@interface BVTabBarController : UIViewController <BVTabBarDelegate> {
    
    NSArray *_viewControllers;
    UIViewController *_selectedViewController;
    
    BVTabBar *_tabBar;
    UIView *_loadingView;
    UIImageView *_loadingViewUpperHalfImageView;
    UIImageView *_loadingViewLowerHalfImageView;
    UILabel *_loadingLabel;
    UIActivityIndicatorView *_loadingActivityIndicator;
    
    CGRect mOriginalFrameForLoadingUpperImageView;
    CGRect mOriginalFrameForLoadingLowerImageView;
    
    id <BVTabBarControllerDelegate> controllerDelegate;
}

@property (nonatomic, assign) id <BVTabBarControllerDelegate> controllerDelegate;
@property (nonatomic, readonly) NSArray *viewControllers;
@property (nonatomic, readonly) BVTabBar *tabBar;


- (id)initWithViewControllers:(NSArray *)viewControllers;
- (void)showLoadingScreenAnimated:(BOOL)animated;
- (void)hideLoadingScreenAnimated:(BOOL)animated;

@end
