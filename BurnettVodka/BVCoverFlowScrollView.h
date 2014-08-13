//
//  BVCoverFlowScrollView.h
//  BurnettVodka
//
//  Created by admin on 7/27/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeaturedRecipeItem;






@class BVFeaturedRecipeView;

@protocol BVFeaturedRecipeViewDelegate <NSObject>

- (void)featuredRecipeView:(BVFeaturedRecipeView *)view userTappedWithRecipeID:(NSInteger)recipeID;

@end

@interface BVFeaturedRecipeView : UIView {
    
    FeaturedRecipeItem *mRecipeItem;
    CGFloat mDistanceFromCenter;
    
    UIImageView *mPosterImageView;
    UIActivityIndicatorView *mActivityIndicator;
        
    id <BVFeaturedRecipeViewDelegate> viewDelegate;
}

@property (nonatomic, assign) id <BVFeaturedRecipeViewDelegate> viewDelegate;


- (id)initWithFrame:(CGRect)frame andFeaturedRecipeItem:(FeaturedRecipeItem *)item andNew:(BOOL)isnew;
- (void)updateDistanceFromCenter:(CGFloat)distanceFromCenter;

@end






@class BVCoverFlowScrollView;

@protocol BVCoverFlowScrollViewDelegate <NSObject>

- (void)coverFlowScrollView:(BVCoverFlowScrollView *)scrollView userTappedWithRecipeID:(NSInteger)recipeID;

@end

@interface BVCoverFlowScrollView : UIScrollView <BVFeaturedRecipeViewDelegate> {
    
    NSArray *mFeaturedRecipeItemsArray;
    NSMutableArray *mHomeScreenRecipeCardViewsArray;
    CGFloat mSideSpacingWhenSingleCard;
    CGFloat mDistanceUponWhichToVary;
    
    id <BVCoverFlowScrollViewDelegate> coverFlowDelegate;
}

@property (nonatomic, assign) id <BVCoverFlowScrollViewDelegate> coverFlowDelegate;

- (void)resetScrollViewWithRecipesArray:(NSArray *)recipesArray;
- (void)scrollViewScrolled;

@end
