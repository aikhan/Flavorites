//
//  BVRecipeTabRecipeCell.m
//  BurnettVodka
//
//  Created by admin on 8/9/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVRecipeTabRecipeCell.h"
#import "UtilityManager.h"


#define kExtraPaddingRight 25


@interface BVRecipeTabRecipeCell ()

+ (UIImage *)backgroundImage;
+ (UIImage *)headerImage;
+ (UIImage *)footerImage;

@end


@implementation BVRecipeTabRecipeCell


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
    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"TableViewRowBackgroundRecipeForRecipeTabiOS6.png" andAddIfRequired:YES];
    return backgroundImage;
}

+ (UIImage *)headerImage
{
    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"TableViewRowFirstHeaderRecipeForRecipeTabiOS6.png" andAddIfRequired:YES];
    return backgroundImage;
}

+ (UIImage *)footerImage
{
    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"TableViewRowLastHeaderRecipeForRecipeTabiOS6.png" andAddIfRequired:YES];
    return backgroundImage;
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andCellPosition:(BVRecipeCellPosition)cellPosition
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier andCellPosition:cellPosition];
    if (self)
    {
        // Initialization code
        
        
        UIImage *backgroundImage = [BVRecipeTabRecipeCell backgroundImage];
        mBackgroundImageView.image = backgroundImage;
        
        
        switch (cellPosition)
        {
            case BVRecipeCellPositionFirst:
            {
                UIImage *headerImage = [BVRecipeTabRecipeCell headerImage];
                mHeaderImageView.image = headerImage;
                
                break;
            }
                
            case BVRecipeCellPositionLast:
            {
                UIImage *footerImage = [BVRecipeTabRecipeCell footerImage];
                mFooterImageView.image = footerImage;

                break;
            }
                
            case BVRecipeCellPositionFirstAndLast:
            {
                UIImage *headerImage = [BVRecipeTabRecipeCell headerImage];
                mHeaderImageView.image = headerImage;
                
                UIImage *footerImage = [BVRecipeTabRecipeCell footerImage];
                mFooterImageView.image = footerImage;
                
                break;
            }
                
                
            default:
                break;
        }
        
        
        
        // Recipe Title
        CGFloat widthAvailableForRecipeTitle = mRecipeTitleLabel.frame.size.width - kExtraPaddingRight;
        NSString *sampleRecipeTitleText = @"Recipe";
        CGSize recipeTitleSize = [sampleRecipeTitleText sizeWithFont:mRecipeTitleLabel.font constrainedToSize:CGSizeMake(widthAvailableForRecipeTitle, 9999) lineBreakMode:UILineBreakModeWordWrap];
        mRecipeTitleLabel.frame = CGRectMake(mRecipeTitleLabel.frame.origin.x,
                                             mRecipeTitleLabel.frame.origin.y,
                                             widthAvailableForRecipeTitle,
                                             recipeTitleSize.height);
        
        
        
        mSeperatorLineView.frame = CGRectMake(mSeperatorLineView.frame.origin.x,
                                              mSeperatorLineView.frame.origin.y,
                                              mSeperatorLineView.frame.size.width - kExtraPaddingRight,
                                              mSeperatorLineView.frame.size.height);
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
