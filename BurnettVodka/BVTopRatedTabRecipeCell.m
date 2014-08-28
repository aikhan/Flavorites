//
//  BVTopRatedTabRecipeCell.m
//  BurnettVodka
//
//  Created by admin on 7/24/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVTopRatedTabRecipeCell.h"
#import "BVRecipeImageView.h"
#import "UtilityManager.h"

@implementation BVTopRatedTabRecipeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andCellPosition:(BVRecipeCellPosition)cellPosition
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier andCellPosition:cellPosition];
    if (self)
    {
        // Initialization code

        UIImage *backgroundCircleImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"TopRatedBackgroundCircle.png" andAddIfRequired:YES];
        
        mTopRatingBackgroundCircleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(mRecipeImageView.frame.origin.x + 4,
                                                                                            mRecipeImageView.frame.origin.y /*+ mRecipeImageView.frame.size.height - backgroundCircleImage.size.height - 2*/,
                                                                                            backgroundCircleImage.size.width,
                                                                                            backgroundCircleImage.size.height)];
        mTopRatingBackgroundCircleImageView.image = backgroundCircleImage;
        [mContainerView addSubview:mTopRatingBackgroundCircleImageView];
        
        
        
        
        
        mTopRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(mTopRatingBackgroundCircleImageView.frame.origin.x,
                                                                    mTopRatingBackgroundCircleImageView.frame.origin.y,
                                                                    mTopRatingBackgroundCircleImageView.frame.size.width,
                                                                    mTopRatingBackgroundCircleImageView.frame.size.height)];
        mTopRatingLabel.backgroundColor = [UIColor clearColor];
        mTopRatingLabel.textColor = [UIColor whiteColor];
        mTopRatingLabel.textAlignment = UITextAlignmentCenter;
        mTopRatingLabel.font = [UtilityManager fontGetRegularFontOfSize:14];
        [mContainerView addSubview:mTopRatingLabel];
    
    }
    return self;
}

- (void)dealloc {
    
    [mTopRatingBackgroundCircleImageView release];
    [mTopRatingLabel release];
    [super dealloc];
}


- (void)updateCellWithRecipe:(Recipe *)recipe andRatingNumber:(NSInteger)ratingNumber
{
    [super updateCellWithRecipe:recipe];
    
    mTopRatingLabel.text = [NSString stringWithFormat:@"%d", ratingNumber];
}

@end
