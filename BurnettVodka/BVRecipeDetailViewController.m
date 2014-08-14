//
//  BVRecipeDetailViewController.m
//  BurnettVodka
//
//  Created by admin on 7/19/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVRecipeDetailViewController.h"
#import "UtilityManager.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "DataManager.h"
#import "BVApp.h"
#import "BVRatingStarView.h"
#import "Constants.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"


#define kAlertViewForMail 1


#define kPaddingLeft 20
#define kPaddingRight 20
#define kPaddingTop 10
#define kPaddingBottom 10


#define kGapBetweenTitleAndSeperator 10
#define kGapBetweenSeperatorAndImage 5
#define kGapBetweenImageAndRateFavView 5
#define kGapBetweenRateFavViewAndBottomView 5



#define kRecipeImageViewHeightIncludingTopAndBottomPadding 174

#define kRatingViewWidth 151
#define kRatingViewGapBetweenRatingLabelAndStarView 4

#define kBottomViewPaddingLeft 10
#define kBottomViewPaddingRight 10
#define kBottomViewPaddingTop 7
#define kBottomViewPaddingBottom 12

#define kBottomViewGapBetweenSectionTitleAndSeperator 3
#define kBottomViewGapBetweenSeperatorAndSectionContent 3
#define kBottomViewGapBetweenTwoSections 10
#define kBottomViewGapBetweenTwoBulletPoints 8
#define kBottomViewGapBetweenBulletPointIconAndText 7

#define kRemoveFromFavViewHeight 50
#define kRemoveFromFavViewPaddingTop 5
#define kRemoveFromFavViewGapBetweenMessageAndButtons 0
#define kRemoveFromFavViewGapBetweenButtons 23

static NSString *event = @"Recipe Detail";
@interface BVRecipeDetailAddToFavoriteView ()

- (UITapGestureRecognizer *)swipeGestureToRemoveFromFaves;

@end


@implementation BVRecipeDetailAddToFavoriteView

@synthesize viewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        mAddToFavButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     self.frame.size.width,
                                                                     self.frame.size.height)];
        [mAddToFavButton addTarget:self action:@selector(addToFav:) forControlEvents:UIControlEventTouchUpInside];
        [mAddToFavButton setTitleColor:[UIColor whiteColor] forState:
         UIControlStateNormal];
        mAddToFavButton.titleLabel.font = [UtilityManager fontGetRegularFontOfSize:14];
        
        [self addSubview:mAddToFavButton];
    }
    return self;
}

- (void)dealloc {
    
    [mSwipeGestureRecognizer release];
    [mAddToFavButton release];
    [super dealloc];
}

- (void)addToFav:(id)sender
{
    if([viewDelegate respondsToSelector:@selector(recipeDetailAddToFavoriteViewUserTappedAddToFavoriteButton:)])
    {
        [viewDelegate recipeDetailAddToFavoriteViewUserTappedAddToFavoriteButton:self];
    }
}

- (void)updateViewToShowAdded:(BOOL)isAdded animated:(BOOL)animated
{
    // Check the state
    if(isAdded)
    {
        if([[mAddToFavButton titleForState:UIControlStateNormal] isEqualToString:@" My Faves"])
        {
            return;
        }
    }
    else
    {
        if([[mAddToFavButton titleForState:UIControlStateNormal] isEqualToString:@" Add to Favorites"])
        {
            return;
        }
    }
    
    if(animated)
    {
        CGFloat origninalXCoordinateOfButton = mAddToFavButton.frame.origin.x;
        
        [UIView animateWithDuration:0.2
                         animations:^{
                            
                             mAddToFavButton.frame = CGRectMake(self.frame.size.width,
                                                                mAddToFavButton.frame.origin.y,
                                                                mAddToFavButton.frame.size.width,
                                                                mAddToFavButton.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             
                             NSString *title = @"";
                             
                             if(isAdded)
                             {
                                 title = @" My Faves";
                                 mAddToFavButton.userInteractionEnabled = NO;
                                 
                                 UIImage *addedInFavImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"AddedInMyFaves.png" andAddIfRequired:YES];
                                // [mAddToFavButton setImage:addedInFavImage forState:UIControlStateNormal];
                                 
                                 UITapGestureRecognizer *gesture = [self swipeGestureToRemoveFromFaves];
                                 [self addGestureRecognizer:gesture];
                             }
                             else
                             {
                                 title = @" Add to Favorites";
                                 mAddToFavButton.userInteractionEnabled = YES;
                                 
                                 UIImage *addToFavImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"AddToMyFaves.png" andAddIfRequired:YES];
                                // [mAddToFavButton setImage:addToFavImage forState:UIControlStateNormal];
                                 
                                 UITapGestureRecognizer *gesture = [self swipeGestureToRemoveFromFaves];
                                 [self removeGestureRecognizer:gesture];
                             }
                             
                             [mAddToFavButton setTitle:title forState:UIControlStateNormal];
                             
                             [UIView animateWithDuration:0.2
                                              animations:^{
                                                 
                                                  mAddToFavButton.frame = CGRectMake(origninalXCoordinateOfButton,
                                                                                     mAddToFavButton.frame.origin.y,
                                                                                     mAddToFavButton.frame.size.width,
                                                                                     mAddToFavButton.frame.size.height);
                                              }];
                         }];
    }
    else
    {
        NSString *title = @"";
        
        if(isAdded)
        {
            title = @" My Faves";
            mAddToFavButton.userInteractionEnabled = NO;
            
            UIImage *addedInFavImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"AddedInMyFaves.png" andAddIfRequired:YES];
          //  [mAddToFavButton setImage:addedInFavImage forState:UIControlStateNormal];
            
            UITapGestureRecognizer *gesture = [self swipeGestureToRemoveFromFaves];
            [self addGestureRecognizer:gesture];
        }
        else
        {
            title = @" Add to Favorites";
            mAddToFavButton.userInteractionEnabled = YES;
            
            UIImage *addToFavImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"AddToMyFaves.png" andAddIfRequired:YES];
            //[mAddToFavButton setImage:addToFavImage forState:UIControlStateNormal];
            
            UITapGestureRecognizer *gesture = [self swipeGestureToRemoveFromFaves];
            [self removeGestureRecognizer:gesture];
        }
        
        [mAddToFavButton setTitle:title forState:UIControlStateNormal];
    }
}


- (UITapGestureRecognizer *)swipeGestureToRemoveFromFaves
{
    if(mSwipeGestureRecognizer == nil)
    {
        mSwipeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    }
    
    return mSwipeGestureRecognizer;
}

- (void)swipeRight:(UITapGestureRecognizer *)gesture
{
    if([viewDelegate respondsToSelector:@selector(recipeDetailAddToFavoriteViewUserSwippedToRemoveFromFavorites:)])
    {
        [viewDelegate recipeDetailAddToFavoriteViewUserSwippedToRemoveFromFavorites:self];
    }
}

@end




@interface BVRecipeDetailViewController ()

