//
//  BVRecipeDetailViewController.h
//  BurnettVodka
//
//  Created by admin on 7/19/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"
#import "BVShareOverlayView.h"
#import "BVRatingOverlayView.h"
#import <MessageUI/MessageUI.h>
#import "GAITrackedViewController.h"

@class BVRatingStarView;




@class BVRecipeDetailAddToFavoriteView;

@protocol BVRecipeDetailAddToFavoriteViewDelegate <NSObject>

- (void)recipeDetailAddToFavoriteViewUserTappedAddToFavoriteButton:(BVRecipeDetailAddToFavoriteView *)view;
- (void)recipeDetailAddToFavoriteViewUserSwippedToRemoveFromFavorites:(BVRecipeDetailAddToFavoriteView *)view;

@end

@interface BVRecipeDetailAddToFavoriteView : UIView {
    
    UIButton *mAddToFavButton;
    UISwipeGestureRecognizer *mSwipeGestureRecognizer;
    
    id <BVRecipeDetailAddToFavoriteViewDelegate> viewDelegate;
}

@property (nonatomic, assign) id <BVRecipeDetailAddToFavoriteViewDelegate> viewDelegate;

- (void)updateViewToShowAdded:(BOOL)isAdded animated:(BOOL)animated;

@end










@interface BVRecipeDetailViewController : GAITrackedViewController <BVShareOverlayViewDelegate, BVRatingOverlayViewDelegate, MFMailComposeViewControllerDelegate, BVRecipeDetailAddToFavoriteViewDelegate, MFMessageComposeViewControllerDelegate> {
    
    Recipe *mRecipeObject;
    
    UIScrollView *mScrollView;
    BVShareOverlayView *mShareOverlayView;
    BVRatingOverlayView *mRatingOverlayView;
    BVRecipeDetailAddToFavoriteView *mAddToFavoriteView;
    BVRatingStarView *mRatingStarView;
    UILabel *mRatingTitleLabel;
    UIView *mRemoveFromFavoriteView;
    
    CGRect mOriginalRectForRemoveFromFavView;
}

- (id)initWithRecipe:(Recipe *)recipeObject;

@end
