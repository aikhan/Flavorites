//
//  BVRecipeImageView.m
//  BurnettVodka
//
//  Created by admin on 7/18/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVRecipeImageView.h"
#import "UtilityManager.h"

@implementation BVRecipeImageView

@synthesize viewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"RecipeImageViewBackground.png" andAddIfRequired:YES];
        
        CGFloat heightToBeUsed = frame.size.height;
        CGFloat widthToBeUsed = (backgroundImage.size.width / backgroundImage.size.height) * heightToBeUsed;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                widthToBeUsed,
                                heightToBeUsed);
        
        
        mBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                             0,
                                                                             self.frame.size.width,
                                                                             self.frame.size.height)];
        mBackgroundImageView.image = backgroundImage;
        [self addSubview:mBackgroundImageView];
        
        
        
        
        
        mRecipeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1,
                                                                         1,
                                                                         self.frame.size.width - 2,
                                                                         self.frame.size.height - 2)];
        mRecipeImageView.contentMode = UIViewContentModeScaleAspectFit;
        mRecipeImageView.clipsToBounds = YES;
        [self addSubview:mRecipeImageView];
        
        
    }
    return self;
}

- (void)dealloc {
    
    [mRecipeImageView release];
    [mBackgroundImageView release];
    [super dealloc];
}



- (void)updateForRecipe:(Recipe *)recipeObject
{
    UIImage *recipeImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:[recipeObject pngImageFileName] andAddIfRequired:NO];
    if(recipeImage)
    {
        mRecipeImageView.image = recipeImage;
    }
    else
    {
        mRecipeImageView.image = nil;
        
        if([viewDelegate respondsToSelector:@selector(recipeImageView:needsImageReloadForRecipe:)])
        {
            [viewDelegate recipeImageView:self needsImageReloadForRecipe:recipeObject];
        }
    }
}

- (void)updateRecipeImage:(UIImage *)recipeImage
{
    mRecipeImageView.image = recipeImage;
}


@end