- (void)loadUserInterface;
- (UIView *)bottomViewWithIngredientsArray:(NSArray *)arrayOfIngredients andProcess:(NSString *)processString andMinimumHieght:(CGFloat)minimunHeightOfBottomView;
- (UIView *)centerViewInBottomViewWithIngredientsArray:(NSArray *)arrayOfIngredients andProcessString:(NSString *)processString andAvailableWidth:(CGFloat)availableWidth andMinimumHeight:(CGFloat)minimumHeight;
- (UIView *)ingredientsViewWithIngredientsArray:(NSArray *)arrayOfIngredients andAvailableWidth:(CGFloat)availableWidth andFont:(UIFont *)font;
- (void)updateRatingTitleLabel;
- (UIView *)viewForRemoveFromFavorite;

- (void)shareRecipeOnMessage;
- (void)shareRecipeOnMail;
- (void)shareRecipeOnTwitter;
- (void)shareRecipeOnFacebook;

@end

@implementation BVRecipeDetailViewController
UIView *myViewForBackButton;
UIView *myViewForShareButton;
- (id)initWithRecipe:(Recipe *)recipeObject
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        mRecipeObject = [recipeObject retain];
        
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 // iOS 7.0 supported
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
#endif
    }
    return self;
}


- (void)loadView {
    
    [super loadView];
    
    CGFloat iOS7OffsetAdjustmentForStatusBar = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        iOS7OffsetAdjustmentForStatusBar = 20;
    }
    
    self.view.frame = CGRectMake(0,
                                 0,
                                 self.navigationController.view.frame.size.width,
                                 self.navigationController.view.frame.size.height - self.navigationController.navigationBar.frame.size.height + iOS7OffsetAdjustmentForStatusBar);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeRemovedFromFavorites:) name:kNotificationRecipeRemovedFromFavoriteFromFavoriteTab object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeRemovedFromFavoritesFromRecipeDetailScreen:) name:kNotificationRecipeRemovedFromFavoriteFromRecipeDetailScreen object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeRatingsDataChanged:) name:kNotificationRecipeRatingsChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeAddedToFavorites:) name:kNotificationRecipeAddedToFavorite object:nil];
    
    
 //   [UtilityManager addTitle:@"Recipes" toNavigationItem:self.navigationItem];
    
    
    UIBarButtonItem *backButton = [UtilityManager navigationBarBackButtonItemWithTarget:self andAction:@selector(backButtonClicked:) andHeight:self.navigationController.navigationBar.frame.size.height+20];
   // self.navigationItem.leftBarButtonItem = backButton;
    
    [self loadUserInterface];
    

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, 320, 59);
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reciepeTab.png"] forBarMetrics:UIBarMetricsDefault];
    myViewForBackButton = [[UIView alloc] initWithFrame:CGRectMake(20,12,71,36)];
    
    UIButton *mybutton = [UIButton buttonWithType: UIButtonTypeCustom];
    // [mybutton setImage:[UIImage imageNamed:@"BackBarButtonArrow.png"] forState:UIControlStateNormal];
    // [mybutton setBackgroundColor:[UIColor greenColor]];
    [mybutton setFrame:CGRectMake(0,0,71,36)];
    [mybutton setBackgroundImage:[UIImage imageNamed:@"BackBarButtonArrow.png"] forState:UIControlStateNormal];
    [mybutton addTarget:self action:@selector(backButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
    [myViewForBackButton addSubview:mybutton];
    [self.navigationController.navigationBar addSubview:myViewForBackButton];
    
    
    
    
    UIBarButtonItem *shareButton =[UtilityManager navigationBarBackButtonItemWithTarget1:self andAction:@selector(share:) andHeight:self.navigationController.navigationBar.frame.size.height+20];
    //self.navigationItem.rightBarButtonItem = shareButton;
    
    myViewForShareButton = [[UIView alloc] initWithFrame:CGRectMake(229,12,71,36)];
    
    UIButton *mybuttonShare = [UIButton buttonWithType: UIButtonTypeCustom];
    [mybuttonShare setFrame:CGRectMake(0,0,71,36)];
    [mybuttonShare setBackgroundImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [mybuttonShare addTarget:self action:@selector(share:) forControlEvents: UIControlEventTouchUpInside];
    [myViewForShareButton addSubview:mybuttonShare];
    [self.navigationController.navigationBar addSubview:myViewForShareButton];
}
- (void)viewWillDisappear:(BOOL)animated{
    [myViewForBackButton removeFromSuperview];
    myViewForBackButton = nil;
    [myViewForBackButton dealloc];
    
    [myViewForShareButton removeFromSuperview];
    myViewForShareButton = nil;
    [myViewForShareButton dealloc];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, 320, 59);
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reciepeTab.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [mScrollView release];
    [mRemoveFromFavoriteView release];
    [mRatingTitleLabel release];
    
    [mRatingStarView release];
    [mAddToFavoriteView release];
    
    mRatingOverlayView.viewDelegate = nil;
    [mRatingOverlayView release];
    
    mShareOverlayView.viewDelegate = nil;
    [mShareOverlayView release];
    
    [mRecipeObject release];
    [super dealloc];
}


#pragma mark - UI Methods

- (void)loadUserInterface
{
    // Background Image View
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                     0,
                                                                                     self.view.frame.size.width,
                                                                                     self.view.frame.size.height)];

    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"detailbg.png" andAddIfRequired:YES];
    backgroundImageView.image = backgroundImage;
    backgroundImageView.contentMode = UIViewContentModeTop;
    [self.view addSubview:backgroundImageView];
    [backgroundImageView release];
    
    
    
    
    
    // Scroll View
    mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 self.view.frame.size.width,
                                                                 self.view.frame.size.height)];
    
    [self.view addSubview:mScrollView];

    
    
    
    
    
    
    
    

    
    
    // Recipe Title
    
    CGFloat widthAvailableForRecipeTitle = self.view.frame.size.width - kPaddingLeft - kPaddingRight;
    NSString *recipeTitleString = mRecipeObject.title;
    UIFont *recipeTitleFont = [UtilityManager fontGetRegularFontOfSize:26];
    CGSize recipeTitleSize = [recipeTitleString sizeWithFont:recipeTitleFont constrainedToSize:CGSizeMake(widthAvailableForRecipeTitle, 9999) lineBreakMode:UILineBreakModeWordWrap];
    UILabel *recipeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeft,
                                                                          kPaddingTop+10,
                                                                          widthAvailableForRecipeTitle,
                                                                          45)];
    recipeTitleLabel.text = recipeTitleString;
    recipeTitleLabel.backgroundColor = [UIColor colorWithRed:(205.0/256.0) green:(17.0/256.0) blue:(60.0/256.0) alpha:1.0];
    recipeTitleLabel.textColor = [UIColor whiteColor];
    recipeTitleLabel.font = recipeTitleFont;
    recipeTitleLabel.textAlignment = UITextAlignmentCenter;
    recipeTitleLabel.numberOfLines = 1;
    [mScrollView addSubview:recipeTitleLabel];
    [recipeTitleLabel release];
    
    
    
    
    // Seperator
    
    UIImage *topSeperatorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeDetailSeperatorAfterTitle" ofType:@"png"]];
    UIImageView *topSeperatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(roundf((self.view.frame.size.width - topSeperatorImage.size.width) / 2),
                                                                                       recipeTitleLabel.frame.origin.y + recipeTitleLabel.frame.size.height + kGapBetweenTitleAndSeperator,
                                                                                       topSeperatorImage.size.width,
                                                                                       topSeperatorImage.size.height)];
    topSeperatorImageView.image = topSeperatorImage;
    [topSeperatorImage release];
    
    //[mScrollView addSubview:topSeperatorImageView];
    [topSeperatorImageView release];
    
    
    
    
    // Recipe ImageView
    
    UIImageView *recipeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                 recipeTitleLabel.frame.origin.y + recipeTitleLabel.frame.size.height + kGapBetweenSeperatorAndImage+15,
                                                                                 self.view.frame.size.width,
                                                                                 kRecipeImageViewHeightIncludingTopAndBottomPadding - kGapBetweenSeperatorAndImage - kGapBetweenImageAndRateFavView)];
    recipeImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImage *recipeImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:[mRecipeObject pngImageFileName] andAddIfRequired:YES];
    recipeImageView.image = recipeImage;

    
    [mScrollView addSubview:recipeImageView];
    [recipeImageView release];

    
    
    
    CGFloat minimumHeightForBottomView = mScrollView.frame.size.height - (recipeImageView.frame.origin.y + recipeImageView.frame.size.height)-50;
    
    UIView *bottomView = [[self bottomViewWithIngredientsArray:[mRecipeObject arrayOfIngredients] andProcess:mRecipeObject.directions andMinimumHieght:minimumHeightForBottomView] retain];
    bottomView.frame = CGRectMake(roundf((self.view.frame.size.width - bottomView.frame.size.width) / 2),
                                  recipeImageView.frame.origin.y + recipeImageView.frame.size.height + kGapBetweenRateFavViewAndBottomView,
                                  bottomView.frame.size.width,
                                  bottomView.frame.size.height);
    [mScrollView addSubview:bottomView];
    [bottomView release];
    

    
    
    
    // Rating And Favorite Background ImageView
    UIImage *backgroundImageForRatingAndFavView = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeDetailBgForRatingAndFav" ofType:@"png"]];
    
    UIImageView *ratingAndFavBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9,
                                                                                                 bottomView.frame.origin.y + bottomView.frame.size.height + kGapBetweenImageAndRateFavView,backgroundImageForRatingAndFavView.size.width,                                                                                                 backgroundImageForRatingAndFavView.size.height)];
    ratingAndFavBackgroundImageView.image = backgroundImageForRatingAndFavView;
    [backgroundImageForRatingAndFavView release];
    
    [mScrollView addSubview:ratingAndFavBackgroundImageView];
    [ratingAndFavBackgroundImageView release];
    
    
    
    // Rating View
    
    UIView *ratingView = [[UIView alloc] initWithFrame:CGRectMake(9,
                                                                  bottomView.frame.origin.y + bottomView.frame.size.height + kGapBetweenImageAndRateFavView,
                                                                  kRatingViewWidth,
                                                                  backgroundImageForRatingAndFavView.size.height)];
    
    [mScrollView addSubview:ratingView];
    [ratingView release];
    
    
    UIButton *invisibleRatingButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                                 0,
                                                                                 ratingView.frame.size.width,
                                                                                 ratingView.frame.size.height)];
    [invisibleRatingButton addTarget:self action:@selector(ratingViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    [ratingView addSubview:invisibleRatingButton];
    [invisibleRatingButton release];
    
    

    NSString *ratingString = @"My Rating:";
    UIFont *ratingFont = [UtilityManager fontGetRegularFontOfSize:14];
    if(mRecipeObject.ratingValueSubmittedByUser == nil || [mRecipeObject.ratingValueSubmittedByUser floatValue] == 0)
    {
        ratingString = @"Rate:";
    }
    CGSize ratitngSize = [ratingString sizeWithFont:ratingFont];
    mRatingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                     roundf((ratingView.frame.size.height - ratitngSize.height) / 2),
                                                                     ratitngSize.width,
                                                                     ratitngSize.height)];
    mRatingTitleLabel.text = ratingString;
    mRatingTitleLabel.textAlignment = NSTextAlignmentCenter;
    mRatingTitleLabel.backgroundColor = [UIColor clearColor];
    mRatingTitleLabel.textColor = [UIColor whiteColor];
    mRatingTitleLabel.font = ratingFont;
    if([mRatingTitleLabel respondsToSelector:@selector(minimumScaleFactor)])
    {
        mRatingTitleLabel.minimumScaleFactor = 1.0;
    }
    else
    {
        mRatingTitleLabel.minimumFontSize = 3;
    }
    
    mRatingTitleLabel.adjustsFontSizeToFitWidth = YES;
    ratingView.backgroundColor = [UIColor clearColor];
                                  //colorWithRed:(40.0/256.0) green:(45.0/256.0) blue:(85.0/256.0) alpha:1.0];
    [ratingView addSubview:mRatingTitleLabel];

    

    
    
    
    [mRatingStarView removeFromSuperview];
    [mRatingStarView release];
    mRatingStarView = [[BVRatingStarView alloc] initWithFrame:CGRectZero andGapBetweenTwoStars:2];
    mRatingStarView.userInteractionEnabled = NO;
    [mRatingStarView updateViewWithRatingOutOfFive:[mRecipeObject.ratingValueSubmittedByUser floatValue]];
    [ratingView addSubview:mRatingStarView];
    
    
    mRatingTitleLabel.frame = CGRectMake(roundf((ratingView.frame.size.width - (mRatingTitleLabel.frame.size.width + kRatingViewGapBetweenRatingLabelAndStarView + mRatingStarView.frame.size.width)) / 2),
                                   mRatingTitleLabel.frame.origin.y,
                                   mRatingTitleLabel.frame.size.width,
                                   mRatingTitleLabel.frame.size.height);
    
    mRatingStarView.frame = CGRectMake(mRatingTitleLabel.frame.origin.x + mRatingTitleLabel.frame.size.width + kRatingViewGapBetweenRatingLabelAndStarView,
                                       roundf((ratingView.frame.size.height - mRatingStarView.frame.size.height) / 2) - 1,
                                       mRatingStarView.frame.size.width,
                                       mRatingStarView.frame.size.height);
    
    
    
    // Favorite View
    
    mAddToFavoriteView.viewDelegate = nil;
    [mAddToFavoriteView removeFromSuperview];
    [mAddToFavoriteView release];
    mAddToFavoriteView = [[BVRecipeDetailAddToFavoriteView alloc] initWithFrame:CGRectMake(ratingView.frame.origin.x + ratingView.frame.size.width,
                                                                                           bottomView.frame.origin.y + bottomView.frame.size.height + kGapBetweenImageAndRateFavView,
                                                                                           self.view.frame.size.width - (ratingView.frame.origin.x + ratingView.frame.size.width),
                                                                                           backgroundImageForRatingAndFavView.size.height)];
    mAddToFavoriteView.viewDelegate = self;
    mAddToFavoriteView.backgroundColor = [UIColor clearColor];
                                          //colorWithRed:(236.0/256.0) green:(0.0/256.0) blue:(139.0/256.0) alpha:1.0];

    if(mRecipeObject.associatedApp == [[DataManager sharedDataManager] app])
    {
        [mAddToFavoriteView updateViewToShowAdded:YES animated:NO];
    }
    else
    {
        [mAddToFavoriteView updateViewToShowAdded:NO animated:NO];
    }
    
    [mScrollView addSubview:mAddToFavoriteView];
    
    

    
    
    // Resize Content Size Of Scroll View
    mScrollView.contentSize = CGSizeMake(mScrollView.frame.size.width,
                                         ratingView.frame.origin.y + ratingView.frame.size.height + kPaddingBottom+50);
    
}


