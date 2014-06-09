//
//  BVFavTabRecipeCell.h
//  BurnettVodka
//
//  Created by admin on 7/24/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVRecipeCell.h"

@class BVRemoveFromFavoriteView;

@protocol BVRemoveFromFavoriteViewDelegate <NSObject>

- (void)userTappedNOOnBVRemoveFromFavoriteView:(BVRemoveFromFavoriteView *)view;
- (void)userTappedYESOnBVRemoveFromFavoriteView:(BVRemoveFromFavoriteView *)view;

@end

@interface BVRemoveFromFavoriteView : UIView {
    
    UIView *mTranslucentBackgroundView;
    UILabel *mTitleLabel;
    UILabel *mDescriptionLabel;
    UIButton *mNoButton;
    UIButton *mYesButton;
    
    CGRect mOriginalFrameForTitleLabel;
    CGRect mOriginalFrameForDescriptionLabel;
    CGRect mOriginalFrameForNoButton;
    CGRect mOriginalFrameForYesButton;
    CGRect mOriginalFrameForTranslucentView;
        
    id <BVRemoveFromFavoriteViewDelegate> viewDelegate;
}

@property (nonatomic, assign) id <BVRemoveFromFavoriteViewDelegate> viewDelegate;

- (void)show;
- (void)hide;

@end




@class BVFavTabRecipeCell;

@protocol BVFavTabRecipeCellDelegate <NSObject>

- (void)favTabRecipeCell:(BVFavTabRecipeCell *)cell deleteViewActive:(BOOL)isActive;
- (void)favTabRecipeCellUserConfirmedDeletion:(BVFavTabRecipeCell *)cell;

@end



@interface BVFavTabRecipeCell : BVRecipeCell <BVRemoveFromFavoriteViewDelegate> {
    
    BVRemoveFromFavoriteView *mRemoveFroFavView;
    
    BOOL isDeleteViewActive;
    
    id <BVFavTabRecipeCellDelegate> favTabRecipeCellDelegate;
}

@property (nonatomic, assign) id <BVFavTabRecipeCellDelegate> favTabRecipeCellDelegate;

- (void)showDeleteViewAnimated:(BOOL)animated;
- (void)hideDeleteViewAnimated:(BOOL)animated;

@end
