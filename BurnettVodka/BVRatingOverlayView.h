//
//  BVRatingOverlayView.h
//  BurnettVodka
//
//  Created by admin on 7/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"
#import "ASIHTTPRequest.h"

@class BVRatingOverlayView;

@protocol BVRatingOverlayViewDelegate <NSObject>

- (void)ratingOverlayViewCancelButtonTapped:(BVRatingOverlayView *)view;
- (void)ratingOverlayView:(BVRatingOverlayView *)view didFinishSubmittingRatingsForRecipe:(Recipe *)recipe;
- (void)ratingOverlayView:(BVRatingOverlayView *)view didFailToSubmitRatingsForRecipe:(Recipe *)recipe;
- (void)ratingOverlayView:(BVRatingOverlayView *)view didCancelWhileSubmittingRatingsForRecipe:(Recipe *)recipe;
- (Recipe *)recipeObjectForRatingSubmissionByBVRatingOverlayView:(BVRatingOverlayView *)view;

@end

@interface BVRatingOverlayView : UIView {
    
    UIView *mBackgroundTranslucentView;
    UIView *mContainerView;
    
    UILabel *mMessageLabel;
    UIActivityIndicatorView *mActivityIndicatorView;
    UIButton *mSubmissionCancelButton;
    
    Recipe *mRecipe;
    ASIHTTPRequest *mRatingSubmissionRequest;
    
    id <BVRatingOverlayViewDelegate> viewDelegate;
}

@property (nonatomic, assign) id <BVRatingOverlayViewDelegate> viewDelegate;

- (void)showInView:(UIView *)view;

@end