- (UIView *)bottomViewWithIngredientsArray:(NSArray *)arrayOfIngredients andProcess:(NSString *)processString andMinimumHieght:(CGFloat)minimunHeightOfBottomView
{
    // Setup Common Variables
    
    UIImage *bottomViewHeaderBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeDetailBottomBackgroundHeader" ofType:@"png"]];
    UIImage *bottomViewFooterBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeDetailBottomBackgroundFooter" ofType:@"png"]];
    

    
    
    
    
    UIView *bottomView = [[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   bottomViewHeaderBackgroundImage.size.width,
                                                                   minimunHeightOfBottomView)] autorelease];
    bottomView.backgroundColor = [UIColor clearColor];
    
    
    
    
    
    
    // Bottom View HeaderImage
    UIImageView *headerImageViewForBottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                              0,
                                                                                              bottomView.frame.size.width,
                                                                                              bottomViewHeaderBackgroundImage.size.height)];
    headerImageViewForBottomView.image = bottomViewHeaderBackgroundImage;
    [bottomView addSubview:headerImageViewForBottomView];
    [headerImageViewForBottomView release];

    
    
    
    
    // Bottom View Center View
    
    CGFloat mininumHeightForCenterView = minimunHeightOfBottomView - bottomViewHeaderBackgroundImage.size.height - bottomViewFooterBackgroundImage.size.height;
    
    UIView *centerView = [[self centerViewInBottomViewWithIngredientsArray:arrayOfIngredients andProcessString:processString andAvailableWidth:bottomView.frame.size.width andMinimumHeight:mininumHeightForCenterView] retain];
    
    centerView.frame = CGRectMake(0,
                                  headerImageViewForBottomView.frame.origin.y + headerImageViewForBottomView.frame.size.height,
                                  centerView.frame.size.width,
                                  centerView.frame.size.height);
    [bottomView addSubview:centerView];
    [centerView release];
    
    
    
    
    
    // Bottom View FooterImage
    UIImageView *footerImageViewForBottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                              centerView.frame.origin.y + centerView.frame.size.height,
                                                                                              bottomView.frame.size.width,
                                                                                              bottomViewFooterBackgroundImage.size.height)];
    footerImageViewForBottomView.image = bottomViewFooterBackgroundImage;
    [bottomView addSubview:footerImageViewForBottomView];
    [footerImageViewForBottomView release];
    
    
    
    
    // Resize Bottom View Height
    //if(bottomView.frame.size.height < (footerImageViewForBottomView.frame.origin.y + footerImageViewForBottomView.frame.size.height))
    {
        bottomView.frame = CGRectMake(bottomView.frame.origin.x,
                                      bottomView.frame.origin.y,
                                      centerView.frame.size.width,
                                      centerView.frame.size.height);
    }
    
    

    
    
    
