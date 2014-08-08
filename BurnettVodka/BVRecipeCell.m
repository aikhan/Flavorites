//
//  BVRecipeCell.m
//  BurnettVodka
//
//  Created by admin on 7/18/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVRecipeCell.h"
#import "BVRatingStarView.h"
#import "UtilityManager.h"
#import "Flavor.h"


#define kPaddingLeft 13
#define kPaddingRight 13
#define kPaddingTop 5
#define kPaddingBottom 5

#define kRecipeTitleYCoordinateAdjustment 6


#define kGapBetweenRecipeImageViewAndRecipeTitle 14
#define kGapBetweenRecipeTitleAndFlavorTitle 2
#define kGapBetweenRecipeFlavorTitleAndStarView 6
#define kGapBetweenStarViewAndVotes 6


@interface BVRecipeCell ()

+ (UIImage *)backgroundImage;
+ (UIImage *)headerImage;
+ (UIImage *)footerImage;

@end



@implementation BVRecipeCell

@synthesize cellDelegate;

+ (CGFloat)rowHeightOfCellWithCellPosition:(BVRecipeCellPosition)cellPosition
{
    CGFloat rowHeight = 0;
    
    switch (cellPosition)
    {
        case BVRecipeCellPositionSandwiched:
        {
            UIImage *backgroundImage = [self backgroundImage];
            rowHeight = backgroundImage.size.height;
            break;
        }
            
        case BVRecipeCellPositionFirst:
        {
            UIImage *headerImage = [self headerImage];
            UIImage *backgroundImage = [self backgroundImage];
            rowHeight = headerImage.size.height + backgroundImage.size.height;
            break;
        }
            
        case BVRecipeCellPositionLast:
        {
            UIImage *backgroundImage = [self backgroundImage];
            UIImage *footerImage = [self footerImage];
            rowHeight = backgroundImage.size.height + footerImage.size.height;
            break;
        }
            
        case BVRecipeCellPositionFirstAndLast:
        {
            UIImage *headerImage = [self headerImage];
            UIImage *backgroundImage = [self backgroundImage];
            UIImage *footerImage = [self footerImage];
            rowHeight = headerImage.size.height + backgroundImage.size.height + footerImage.size.height;
            break;
        }
            
        default:
            break;
    }
    
    
    return rowHeight;
}

+ (UIImage *)backgroundImage
{
    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"TableViewRowBackgroundRecipe.png" andAddIfRequired:YES];
    return backgroundImage;
}

+ (UIImage *)headerImage
{
    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"TableViewRowFirstHeaderRecipe.png" andAddIfRequired:YES];
    return backgroundImage;
}

+ (UIImage *)footerImage
{
    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"TableViewRowLastHeaderRecipe.png" andAddIfRequired:YES];
    return backgroundImage;
}





- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        
        UIImage *backgroundImage = [BVRecipeCell backgroundImage];
        
        
        
        
        // The Container View
        mContainerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  backgroundImage.size.width,
                                                                  backgroundImage.size.height)];
        mContainerView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:mContainerView];
        
        
        
        
        // Create Background Image View
        mBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                             0,
                                                                             backgroundImage.size.width,
                                                                             backgroundImage.size.height)];
        mBackgroundImageView.image = backgroundImage;
       // [mContainerView addSubview:mBackgroundImageView];
        
        
    
        
        
        
        // Recipe Image View
        CGFloat heightAvailable = mContainerView.frame.size.height - kPaddingTop - kPaddingBottom;
        mRecipeImageView = [[BVRecipeImageView alloc] initWithFrame:CGRectMake(kPaddingLeft,
                                                                               kPaddingTop,
                                                                               0,
                                                                               heightAvailable)];
        mRecipeImageView.viewDelegate = self;
        [mContainerView addSubview:mRecipeImageView];
        
        
        
        
        // Recipe Title
        CGFloat widthAvailableForRecipeTitle = backgroundImage.size.width - (mRecipeImageView.frame.origin.x + mRecipeImageView.frame.size.width + kGapBetweenRecipeImageViewAndRecipeTitle + kPaddingRight);
        NSString *sampleRecipeTitleText = @"Recipe";
        UIFont *recipeTitleFont = [UtilityManager fontGetRegularFontOfSize:23];
        CGSize recipeTitleSize = [sampleRecipeTitleText sizeWithFont:recipeTitleFont constrainedToSize:CGSizeMake(widthAvailableForRecipeTitle, 9999) lineBreakMode:UILineBreakModeWordWrap];
        mRecipeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(mRecipeImageView.frame.origin.x + mRecipeImageView.frame.size.width + kGapBetweenRecipeImageViewAndRecipeTitle,
                                                                      mRecipeImageView.frame.origin.y + kRecipeTitleYCoordinateAdjustment,
                                                                      widthAvailableForRecipeTitle,
                                                                      recipeTitleSize.height)];
        mRecipeTitleLabel.font = recipeTitleFont;
        mRecipeTitleLabel.text = @"";
        mRecipeTitleLabel.backgroundColor = [UIColor clearColor];
        mRecipeTitleLabel.textColor = [UIColor whiteColor];
                                       //colorWithRed:0 green:(73.0/256.0) blue:(144.0/256.0) alpha:1];
        
        if([mRecipeTitleLabel respondsToSelector:@selector(minimumScaleFactor)])
        {
            mRecipeTitleLabel.minimumScaleFactor = 0.3;
        }
        else
        {
            mRecipeTitleLabel.minimumFontSize = 3;
        }
        
        [mRecipeTitleLabel setAdjustsFontSizeToFitWidth:YES];
        [mContainerView addSubview:mRecipeTitleLabel];
        
        
        
        
        
        
        // Flavor Title
        CGFloat widthAvailableForFlavorTitle = widthAvailableForRecipeTitle;
        NSString *sampleFlavorTitleText = @"Flavor";
        UIFont *flavorTitleFont = [UtilityManager fontGetRegularFontOfSize:13];
        CGSize flavorTitleSize = [sampleFlavorTitleText sizeWithFont:flavorTitleFont constrainedToSize:CGSizeMake(widthAvailableForFlavorTitle, 9999) lineBreakMode:UILineBreakModeWordWrap];
        mFlavorTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(mRecipeTitleLabel.frame.origin.x,
                                                                      mRecipeTitleLabel.frame.origin.y + mRecipeTitleLabel.frame.size.height + kGapBetweenRecipeTitleAndFlavorTitle,
                                                                      widthAvailableForFlavorTitle,
                                                                      flavorTitleSize.height)];
        mFlavorTitleLabel.font = flavorTitleFont;
        mFlavorTitleLabel.text = @"";
        mFlavorTitleLabel.backgroundColor = [UIColor clearColor];
        mFlavorTitleLabel.textColor = [UIColor whiteColor];
        if([mFlavorTitleLabel respondsToSelector:@selector(minimumScaleFactor)])
        {
            mFlavorTitleLabel.minimumScaleFactor = 0.3;
        }
        else
        {
            mFlavorTitleLabel.minimumFontSize = 4;
        }
        [mFlavorTitleLabel setAdjustsFontSizeToFitWidth:YES];
        [mContainerView addSubview:mFlavorTitleLabel];
        
        
        
        
        // Star Rating View
        mRatingStarView = [[BVRatingStarView alloc] initWithFrame:CGRectMake(mRecipeTitleLabel.frame.origin.x,
                                                                             mFlavorTitleLabel.frame.origin.y + mFlavorTitleLabel.frame.size.height + kGapBetweenRecipeFlavorTitleAndStarView,
                                                                             0,
                                                                             0)];
        [mContainerView addSubview:mRatingStarView];
        
        
        
        
        
        // Votes Label
        NSString *sampleVotesText = @"(99999999)";
        UIFont *votesTitleFont = [UtilityManager fontGetRegularFontOfSize:11];
        CGSize votesSize = [sampleVotesText sizeWithFont:votesTitleFont];
        mVotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(mRatingStarView.frame.origin.x + mRatingStarView.frame.size.width + kGapBetweenStarViewAndVotes,
                                                                mRatingStarView.frame.origin.y + mRatingStarView.frame.size.height - votesSize.height + 1,
                                                                votesSize.width,
                                                                votesSize.height)];
        mVotesLabel.font = votesTitleFont;
        mVotesLabel.text = @"";
        mVotesLabel.backgroundColor = [UIColor clearColor];
        mVotesLabel.textColor =  [UIColor whiteColor];
        [mContainerView addSubview:mVotesLabel];
        
        
        
        
        
        
        // Seperator Line
        mSeperatorLineView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeft - 5,
                                                                      mContainerView.frame.size.height - 1,
                                                                      backgroundImage.size.width - (kPaddingLeft - 5 + kPaddingRight - 5),
                                                                      1)];
        mSeperatorLineView.backgroundColor = [UIColor colorWithRed:(212.0/256.0) green:(212.0/256.0) blue:(212.0/256.0) alpha:1.0];
        [mContainerView addSubview:mSeperatorLineView];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andCellPosition:(BVRecipeCellPosition)cellPosition
{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        
        switch (cellPosition)
        {
            case BVRecipeCellPositionFirst:
            {
                UIImage *headerImage = [BVRecipeCell headerImage];
                mHeaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                 0,
                                                                                 headerImage.size.width,
                                                                                 headerImage.size.height)];
                mHeaderImageView.image = headerImage;
               // [self.contentView addSubview:mHeaderImageView];
                
                
                
                
                mContainerView.frame = CGRectMake(0,
                                                  mHeaderImageView.frame.origin.y + mHeaderImageView.frame.size.height,
                                                  mContainerView.frame.size.width,
                                                  mContainerView.frame.size.height);
                
                break;
            }
                
            case BVRecipeCellPositionLast:
            {
                UIImage *footerImage = [BVRecipeCell footerImage];
                mFooterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                 mContainerView.frame.origin.y + mContainerView.frame.size.height,
                                                                                 footerImage.size.width,
                                                                                 footerImage.size.height)];
                mFooterImageView.image = footerImage;
                //[self.contentView addSubview:mFooterImageView];
                
                
                [mSeperatorLineView removeFromSuperview];
                [mSeperatorLineView release];
                mSeperatorLineView = nil;
                
                break;
            }
                
            case BVRecipeCellPositionFirstAndLast:
            {
                UIImage *headerImage = [BVRecipeCell headerImage];
                mHeaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                 0,
                                                                                 headerImage.size.width,
                                                                                 headerImage.size.height)];
                mHeaderImageView.image = headerImage;
                //[self.contentView addSubview:mHeaderImageView];
                
                
                
                
                mContainerView.frame = CGRectMake(0,
                                                  mHeaderImageView.frame.origin.y + mHeaderImageView.frame.size.height,
                                                  mContainerView.frame.size.width,
                                                  mContainerView.frame.size.height);
                
                UIImage *footerImage = [BVRecipeCell footerImage];
                mFooterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                 mContainerView.frame.origin.y + mContainerView.frame.size.height,
                                                                                 footerImage.size.width,
                                                                                 footerImage.size.height)];
                mFooterImageView.image = footerImage;
                //[self.contentView addSubview:mFooterImageView];
                
                break;
            }
                
                
            default:
                break;
        }
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    
    [mContainerView release];
    [mSeperatorLineView release];
    [mRecipeImageView release];
    [mRatingStarView release];
    [mHeaderImageView release];
    [mFooterImageView release];
    [mBackgroundImageView release];
    [mRecipeTitleLabel release];
    [mFlavorTitleLabel release];
    [mVotesLabel release];
    [super dealloc];
}



