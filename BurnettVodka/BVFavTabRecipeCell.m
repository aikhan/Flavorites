//
//  BVFavTabRecipeCell.m
//  BurnettVodka
//
//  Created by admin on 7/24/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVFavTabRecipeCell.h"
#import "UtilityManager.h"



#define kRemoveFromFavoriteViewXCoordinate 5
#define kRemoveFromFavoriteViewWidth 310
#define kRemoveFromFavoriteViewGapBetweenTitleAndDescription 3
#define kRemoveFromFavoriteViewGapBetweenDescriptionAndButtons 0
#define kRemoveFromFavoriteViewGapBetweenButtons 23

@implementation BVRemoveFromFavoriteView

@synthesize viewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Custom initialization
        
        
        self.clipsToBounds = YES;
        
        
        mTranslucentBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                              0,
                                                                              self.frame.size.width,
                                                                              self.frame.size.height)];
        mTranslucentBackgroundView.backgroundColor = [UIColor whiteColor];
        [self addSubview:mTranslucentBackgroundView];
        mOriginalFrameForTranslucentView = mTranslucentBackgroundView.frame;
        
        
        
        NSString *titleString = @"Remove From My Faves?";
        UIFont *titleFont = [UtilityManager fontGetRegularFontOfSize:17];
        CGSize titleSize = [titleString sizeWithFont:titleFont];
        mTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(roundf((self.frame.size.width - titleSize.width) / 2),
                                                                0,
                                                                titleSize.width,
                                                                titleSize.height)];
        mTitleLabel.backgroundColor = [UIColor clearColor];
        mTitleLabel.textColor = [UIColor whiteColor];
        mTitleLabel.text = titleString;
        mTitleLabel.font = titleFont;
        [self addSubview:mTitleLabel];

        
        
        
        NSString *descriptionString = @"Are you sure that you would like to remove this?";
        UIFont *descriptionFont = [UtilityManager fontGetRegularFontOfSize:14];
        CGSize descriptionSize = [descriptionString sizeWithFont:descriptionFont];
        mDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(roundf((self.frame.size.width - descriptionSize.width) / 2),
                                                                      0,
                                                                      descriptionSize.width,
                                                                      descriptionSize.height)];
        mDescriptionLabel.backgroundColor = [UIColor clearColor];
        mDescriptionLabel.textColor = [UIColor whiteColor];
                                       //colorWithRed:(161.0/256.0) green:(175.0/256.0) blue:(196.0/256.0) alpha:1];
        mDescriptionLabel.text = descriptionString;
        mDescriptionLabel.font = descriptionFont;
        [self addSubview:mDescriptionLabel];
        
        
        
        
        CGFloat sidePaddingForButtons = 10;
        UIFont *fontForButtons = [UtilityManager fontGetRegularFontOfSize:20];
        
        NSString *noString = @"No";
        CGSize noButtonSize = [noString sizeWithFont:fontForButtons];
        mNoButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               noButtonSize.width + sidePaddingForButtons + sidePaddingForButtons,
                                                               noButtonSize.height + sidePaddingForButtons + sidePaddingForButtons)];
        [mNoButton setTitle:noString forState:UIControlStateNormal];
        [mNoButton setTitleColor:[UIColor colorWithRed:0 green:(73.0/256.0) blue:(144.0/256.0) alpha:1] forState:UIControlStateNormal];
        [mNoButton addTarget:self action:@selector(noButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        mNoButton.titleLabel.font = fontForButtons;
        [self addSubview:mNoButton];

        
        NSString *yesString = @"Yes";
        CGSize yesButtonSize = [yesString sizeWithFont:fontForButtons];
        mYesButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               yesButtonSize.width + sidePaddingForButtons + sidePaddingForButtons,
                                                               yesButtonSize.height + sidePaddingForButtons + sidePaddingForButtons)];
        [mYesButton setTitle:yesString forState:UIControlStateNormal];
        [mYesButton setTitleColor:[UIColor colorWithRed:0 green:(73.0/256.0) blue:(144.0/256.0) alpha:1] forState:UIControlStateNormal];
        [mYesButton addTarget:self action:@selector(yesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        mYesButton.titleLabel.font = fontForButtons;
        [self addSubview:mYesButton];

        
        
        
        // Now that all the elements have been built and we know their heights and widths, no we need to position them correctly.
        
        CGFloat yCoordinateForTitleLabel = roundf((self.frame.size.height - (mTitleLabel.frame.size.height + kRemoveFromFavoriteViewGapBetweenTitleAndDescription + mDescriptionLabel.frame.size.height + kRemoveFromFavoriteViewGapBetweenDescriptionAndButtons + mYesButton.frame.size.height)) / 2);
        mTitleLabel.frame = CGRectMake(mTitleLabel.frame.origin.x,
                                       yCoordinateForTitleLabel,
                                       mTitleLabel.frame.size.width,
                                       mTitleLabel.frame.size.height);
        mOriginalFrameForTitleLabel = mTitleLabel.frame;

        
        
        mDescriptionLabel.frame = CGRectMake(mDescriptionLabel.frame.origin.x,
                                             mTitleLabel.frame.origin.y + mTitleLabel.frame.size.height + kRemoveFromFavoriteViewGapBetweenTitleAndDescription,
                                             mDescriptionLabel.frame.size.width,
                                             mDescriptionLabel.frame.size.height);
        mOriginalFrameForDescriptionLabel = mDescriptionLabel.frame;
        
        

        CGFloat xCoordinateForNoButton = roundf((self.frame.size.width - (mNoButton.frame.size.width + kRemoveFromFavoriteViewGapBetweenButtons + mYesButton.frame.size.width)) / 2);
        mNoButton.frame = CGRectMake(xCoordinateForNoButton,
                                     mDescriptionLabel.frame.origin.y + mDescriptionLabel.frame.size.height + kRemoveFromFavoriteViewGapBetweenDescriptionAndButtons,
                                     mNoButton.frame.size.width,
                                     mNoButton.frame.size.height);
        mOriginalFrameForNoButton = mNoButton.frame;
        
        
        mYesButton.frame = CGRectMake(mNoButton.frame.origin.x + mNoButton.frame.size.width + kRemoveFromFavoriteViewGapBetweenButtons,
                                      mNoButton.frame.origin.y,
                                      mYesButton.frame.size.width,
                                      mYesButton.frame.size.height);
        mOriginalFrameForYesButton = mYesButton.frame;
        
    }
    return self;
}