//    // Bottom View Center View Clean Up Variables
   [bottomViewFooterBackgroundImage release];
    [bottomViewHeaderBackgroundImage release];
    
    
    return bottomView;
}

- (UIView *)centerViewInBottomViewWithIngredientsArray:(NSArray *)arrayOfIngredients andProcessString:(NSString *)processString andAvailableWidth:(CGFloat)availableWidth andMinimumHeight:(CGFloat)minimumHeight
{
    // Setup Common Variables    
    UIImage *seperatorInBottomImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeDetailSeperatorInBottomBackground" ofType:@"png"]];
    UIImage *bottomViewCenterBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeDetailBottomBackground" ofType:@"png"]];
    
    UIFont *bottomViewSectionTitleFont = [UtilityManager fontGetBoldFontOfSize:18.0];
    UIFont *bottomViewSectionContentFont = [UtilityManager fontGetBoldFontOfSize:16.0];
    
    CGFloat widthAvailableForContentsInBottomView = availableWidth - kBottomViewPaddingLeft - kBottomViewPaddingRight;
    
    
    
    UIView *centerView = [[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   availableWidth,
                                                                   minimumHeight)] autorelease];
    
    
    
    
    
    
    
    
    // Background ImageView
    UIImageView *centerBackgroundImageViewForBottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                                        0,
                                                                                                        centerView.frame.size.width,
                                                                                                        minimumHeight)];
    centerBackgroundImageViewForBottomView.image = bottomViewCenterBackgroundImage;
    centerBackgroundImageViewForBottomView.contentMode = UIViewContentModeScaleToFill;
    [centerView addSubview:centerBackgroundImageViewForBottomView];
    [centerBackgroundImageViewForBottomView release];

    
    
    
    
    
    // Bottom View Section Ingredients
    
    NSString *ingredientsTitleString = @"Ingredients:";
    CGSize ingredientsTitleSize = [ingredientsTitleString sizeWithFont:bottomViewSectionTitleFont];
    UILabel *ingredientsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kBottomViewPaddingLeft,
                                                                               kBottomViewPaddingTop,
                                                                               ingredientsTitleSize.width,
                                                                               ingredientsTitleSize.height)];
    ingredientsTitleLabel.text = ingredientsTitleString;
    ingredientsTitleLabel.backgroundColor = [UIColor clearColor];
    ingredientsTitleLabel.textColor = [UIColor whiteColor];
    ingredientsTitleLabel.font = bottomViewSectionTitleFont;
    [centerView addSubview:ingredientsTitleLabel];
    [ingredientsTitleLabel release];

    
    UIImageView *seperatorInBottomImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(kBottomViewPaddingLeft,
                                                                                             ingredientsTitleLabel.frame.origin.y + ingredientsTitleLabel.frame.size.height + kBottomViewGapBetweenSectionTitleAndSeperator,
                                                                                             seperatorInBottomImage.size.width,
                                                                                             seperatorInBottomImage.size.height)];
    seperatorInBottomImageView1.image = seperatorInBottomImage;
    
    [centerView addSubview:seperatorInBottomImageView1];
    [seperatorInBottomImageView1 release];
    
    
    
    
    UIView *ingredientsContentView = [[self ingredientsViewWithIngredientsArray:arrayOfIngredients andAvailableWidth:widthAvailableForContentsInBottomView andFont:bottomViewSectionContentFont] retain];
    ingredientsContentView.frame = CGRectMake(kBottomViewPaddingLeft,
                                              seperatorInBottomImageView1.frame.origin.y + seperatorInBottomImageView1.frame.size.height + kBottomViewGapBetweenSeperatorAndSectionContent,
                                              ingredientsContentView.frame.size.width,
                                              
                                              ingredientsContentView.frame.size.height);
    [centerView addSubview:ingredientsContentView];
    [ingredientsContentView release];

    
    
    
    
    
    
    
    // Bottom View Section Process
    NSString *processTitleString = @"";
    CGSize processTitleSize = [ingredientsTitleString sizeWithFont:bottomViewSectionTitleFont];
    UILabel *processTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kBottomViewPaddingLeft,
                                                                           ingredientsContentView.frame.origin.y + ingredientsContentView.frame.size.height + kBottomViewGapBetweenTwoSections,
                                                                           processTitleSize.width,
                                                                           processTitleSize.height)];
    processTitleLabel.text = processTitleString;
    processTitleLabel.backgroundColor = [UIColor clearColor];
    processTitleLabel.textColor = [UIColor whiteColor];
    processTitleLabel.font = bottomViewSectionTitleFont;
    [centerView addSubview:processTitleLabel];
    [processTitleLabel release];
    
    
    
    
    UIImageView *seperatorInBottomImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(kBottomViewPaddingLeft,
                                                                                             ingredientsContentView.frame.origin.y + ingredientsContentView.frame.size.height + kBottomViewGapBetweenTwoSections,
                                                                                             seperatorInBottomImage.size.width,
                                                                                             seperatorInBottomImage.size.height)];
    seperatorInBottomImageView2.image = seperatorInBottomImage;
    
    [centerView addSubview:seperatorInBottomImageView2];
    [seperatorInBottomImageView2 release];
    
    
    
    
    
    NSString *processContentsString = processString;
    CGSize processContentsSize = [processContentsString sizeWithFont:bottomViewSectionContentFont constrainedToSize:CGSizeMake(widthAvailableForContentsInBottomView, 9999) lineBreakMode:UILineBreakModeWordWrap];
    
    UILabel *processContentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(kBottomViewPaddingLeft,
                                                                              seperatorInBottomImageView2.frame.origin.y + seperatorInBottomImageView2.frame.size.height + kBottomViewGapBetweenSeperatorAndSectionContent+1,
                                                                              widthAvailableForContentsInBottomView,
                                                                              processContentsSize.height)];
    processContentsLabel.text = processContentsString;
    processContentsLabel.backgroundColor = [UIColor clearColor];
    processContentsLabel.textColor = [UIColor whiteColor];
    processContentsLabel.font = bottomViewSectionContentFont;
    processContentsLabel.numberOfLines = 100;
    
    [centerView addSubview:processContentsLabel];
    [processContentsLabel release];

    
    
    
    // Resize Center View and Background Image View
    if(centerView.frame.size.height < (processContentsLabel.frame.origin.y + processContentsLabel.frame.size.height + kBottomViewPaddingBottom))
    {
        centerView.frame = CGRectMake(centerView.frame.origin.x,
                                      centerView.frame.origin.y,
                                      centerView.frame.size.width,
                                      processContentsLabel.frame.origin.y + processContentsLabel.frame.size.height + kBottomViewPaddingBottom);
    }
    
    
    centerBackgroundImageViewForBottomView.frame = CGRectMake(0,
                                                              0,
                                                              centerView.frame.size.width,
                                                              centerView.frame.size.height);
    
    
  
    // Bottom View Center View Clean Up Variables
    [bottomViewCenterBackgroundImage release];
    [seperatorInBottomImage release];
    
    
    
    return centerView;
}


