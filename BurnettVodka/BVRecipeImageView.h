//
//  BVRecipeImageView.h
//  BurnettVodka
//
//  Created by admin on 7/18/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

@class BVRecipeImageView;

@protocol BVRecipeImageViewDelegate <NSObject>

- (void)recipeImageView:(BVRecipeImageView *)recipeImageView needsImageReloadForRecipe:(Recipe *)recipeObject;

@end

@interface BVRecipeImageView : UIView {
    
    UIImageView *mBackgroundImageView;
    UIImageView *mRecipeImageView;
    
    id <BVRecipeImageViewDelegate> viewDelegate;
}

@property (nonatomic, assign) id <BVRecipeImageViewDelegate> viewDelegate;

- (void)updateForRecipe:(Recipe *)recipeObject;
- (void)updateRecipeImage:(UIImage *)recipeImage;

@end
