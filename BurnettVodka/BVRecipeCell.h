//
//  BVRecipeCell.h
//  BurnettVodka
//
//  Created by admin on 7/18/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVRecipeImageView.h"

@class BVRatingStarView;
@class Recipe;
@class BVRecipeCell;


typedef enum {
    BVRecipeCellPositionSandwiched,
    BVRecipeCellPositionFirst,
    BVRecipeCellPositionLast,
    BVRecipeCellPositionFirstAndLast
} BVRecipeCellPosition;


@protocol BVRecipeCellDelegate <NSObject>

- (void)recipeCell:(BVRecipeCell *)cell needsImageReloadForRecipe:(Recipe *)recipeObject;

@end



@interface BVRecipeCell : UITableViewCell <BVRecipeImageViewDelegate> {
    
    UIView *mContainerView;
    UIImageView *mBackgroundImageView;
    UIImageView *mHeaderImageView;
    UIImageView *mFooterImageView;
    UILabel *mRecipeTitleLabel;
    UILabel *mFlavorTitleLabel;
    UILabel *mVotesLabel;
    BVRatingStarView *mRatingStarView;
    BVRecipeImageView *mRecipeImageView;
    UIView *mSeperatorLineView;
    
    id <BVRecipeCellDelegate> cellDelegate;
}

@property (nonatomic, assign) id <BVRecipeCellDelegate> cellDelegate;

+ (CGFloat)rowHeightOfCellWithCellPosition:(BVRecipeCellPosition)cellPosition;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andCellPosition:(BVRecipeCellPosition)cellPosition;

- (void)updateCellWithRecipe:(Recipe *)recipe;
- (void)updateCellWithRecipeInfoDictionary:(NSDictionary *)recipeDic;
- (void)updateRecipeImageWithImage:(UIImage *)recipeImage;

@end