- (UIView *)ingredientsViewWithIngredientsArray:(NSArray *)arrayOfIngredients andAvailableWidth:(CGFloat)availableWidth andFont:(UIFont *)font
{
    UIView *ingredientView = [[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       availableWidth,
                                                                       0)] autorelease];
    ingredientView.backgroundColor = [UIColor clearColor];
    
    
    CGFloat yCoordinatePointer = 0;
    
    for(int i=0; i<[arrayOfIngredients count]; i++)
    {
        if(i > 0)
        {
            yCoordinatePointer = yCoordinatePointer + kBottomViewGapBetweenTwoBulletPoints;
        }
        
        NSString *pointText = [arrayOfIngredients objectAtIndex:i];
        UIView *bulletPointView = [[self bulletPointViewForString:pointText withWidth:availableWidth andFont:font] retain];
        bulletPointView.frame = CGRectMake(0,
                                           yCoordinatePointer,
                                           bulletPointView.frame.size.width,
                                           bulletPointView.frame.size.height);
        [ingredientView addSubview:bulletPointView];
        [bulletPointView release];
        
        yCoordinatePointer = bulletPointView.frame.origin.y + bulletPointView.frame.size.height;
    }
    
    
    ingredientView.frame = CGRectMake(ingredientView.frame.origin.x,
                                      ingredientView.frame.origin.y,
                                      ingredientView.frame.size.width,
                                      yCoordinatePointer);
    
    
    return ingredientView;
}

- (UIView *)bulletPointViewForString:(NSString *)pointString withWidth:(CGFloat)availableWidth andFont:(UIFont *)font
{
    UIView *bulletPointView = [[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        availableWidth,
                                                                        0)] autorelease];
    
    
    
    UIImage *bulletImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeDetailBulletPointIcon" ofType:@"png"]];
    UIImageView *bulletPointImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      bulletImage.size.width,
                                                                                      bulletImage.size.height)];
    bulletPointImageView.image = bulletImage;
    [bulletImage release];
    
    [bulletPointView addSubview:bulletPointImageView];
    [bulletPointImageView release];
    
    
    CGFloat widthAvailableForText = availableWidth - (bulletPointImageView.frame.origin.x + bulletPointImageView.frame.size.width + kBottomViewGapBetweenBulletPointIconAndText);
    CGSize textLabelSize = [pointString sizeWithFont:font constrainedToSize:CGSizeMake(widthAvailableForText, 9999) lineBreakMode:UILineBreakModeWordWrap];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(bulletPointImageView.frame.origin.x + bulletPointImageView.frame.size.width + kBottomViewGapBetweenBulletPointIconAndText,
                                                                   0,
                                                                   widthAvailableForText,
                                                                   textLabelSize.height)];
    textLabel.text = pointString;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = font;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.numberOfLines = 100;
    
    [bulletPointView addSubview:textLabel];
    [textLabel release];
    
    
    CGFloat heightToBeUsed = 0;
    if((textLabel.frame.origin.y + textLabel.frame.size.height) > (bulletPointImageView.frame.origin.y + bulletPointImageView.frame.size.height))
    {
        heightToBeUsed = textLabel.frame.origin.y + textLabel.frame.size.height;
        
        // Change the position of the bullet icon to center
        bulletPointImageView.frame = CGRectMake(bulletPointImageView.frame.origin.x,
                                                textLabel.frame.origin.y + roundf((textLabel.frame.size.height - bulletPointImageView.frame.size.height) / 2),
                                                bulletPointImageView.frame.size.width,
                                                bulletPointImageView.frame.size.height);
    }
    else
    {
        heightToBeUsed = bulletPointImageView.frame.origin.y + bulletPointImageView.frame.size.height;
        
        
        // Change the position of the bullet icon to center
        textLabel.frame = CGRectMake(textLabel.frame.origin.x,
                                     bulletPointImageView.frame.origin.y + roundf((bulletPointImageView.frame.size.height - textLabel.frame.size.height) / 2),
                                     textLabel.frame.size.width,
                                     textLabel.frame.size.height);
    }
    
    
    bulletPointView.frame = CGRectMake(bulletPointView.frame.origin.x,
                                       bulletPointView.frame.origin.y,
                                       bulletPointView.frame.size.width,
                                       heightToBeUsed);
    

    return bulletPointView;
}