- (void)dealloc {

    [mTranslucentBackgroundView release];
    [mTitleLabel release];
    [mDescriptionLabel release];
    [mNoButton release];
    [mYesButton release];
    [super dealloc];
}


- (void)show
{
    mTranslucentBackgroundView.alpha = 1.0;
    
    mTitleLabel.frame = mOriginalFrameForTitleLabel;
    
    mDescriptionLabel.frame = mOriginalFrameForDescriptionLabel;
    
    mNoButton.frame = mOriginalFrameForNoButton;
    
    mYesButton.frame = mOriginalFrameForYesButton;
}

- (void)hide
{
    mTranslucentBackgroundView.alpha = 0.0;
        
    mTitleLabel.frame = CGRectMake(self.frame.size.width,
                                   mOriginalFrameForTitleLabel.origin.y,
                                   mOriginalFrameForTitleLabel.size.width,
                                   mOriginalFrameForTitleLabel.size.height);
    
    mDescriptionLabel.frame = CGRectMake(self.frame.size.width,
                                         mOriginalFrameForDescriptionLabel.origin.y,
                                         mOriginalFrameForDescriptionLabel.size.width,
                                         mOriginalFrameForDescriptionLabel.size.height);
    
    mNoButton.frame = CGRectMake(self.frame.size.width,
                                 mOriginalFrameForNoButton.origin.y,
                                 mOriginalFrameForNoButton.size.width,
                                 mOriginalFrameForNoButton.size.height);
    
    mYesButton.frame = CGRectMake(self.frame.size.width,
                                  mOriginalFrameForYesButton.origin.y,
                                  mOriginalFrameForYesButton.size.width,
                                  mOriginalFrameForYesButton.size.height);
}



- (void)noButtonClicked:(id)sender
{
    if([viewDelegate respondsToSelector:@selector(userTappedNOOnBVRemoveFromFavoriteView:)])
    {
        [viewDelegate userTappedNOOnBVRemoveFromFavoriteView:self];
    }
}

- (void)yesButtonClicked:(id)sender
{
    if([viewDelegate respondsToSelector:@selector(userTappedYESOnBVRemoveFromFavoriteView:)])
    {
        [viewDelegate userTappedYESOnBVRemoveFromFavoriteView:self];
    }
}


@end




@interface BVFavTabRecipeCell ()

- (void)resetDeleteView;

@end


@implementation BVFavTabRecipeCell