- (void)updateCellWithRecipe:(Recipe *)recipe
{
    [mRecipeImageView updateForRecipe:recipe];
    
    
    mRecipeTitleLabel.text = [recipe title];
    
    
    NSString *flavorTitle = [NSString stringWithFormat:@"Burnett's %@ Vodka", recipe.flavor.title];
    mFlavorTitleLabel.text = flavorTitle;
    if ([flavorTitle isEqualToString:@"Burnett's Ruby Red Grapefruit Vodka"]) {
        mFlavorTitleLabel.font = [UtilityManager fontGetRegularFontOfSize:12];
    }
    
    CGFloat recipeRating = [recipe.ratingValue floatValue];
    [mRatingStarView updateViewWithRatingOutOfFive:recipeRating];
    
    
    NSInteger recipeVotes = [recipe.ratingCount integerValue];
    NSString *votesString = [NSString stringWithFormat:@"(%d)", recipeVotes];
    mVotesLabel.text = votesString;
}

- (void)updateCellWithRecipeInfoDictionary:(NSDictionary *)recipeDic
{
    NSString *recipeTitle = @"BluePom Martini";
    mRecipeTitleLabel.text = recipeTitle;
    
    
    NSString *flavorTitle = @"Burnett's Blueberry Vodka";
    mFlavorTitleLabel.text = flavorTitle;
    
    
    CGFloat recipeRating = 4.0;
    [mRatingStarView updateViewWithRatingOutOfFive:recipeRating];
    
    
    NSInteger recipeVotes = 12;
    NSString *votesString = [NSString stringWithFormat:@"(%d)", recipeVotes];
    mVotesLabel.text = votesString;
}

- (void)updateRecipeImageWithImage:(UIImage *)recipeImage
{
    [mRecipeImageView updateRecipeImage:recipeImage];
}


- (void)recipeImageView:(BVRecipeImageView *)recipeImageView needsImageReloadForRecipe:(Recipe *)recipeObject
{
    if([cellDelegate respondsToSelector:@selector(recipeCell:needsImageReloadForRecipe:)])
    {
        [cellDelegate recipeCell:self needsImageReloadForRecipe:recipeObject];
    }
}





@end