- (void)updateRatingTitleLabel
{
    NSString *ratingString = @"Rate:";
    if(mRecipeObject.ratingValueSubmittedByUser == nil || [mRecipeObject.ratingValueSubmittedByUser floatValue] == 0)
    {
        ratingString = @"Rate:";
    }
    
    mRatingTitleLabel.text = ratingString;
}


- (UIView *)viewForRemoveFromFavorite
{
    if(mRemoveFromFavoriteView == nil)
    {
        mRemoveFromFavoriteView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width,
                                                                           mAddToFavoriteView.frame.origin.y + 1,
                                                                           self.view.frame.size.width,
                                                                           kRemoveFromFavViewHeight)];
        mOriginalRectForRemoveFromFavView = mRemoveFromFavoriteView.frame;
        mRemoveFromFavoriteView.backgroundColor = [UIColor colorWithRed:(40.0/256.0) green:(45.0/256.0) blue:(85.0/256.0) alpha:1];
        
        
        
        NSString *messageString = @"Are you sure you want to remove from My Faves?";
        UIFont *messageFont = [UtilityManager fontGetRegularFontOfSize:14];
        CGSize messageSize = [messageString sizeWithFont:messageFont];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          kRemoveFromFavViewPaddingTop,
                                                                          mRemoveFromFavoriteView.frame.size.width,
                                                                          messageSize.height)];
        messageLabel.text = messageString;
        messageLabel.textColor = [UIColor colorWithRed:(161.0/256.0) green:(175.0/256.0) blue:(196.0/256.0) alpha:1];
        messageLabel.font = messageFont;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textAlignment = UITextAlignmentCenter;
        [mRemoveFromFavoriteView addSubview:messageLabel];
        [messageLabel release];
        
        
        
        CGFloat sidePaddingForButtons = 5;
        UIFont *fontForButtons = [UtilityManager fontGetRegularFontOfSize:15];
        
        NSString *noString = @"No";
        CGSize noButtonSize = [noString sizeWithFont:fontForButtons];
        UIButton *noButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        40,
                                                                        20)];
        [noButton setTitle:noString forState:UIControlStateNormal];
        [noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [noButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [noButton setBackgroundColor:[UIColor colorWithRed:(236.0/256.0) green:(0.0/256.0) blue:(139.0/256.0) alpha:1.0]];
        [noButton addTarget:self action:@selector(noButtonClickedOnRemoveFromFavView:) forControlEvents:UIControlEventTouchUpInside];
        noButton.titleLabel.font = fontForButtons;
        [mRemoveFromFavoriteView addSubview:noButton];
        [noButton release];
        
        
        
        
        NSString *yesString = @"Yes";
        CGSize yesButtonSize = [yesString sizeWithFont:fontForButtons];
        UIButton *yesButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         40,
                                                                         20)];
        [yesButton setTitle:yesString forState:UIControlStateNormal];
        [yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [yesButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [yesButton setBackgroundColor:[UIColor colorWithRed:(236.0/256.0) green:(0.0/256.0) blue:(139.0/256.0) alpha:1.0]];
        [yesButton addTarget:self action:@selector(yesButtonClickedOnRemoveFromFavView:) forControlEvents:UIControlEventTouchUpInside];
        yesButton.titleLabel.font = fontForButtons;
        [mRemoveFromFavoriteView addSubview:yesButton];
        [yesButton release];
        
        
        
        CGFloat xCoordinateForNoButton = roundf((mRemoveFromFavoriteView.frame.size.width - (noButton.frame.size.width + kRemoveFromFavViewGapBetweenButtons + yesButton.frame.size.width)) / 2);
        noButton.frame = CGRectMake(xCoordinateForNoButton,
                                    messageLabel.frame.origin.y + messageLabel.frame.size.height + kRemoveFromFavViewGapBetweenMessageAndButtons,
                                    noButton.frame.size.width,
                                    noButton.frame.size.height);

        yesButton.frame = CGRectMake(noButton.frame.origin.x + noButton.frame.size.width + kRemoveFromFavViewGapBetweenButtons,
                                     noButton.frame.origin.y,
                                     yesButton.frame.size.width,
                                     yesButton.frame.size.height);
    }
    
    return mRemoveFromFavoriteView;
}


#pragma mark - Action Methods