@synthesize favTabRecipeCellDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andCellPosition:(BVRecipeCellPosition)cellPosition
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier andCellPosition:cellPosition];
    if (self)
    {
        // Initialization code
        
        UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightToDelete:)];
        [self addGestureRecognizer:rightSwipeGestureRecognizer];
        [rightSwipeGestureRecognizer release];
        
        
        UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftToDelete:)];
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:leftSwipeGestureRecognizer];
        [leftSwipeGestureRecognizer release];
    }
    return self;
}

- (void)dealloc {
    
    [mRemoveFroFavView release];
    [super dealloc];
}




#pragma mark - Superclass Overide Methods

- (void)updateCellWithRecipe:(Recipe *)recipe
{
    [super updateCellWithRecipe:recipe];
    
    [self resetDeleteView];
}


#pragma mark - Helper Methods

- (BVRemoveFromFavoriteView *)deleteView
{
    if(mRemoveFroFavView == nil)
    {
        mRemoveFroFavView = [[BVRemoveFromFavoriteView alloc] initWithFrame:CGRectMake(kRemoveFromFavoriteViewXCoordinate,
                                                                                       0,
                                                                                       kRemoveFromFavoriteViewWidth,
                                                                                       mContainerView.frame.size.height)];
        mRemoveFroFavView.viewDelegate = self;
        [mContainerView addSubview:mRemoveFroFavView];
    }
    
    return mRemoveFroFavView;
}


- (void)resetDeleteView
{
    BVRemoveFromFavoriteView *deleteView = [self deleteView];
    
    [deleteView hide];
    
    deleteView.hidden = YES;
    
    isDeleteViewActive = NO;
    
    if([favTabRecipeCellDelegate respondsToSelector:@selector(favTabRecipeCell:deleteViewActive:)])
    {
        [favTabRecipeCellDelegate favTabRecipeCell:self deleteViewActive:NO];
    }
}


#pragma mark - UIGestureRecognizer Action Methods

- (void)swipeRightToDelete:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if(isDeleteViewActive)
    {
        [self hideDeleteViewAnimated:YES];
    }
    else
    {
        [self showDeleteViewAnimated:YES];
    }
}

- (void)swipeLeftToDelete:(UISwipeGestureRecognizer *)gestureRecognizer
{    
    if(isDeleteViewActive)
    {
        [self hideDeleteViewAnimated:YES];
    }
    else
    {
        [self showDeleteViewAnimated:YES];
    }
}




#pragma mark - BVRemoveFromFavoriteView Delegate Methods

- (void)userTappedNOOnBVRemoveFromFavoriteView:(BVRemoveFromFavoriteView *)view
{
    [self hideDeleteViewAnimated:YES];
}

- (void)userTappedYESOnBVRemoveFromFavoriteView:(BVRemoveFromFavoriteView *)view
{
    if([favTabRecipeCellDelegate respondsToSelector:@selector(favTabRecipeCellUserConfirmedDeletion:)])
    {
        [favTabRecipeCellDelegate favTabRecipeCellUserConfirmedDeletion:self];
    }
}



#pragma mark - Public Methods

- (void)showDeleteViewAnimated:(BOOL)animated
{
    if([favTabRecipeCellDelegate respondsToSelector:@selector(favTabRecipeCell:deleteViewActive:)])
    {
        [favTabRecipeCellDelegate favTabRecipeCell:self deleteViewActive:YES];
    }
    
    BVRemoveFromFavoriteView *deleteView = [self deleteView];
    deleteView.hidden = NO;
    
    if(animated)
    {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             
                             [deleteView show];
                             
                         }
                         completion:^(BOOL finished) {
                             
                             if(finished)
                             {
                                 isDeleteViewActive = YES;
                             }
                             
                         }];
    }
    else
    {
        [deleteView show];
        isDeleteViewActive = YES;
    }
}

- (void)hideDeleteViewAnimated:(BOOL)animated
{
    if([favTabRecipeCellDelegate respondsToSelector:@selector(favTabRecipeCell:deleteViewActive:)])
    {
        [favTabRecipeCellDelegate favTabRecipeCell:self deleteViewActive:NO];
    }
    
    
    BVRemoveFromFavoriteView *deleteView = [self deleteView];
    
    if(animated)
    {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             [deleteView hide];
                             
                         }
                         completion:^(BOOL finished) {
                             
                             if(finished)
                             {
                                 deleteView.hidden = YES;
                                 isDeleteViewActive = NO;
                             }
                         }];
    }
    else
    {
        [deleteView hide];
        deleteView.hidden = YES;
        isDeleteViewActive = NO;
    }
}

@end