- (void)share:(id)sender
{
    // Create Share Item Objects

    
    
    NSMutableArray *arrayOfShareItems = [[NSMutableArray alloc] init];
    
    if([MFMessageComposeViewController canSendText])
    {
        BVShareItem *messageItem = [[BVShareItem alloc] initWithItemName:@"Message" andIconImage:[[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"ShareMessageIcon.png" andAddIfRequired:YES]];
        [arrayOfShareItems addObject:messageItem];
        [messageItem release];
    }

    BVShareItem *mailItem = [[BVShareItem alloc] initWithItemName:@"Mail" andIconImage:[[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"ShareMailIcon.png" andAddIfRequired:YES]];
    [arrayOfShareItems addObject:mailItem];
    [mailItem release];
    
    
    BVShareItem *facebookItem = [[BVShareItem alloc] initWithItemName:@"Facebook" andIconImage:[[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"ShareFacebookIcon.png" andAddIfRequired:YES]];
    [arrayOfShareItems addObject:facebookItem];
    [facebookItem release];
    
    
    BVShareItem *twitterItem = [[BVShareItem alloc] initWithItemName:@"Twitter" andIconImage:[[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"ShareTwitterIcon.png" andAddIfRequired:YES]];
    [arrayOfShareItems addObject:twitterItem];
    [twitterItem release];
    

    
    mShareOverlayView.viewDelegate = nil;
    [mShareOverlayView removeFromSuperview];
    [mShareOverlayView release];
    mShareOverlayView = [[BVShareOverlayView alloc] initWithShareItems:arrayOfShareItems];
    [arrayOfShareItems release];
    
    mShareOverlayView.viewDelegate = self;
    
    [mShareOverlayView showInView:[UtilityManager tabBarControllerOfTheApplication].view];    
}

- (void)ratingViewTapped:(id)sender
{
    mRatingOverlayView.viewDelegate = nil;
    [mRatingOverlayView removeFromSuperview];
    [mRatingOverlayView release];
    mRatingOverlayView = [[BVRatingOverlayView alloc] init];
    mRatingOverlayView.viewDelegate = self;
    [mRatingOverlayView showInView:[UtilityManager tabBarControllerOfTheApplication].view];
}

- (void)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)noButtonClickedOnRemoveFromFavView:(id)sender
{
    UIView *removeFromFavView = [self viewForRemoveFromFavorite];

    [UIView animateWithDuration:0.2
                     animations:^{
                         
                         removeFromFavView.frame = mOriginalRectForRemoveFromFavView;
                     }
                     completion:^(BOOL finished) {
                         
                         [removeFromFavView removeFromSuperview];
                     }];
}

- (void)yesButtonClickedOnRemoveFromFavView:(id)sender
{
    BVApp *app = [[DataManager sharedDataManager] app];
    [app removeFavoriteRecipesObject:mRecipeObject];
    [DataManager saveDatabaseOnMainThread];
    
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationRecipeRemovedFromFavoriteFromRecipeDetailScreen object:mRecipeObject]];
}


#pragma mark - Helper Methods


- (void)shareRecipeOnMessage
{
    if([MFMessageComposeViewController canSendText])
    {
        NSString *value = [[NSString stringWithFormat:@"%@", mRecipeObject.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
        [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:@"shareonmessage"]];
        id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event     // Event category (required)
                                                              action:@"shareonmessage"  // Event action (required)
                                                               label:value          // Event label
                                                               value:nil] build]];
        NSString *messageString = [NSString stringWithFormat:@"Check out this Burnett's %@ recipe which I found in the Burnett’s Flavorite Occasions Recipe App!\n\n%@", mRecipeObject.title, [mRecipeObject urlLinkForRecipe]];
        
        MFMessageComposeViewController *smsViewController = [[MFMessageComposeViewController alloc] init];
        smsViewController.messageComposeDelegate = self;
        smsViewController.body = messageString;
        [self presentViewController:smsViewController animated:YES completion:nil];

     //   [self presentViewController:smsViewController animated:YES];
        [smsViewController release];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Your device cannot send SMS Message." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (void)shareRecipeOnMail
{
    NSString *value = [[NSString stringWithFormat:@"%@", mRecipeObject.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:@"shareonmail"]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event    // Event category (required)
                                                          action:@"shareonmail"  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
	mailComposer.mailComposeDelegate = self;
	
	[mailComposer setSubject:[NSString stringWithFormat:@"Burnett's %@ recipe", mRecipeObject.title]];
    
    
    
    NSString *htmlTemplateString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"burnetts-recipe-email" ofType:@"html"] encoding:4 error:nil];
    
    // Replace Recipe Name
    htmlTemplateString = [htmlTemplateString stringByReplacingOccurrencesOfString:@"%RECIPE_NAME%" withString:mRecipeObject.title];
    
    // Replace Recipe Link
    htmlTemplateString = [htmlTemplateString stringByReplacingOccurrencesOfString:@"%RECIPE_LINK%" withString:[mRecipeObject urlLinkForRecipe]];
    
    // Replace Recipe Process
    htmlTemplateString = [htmlTemplateString stringByReplacingOccurrencesOfString:@"%PROCESS%" withString:mRecipeObject.directions];
    
    // Replace Recipe Image URL
    NSString *recipleImageURL = [NSString stringWithFormat:@"%@", mRecipeObject.imageName];
    htmlTemplateString = [htmlTemplateString stringByReplacingOccurrencesOfString:@"%IMAGE_URL%" withString:recipleImageURL];
    NSLog(@"URL: %@",recipleImageURL);
    
    
    // Replace Recipe Ingredients
    NSMutableString *ingredientsStringToBeUsedInHTML = [[NSMutableString alloc] init];
    NSArray *ingredientsArray = [mRecipeObject arrayOfIngredients];
    for(NSString *ingredientString in ingredientsArray)
    {
        [ingredientsStringToBeUsedInHTML appendFormat:@"<li>%@</li>", ingredientString];
    }
    
    htmlTemplateString = [htmlTemplateString stringByReplacingOccurrencesOfString:@"%INGREDIENTS%" withString:ingredientsStringToBeUsedInHTML];
    [ingredientsStringToBeUsedInHTML release];
    
    
    [mailComposer setMessageBody:htmlTemplateString isHTML:YES];

    [self presentViewController:mailComposer animated:YES completion:nil];

	//[self presentViewController:mailComposer animated:YES];
	
	[mailComposer release];
}

- (void)shareRecipeOnTwitter
{
    // As of now, the longest recipe name is 'Pumpkin Pie a la Mode Martini' with 29 characters.
    NSString *value = [[NSString stringWithFormat:@"%@", mRecipeObject.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:@"shareontwitter"]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event     // Event category (required)
                                                          action:@"shareontwitter"  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];
    
    NSString *textToBeTweeted = [NSString stringWithFormat:@"Check out this Burnett's %@ recipe on Flavorite Occasions Recipe App!", mRecipeObject.title];
        
    // Check and decide which framework to use for twitter sharing.
    // iOS 6.0 onwards we shall use Social Framework and before that, we shall use Twitter Framework
    if(NSClassFromString(@"SLComposeViewController"))
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        BOOL urlAddSuccess = [tweetSheet addURL:[NSURL URLWithString:[mRecipeObject urlLinkForRecipe]]];
                
        BOOL textAddSuccess = [tweetSheet setInitialText:textToBeTweeted];
        
        if(!(textAddSuccess && urlAddSuccess))
        {
            NSLog(@"Unable to fit all content in tweet because of shortage of space");
        }
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        
        BOOL urlAddSuccess = [tweetSheet addURL:[NSURL URLWithString:[mRecipeObject urlLinkForRecipe]]];
                
        BOOL textAddSuccess = [tweetSheet setInitialText:textToBeTweeted];
        
        if(!(textAddSuccess && urlAddSuccess))
        {
            NSLog(@"Unable to fit all content in tweet because of shortage of space");
        }
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
        [tweetSheet release];
    }
}

- (void)shareRecipeOnFacebook
{
    NSString *value = [[NSString stringWithFormat:@"%@", mRecipeObject.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:@"shareonfacebook"]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event    // Event category (required)
                                                          action:@"shareonfacebook"  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];
    // Check and decide which framework to use for twitter sharing.
    // iOS 6.0 onwards we shall use Social Framework and before that, we shall use Twitter Framework
    if(NSClassFromString(@"SLComposeViewController"))
    {
        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [facebookSheet setInitialText:[NSString stringWithFormat:@"Check out this Burnett's %@ recipe which I found in the Burnett’s Flavorite Occasions Recipe App!\n\n", mRecipeObject.title]];
        
        [facebookSheet addURL:[NSURL URLWithString:[mRecipeObject urlLinkForRecipe]]];
        
        UIImage *recipeImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:[mRecipeObject pngImageFileName] andAddIfRequired:YES];
        [facebookSheet addImage:recipeImage];
        
        [self presentViewController:facebookSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Facebook sharing is not available in iOS less than 6.0. Please upgrade to iOS 6.0 to enable facebook share in this app." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}



#pragma mark - BVShareOverlayView Delegate Methods

- (void)shareOverlayViewCancelButtonTapped:(BVShareOverlayView *)view
{
    mShareOverlayView.viewDelegate = nil;
    [mShareOverlayView removeFromSuperview];
    [mShareOverlayView release];
    mShareOverlayView = nil;
}

- (void)shareOverlayView:(BVShareOverlayView *)view shareItemPressed:(BVShareItem *)item
{
    mShareOverlayView.viewDelegate = nil;
    [mShareOverlayView removeFromSuperview];
    [mShareOverlayView release];
    mShareOverlayView = nil;
    
    
    if([[item.itemName lowercaseString] isEqualToString:@"message"])
    {
        [self shareRecipeOnMessage];
    }
    else if([[item.itemName lowercaseString] isEqualToString:@"mail"])
    {
        [self shareRecipeOnMail];
    }
    else if([[item.itemName lowercaseString] isEqualToString:@"facebook"])
    {
        [self shareRecipeOnFacebook];
    }
    else if([[item.itemName lowercaseString] isEqualToString:@"twitter"])
    {
        [self shareRecipeOnTwitter];
    }
}



#pragma mark - BVRatingOverlayView Delegate Methods

- (void)ratingOverlayViewCancelButtonTapped:(BVRatingOverlayView *)view
{
    mRatingOverlayView.viewDelegate = nil;
    [mRatingOverlayView removeFromSuperview];
    [mRatingOverlayView release];
    mRatingOverlayView = nil;
}

- (void)ratingOverlayView:(BVRatingOverlayView *)view didFinishSubmittingRatingsForRecipe:(Recipe *)recipe
{
    mRatingOverlayView.viewDelegate = nil;
    [mRatingOverlayView removeFromSuperview];
    [mRatingOverlayView release];
    mRatingOverlayView = nil;
}

- (void)ratingOverlayView:(BVRatingOverlayView *)view didFailToSubmitRatingsForRecipe:(Recipe *)recipe
{
    mRatingOverlayView.viewDelegate = nil;
    [mRatingOverlayView removeFromSuperview];
    [mRatingOverlayView release];
    mRatingOverlayView = nil;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to submit the ratings. Make sure your device is connected to internet and try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)ratingOverlayView:(BVRatingOverlayView *)view didCancelWhileSubmittingRatingsForRecipe:(Recipe *)recipe
{
    mRatingOverlayView.viewDelegate = nil;
    [mRatingOverlayView removeFromSuperview];
    [mRatingOverlayView release];
    mRatingOverlayView = nil;
}

- (Recipe *)recipeObjectForRatingSubmissionByBVRatingOverlayView:(BVRatingOverlayView *)view
{
    return mRecipeObject;
}





#pragma mark -
#pragma mark MFMailComposer Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result)
	{
		case MFMailComposeResultSent:
		{
			UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Email has been sent." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            newAlertView.tag = kAlertViewForMail;
			[newAlertView show];
			[newAlertView release];
			
			break;
		}
			
		case MFMailComposeResultCancelled:
		{
			[self dismissModalViewControllerAnimated:YES];
			break;
		}
			
		case MFMailComposeResultFailed:
		{
			UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to send email. Try Later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            newAlertView.tag = kAlertViewForMail;
			[newAlertView show];
			[newAlertView release];
			break;
		}
			
		case MFMailComposeResultSaved:
		{
			UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Email has been saved in drafts." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            newAlertView.tag = kAlertViewForMail;
			[newAlertView show];
			[newAlertView release];
			
			break;
		}
			
		default:
			break;
	}
	
}


#pragma mark -
#pragma mark MFMessageComposeViewController Delegate Methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark UIAlertView Delegate Methods


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kAlertViewForMail)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}



#pragma mark -
#pragma mark BVRecipeDetailAddToFavoriteView Delegate Methods

- (void)recipeDetailAddToFavoriteViewUserTappedAddToFavoriteButton:(BVRecipeDetailAddToFavoriteView *)view
{
    BVApp *app = [[DataManager sharedDataManager] app];
    [app addFavoriteRecipesObject:mRecipeObject];
    [DataManager saveDatabaseOnMainThread];
        
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationRecipeAddedToFavorite object:mRecipeObject]];
}

- (void)recipeDetailAddToFavoriteViewUserSwippedToRemoveFromFavorites:(BVRecipeDetailAddToFavoriteView *)view
{
    UIView *removeFromFavView = [self viewForRemoveFromFavorite];
    [mScrollView addSubview:removeFromFavView];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                        
                         removeFromFavView.frame = CGRectMake(0,
                                                              mOriginalRectForRemoveFromFavView.origin.y,
                                                              mOriginalRectForRemoveFromFavView.size.width,
                                                              mOriginalRectForRemoveFromFavView.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];

}


#pragma mark -
#pragma mark NSNotification Methods

- (void)recipeRemovedFromFavorites:(NSNotification *)notification
{
    Recipe *recipeObjectRemovedFromFavorites = [notification object];
    NSString *value = [[NSString stringWithFormat:@"%@", recipeObjectRemovedFromFavorites.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:@"removefromfavorites"]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event    // Event category (required)
                                                          action:@"removefromfavorites"  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];
    
    if(recipeObjectRemovedFromFavorites == mRecipeObject)
    {
        [mAddToFavoriteView updateViewToShowAdded:NO animated:NO];
        
        UIView *removeFromFavView = [self viewForRemoveFromFavorite];
        if(removeFromFavView.superview)
        {
            removeFromFavView.frame = mOriginalRectForRemoveFromFavView;
            [removeFromFavView removeFromSuperview];
        }
    }
}

- (void)recipeRemovedFromFavoritesFromRecipeDetailScreen:(NSNotification *)notification
{
    Recipe *recipeObjectRemovedFromFavorites = [notification object];
    NSString *value = [[NSString stringWithFormat:@"%@", recipeObjectRemovedFromFavorites.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:@"removefromfavorites_fromdetailscreen"]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event     // Event category (required)
                                                          action:@"removefromfavorites_fromdetailscreen"  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];
    if(recipeObjectRemovedFromFavorites == mRecipeObject)
    {
        UIView *removeFromFavView = [self viewForRemoveFromFavorite];
        if(removeFromFavView.superview)
        {
            [mAddToFavoriteView updateViewToShowAdded:NO animated:NO];
            
            [UIView animateWithDuration:0.2
                             animations:^{
                                 
                                 removeFromFavView.frame = mOriginalRectForRemoveFromFavView;
                             }
                             completion:^(BOOL finished) {
                                 
                                 [removeFromFavView removeFromSuperview];
                             }];
        }
        else
        {
            [mAddToFavoriteView updateViewToShowAdded:NO animated:YES];
        }
    }
}

- (void)recipeRatingsDataChanged:(NSNotification *)notification
{    
    NSArray *arrayOfRecipesForWhichDataHasChanged = [notification object];
    
    for(Recipe *recipeObject in arrayOfRecipesForWhichDataHasChanged)
    {
        if(recipeObject == mRecipeObject)
        {
            [mRatingStarView updateViewWithRatingOutOfFive:[mRecipeObject.ratingValueSubmittedByUser floatValue]];
            
            NSString *value = [[NSString stringWithFormat:@"recipie_%@_%f", mRecipeObject.title, [mRecipeObject.ratingValueSubmittedByUser floatValue]] stringByReplacingOccurrencesOfString:@" " withString:@""];
            [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:@"ratedwithvalue"]];
            id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event     // Event category (required)
                                                                  action:@"ratedwithvalue"  // Event action (required)
                                                                   label:value          // Event label
                                                                   value:nil] build]];
        
            [self updateRatingTitleLabel];
            break;
        }
    }
}

- (void)recipeAddedToFavorites:(NSNotification *)notification
{
    Recipe *recipeAddedToFavorites = [notification object];
    NSString *value = [[NSString stringWithFormat:@"%@", recipeAddedToFavorites.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:@"addtofavorites"]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event     // Event category (required)
                                                          action:@"addtofavorites"  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];
    if(recipeAddedToFavorites == mRecipeObject)
    {
        [mAddToFavoriteView updateViewToShowAdded:YES animated:YES];
        
        UIView *removeFromFavView = [self viewForRemoveFromFavorite];
        if(removeFromFavView.superview)
        {
            removeFromFavView.frame = mOriginalRectForRemoveFromFavView;
            [removeFromFavView removeFromSuperview];
        }
    }
}



@end
