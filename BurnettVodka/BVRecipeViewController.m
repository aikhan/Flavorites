//
//  BVRecipeViewController.m
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVRecipeViewController.h"
#import "UtilityManager.h"
#import "BVRecipeDetailViewController.h"
#import "DataManager.h"
#import "Recipe.h"
#import "UtilityManager.h"
#import "Flavor.h"
#import "BVTabBarController.h"
#import "Constants.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

#define kGapBetweenNavigationBarAndSegmentControl 29
#define kGapBetweenSegmentControlAndSearchBar 7
#define kGapBetweenSearchBarAndTableView 8


#define kSegmentedControlWidth 305


#define kMinimumPullToShowSearchBarAndSegmentedControl 50


@interface BVRecipeViewController ()

- (void)loadUserInterface;
- (void)configureViewOutOfSearchMode;
- (void)showMixerSelectionDropDownWithOptions:(NSArray *)options;
- (void)hideMixerSelectionDropDown;
- (void)showFlavorSelectionDropDownWithOptions:(NSArray *)options;
- (void)hideFlavorSelectionDropDown;
- (void)hideSegmentedControlAndSearchBarAnimated:(BOOL)animated;
- (void)showSegmentedControlAndSearchBarAnimated:(BOOL)animated;
- (void)showNoResultsLabel;
- (void)hideNoResultsLabel;

- (NSMutableArray *)dataForTableView;
- (NSMutableArray *)dataForSegmentedIndex:(RecipeViewControllerSegmentedIndex)index;
- (NSMutableArray *)currentActiveMixerFilters;
- (NSMutableArray *)currentActiveFlavorFilters;

- (void)refreshDataForAZTableView;
- (void)refreshDataForFlavorTableView;
- (void)refreshDataForMixerTableView;

- (UIImage *)imageForAZTabSelected:(BOOL)isSelected;
- (UIImage *)imageForFlavorTabSelected:(BOOL)isSelected;
- (UIImage *)imageForMixersTabSelected:(BOOL)isSelected;

- (void)startDownloadForLazyLoadImage:(HSLazyLoadImage *)image;
- (UITapGestureRecognizer *)tapGestureForSegmentControlForMixers;
- (UITapGestureRecognizer *)tapGestureForSegmentControlForFlavors;
- (NSArray *)arrayOfOptionsForMixerDropDownMenuBasedOnCurrentSelectedMixerFilters;
- (NSArray *)arrayOfOptionsForFlavorDropDownMenuBasedOnCurrentSelectedFlavorFilters;
- (BOOL)isThisString:(NSString *)searchString aseperateEntityInTheString:(NSString *)stringToBeSearched;
- (NSInteger)indexOfSegmentTouchedByUserInSegmentedControl:(UISegmentedControl *)segmentedControl withTouchPoint:(CGPoint)touchPoint;

@end


@implementation BVRecipeViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
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
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidAppear:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeRatingsDataChanged:) name:kNotificationRecipeRatingsChanged object:nil];
    

   // [UtilityManager addTitle:@"Recipes" toNavigationItem:self.navigationItem];
    
    [self loadUserInterface];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, 320, 59);

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reciepeTab.png"] forBarMetrics:UIBarMetricsDefault];

    
    if(mIsSearchModeActive)
    {
       // [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
    self.screenName = @"Recipes";
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, 320, 59);

    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, 320, 59);

    [super viewDidAppear:animated];
   // self.screenName = @"Recipe View";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [mTapGestureForSegmentControlForAlreadySelectedMixerSegment release];
    [mTapGestureForSegmentControlForAlreadySelectedFlavorSegment release];
    
    mLazyImageDownloader.delegate = nil;
    [mLazyImageDownloader release];
    
    
    [mImageAZTabSelected release];
    [mImageAZTabUnselected release];
    [mImageFlavorTabSelected release];
    [mImageFlavorTabUnselected release];
    [mImageRecipesTabSelected release];
    [mImageRecipesTabUnselected release];
    
    [mNoResultsLabel release];
    [mTranslucentOverlayDuringMixerDropDown release];
    [mTranslucentOverlayDuringFlavorDropDown release];
    [mFlavorDropDownMenuView release];
    [mMixerDropDownMenuView release];
    [mTranslucentOverlayDuringSearchMode release];
    [mSearchModeTableData release];
    [mFlavorTableData release];
    [mMixerTableData release];
    [mAZTableData release];
    [mSelectedMixerFiltersArray release];
    [mSelectedFlavorFiltersArray release];
    [mMapOfMixersToFlavorsForMixerFiltering release];
    [mSearchBar release];
    [mSegmentControl release];
    [mBackgroundImageView release];
    [mTableView release];
    [super dealloc];
}




#pragma mark - UI Methods

- (void)loadUserInterface
{
    // Background Image View
    [mBackgroundImageView removeFromSuperview];
    [mBackgroundImageView release];
    mBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         self.view.frame.size.width,
                                                                         self.view.frame.size.height)];

    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"reciepebg.png" andAddIfRequired:YES];
    mBackgroundImageView.image = backgroundImage;
    mBackgroundImageView.contentMode = UIViewContentModeTop;
    [self.view addSubview:mBackgroundImageView];

    
    
    
    
    
    
    
    
    
    // UISegmentControl
    [mSegmentControl removeFromSuperview];
    [mSegmentControl release];
    mSegmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[self imageForAZTabSelected:YES], [self imageForFlavorTabSelected:NO], [self imageForMixersTabSelected:NO], nil]];
    
    mSegmentControl.selectedSegmentIndex = 0;
    mSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    mSegmentControl.backgroundColor=[UIColor clearColor];
    mSegmentControl.frame = CGRectMake(roundf((self.view.frame.size.width - kSegmentedControlWidth) / 2),
                                       kGapBetweenNavigationBarAndSegmentControl,
                                       kSegmentedControlWidth,
                                       30);
    mSegmentControl.tintColor = [UIColor colorWithRed:(57.0/255.0) green:(67.0/255.0) blue:(98.0/255.0) alpha:1.0];
    
    
    
    mOriginalFrameOfSegmentControl = mSegmentControl.frame;
    
    
    
    
    
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        UIImage *segmentedControlBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeTabSegmentedControlBackground" ofType:@"png"]];
        
        [mSegmentControl setBackgroundImage:segmentedControlBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [segmentedControlBackgroundImage release];
    }
    
    
    
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        UIImage *dividerImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeTabSegmentedControlDividerImage" ofType:@"png"]];
        
        [mSegmentControl setDividerImage:dividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [dividerImage release];
    }

    
    
    [mSegmentControl setWidth:101 forSegmentAtIndex:0];
    [mSegmentControl setWidth:101 forSegmentAtIndex:1];
    [mSegmentControl setWidth:101 forSegmentAtIndex:2];
    
    [mSegmentControl addTarget:self
                        action:@selector(segmentControlValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:mSegmentControl];
    
    
    
    
    
    
    
    

    
    // Search Bar
    [mSearchBar removeFromSuperview];
    [mSearchBar release];
    mSearchBar = [[BVSearchBar alloc] initWithFrame:CGRectZero];
    mSearchBar.frame = CGRectMake(roundf((self.view.frame.size.width - mSearchBar.frame.size.width) / 2),
                                  mSegmentControl.frame.origin.y + mSegmentControl.frame.size.height + kGapBetweenSegmentControlAndSearchBar,
                                  mSearchBar.frame.size.width,
                                  mSearchBar.frame.size.height);
    mOriginalFrameOfSearchBar = mSearchBar.frame;
    mSearchBar.searchDelegate = self;
    [self.view addSubview:mSearchBar];

    
    

    
    
    
    // TableView
    [mTableView removeFromSuperview];
    [mTableView release];
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                               mSearchBar.frame.origin.y + mSearchBar.frame.size.height + kGapBetweenSearchBarAndTableView,
                                                               self.view.frame.size.width,
                                                               self.view.frame.size.height - (mSearchBar.frame.origin.y + mSearchBar.frame.size.height + kGapBetweenSearchBarAndTableView))];
    mOriginalFrameOfTableView = mTableView.frame;
    mTableView.dataSource = self;
    mTableView.delegate = self;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        mTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    mTableView.backgroundColor = [UIColor clearColor];
    mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:mTableView];
    
    if([mTableView respondsToSelector:@selector(setSectionIndexColor:)])
    {
        [mTableView performSelector:@selector(setSectionIndexColor:) withObject:[UIColor blackColor]];
    }
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)configureViewOutOfSearchMode
{
    [mTableView reloadData];
    [mTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//    self.navigationController.navigationBar.frame = CGRectMake(0, 0, 320, 65);
//    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reciepeTab.png"] forBarMetrics:UIBarMetricsDefault];
//
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         mSearchBar.frame = mOriginalFrameOfSearchBar;
                         
                         mSegmentControl.frame = mOriginalFrameOfSegmentControl;
                         
                         mTableView.frame = mOriginalFrameOfTableView;
                         
                         mTranslucentOverlayDuringSearchMode.frame = mOriginalFrameOfTableView;
                         mTranslucentOverlayDuringSearchMode.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         [mTranslucentOverlayDuringSearchMode removeFromSuperview];
                         [mTranslucentOverlayDuringSearchMode release];
                         mTranslucentOverlayDuringSearchMode = nil;
                        
                         
                     }];
}

- (void)showMixerSelectionDropDownWithOptions:(NSArray *)options
{
    if(mMixerDropDownMenuView)
        return;
    
    
    
    if(mTranslucentOverlayDuringMixerDropDown == nil)
    {
        mTranslucentOverlayDuringMixerDropDown = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                          0,
                                                                                          self.view.frame.size.width,
                                                                                          self.view.frame.size.height)];
        mTranslucentOverlayDuringMixerDropDown.alpha = 0.7;
        mTranslucentOverlayDuringMixerDropDown.backgroundColor = [UIColor blackColor];
        [self.view addSubview:mTranslucentOverlayDuringMixerDropDown];
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropDownTranslucentLayerForMixerTapped:)];
        [mTranslucentOverlayDuringMixerDropDown addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        
        // This is so that when the DropDown for Mixers is shown along with translucent layer, the segment control is not covered by the translucent layer.
        [self.view bringSubviewToFront:mSegmentControl];
    }
    
    
    mTranslucentOverlayDuringMixerDropDown.alpha = 0.0;
    mTranslucentOverlayDuringMixerDropDown.hidden = NO;
    
    
    
    mMixerDropDownMenuView.viewDelegate = nil;
    [mMixerDropDownMenuView removeFromSuperview];
    [mMixerDropDownMenuView release];
    mMixerDropDownMenuView = [[BVDropDownMenuView alloc] initWithOptions:options];
    mMixerDropDownMenuView.viewDelegate = self;
    mMixerDropDownMenuView.alpha = 0.0;
    [mMixerDropDownMenuView showInView:self.view withArrowPointingAt:CGPointMake(roundf(((mSegmentControl.frame.size.width / 3) * 2) + ((mSegmentControl.frame.size.width / 3) / 2) + 13),
                                                                                 mSegmentControl.frame.origin.y + mSegmentControl.frame.size.height - 6)];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         mTranslucentOverlayDuringMixerDropDown.alpha = 0.7;
                         mMixerDropDownMenuView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                         
                     }];
    
}

- (void)hideMixerSelectionDropDown
{
    if(mMixerDropDownMenuView == nil)
        return;
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         mTranslucentOverlayDuringMixerDropDown.alpha = 0.0;
                         mMixerDropDownMenuView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         mTranslucentOverlayDuringMixerDropDown.hidden = YES;
                         mMixerDropDownMenuView.viewDelegate = nil;
                         [mMixerDropDownMenuView removeFromSuperview];
                         [mMixerDropDownMenuView release];
                         mMixerDropDownMenuView = nil;
                     }];
}

- (void)showFlavorSelectionDropDownWithOptions:(NSArray *)options
{
    if(mFlavorDropDownMenuView)
        return;
    
    
    
    if(mTranslucentOverlayDuringFlavorDropDown == nil)
    {
        mTranslucentOverlayDuringFlavorDropDown = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                          0,
                                                                                          self.view.frame.size.width,
                                                                                          self.view.frame.size.height)];
        mTranslucentOverlayDuringFlavorDropDown.alpha = 0.7;
        mTranslucentOverlayDuringFlavorDropDown.backgroundColor = [UIColor blackColor];
        [self.view addSubview:mTranslucentOverlayDuringFlavorDropDown];
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropDownTranslucentLayerForFlavorTapped:)];
        [mTranslucentOverlayDuringFlavorDropDown addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        
        // This is so that when the DropDown for Mixers is shown along with translucent layer, the segment control is not covered by the translucent layer.
        [self.view bringSubviewToFront:mSegmentControl];
    }
    
    
    mTranslucentOverlayDuringFlavorDropDown.alpha = 0.0;
    mTranslucentOverlayDuringFlavorDropDown.hidden = NO;
    
    
    
    mFlavorDropDownMenuView.viewDelegate = nil;
    [mFlavorDropDownMenuView removeFromSuperview];
    [mFlavorDropDownMenuView release];
    mFlavorDropDownMenuView = [[BVDropDownMenuView alloc] initWithOptions:options];
    mFlavorDropDownMenuView.viewDelegate = self;
    mFlavorDropDownMenuView.alpha = 0.0;
    [mFlavorDropDownMenuView showInView:self.view withArrowPointingAt:CGPointMake(roundf(((mSegmentControl.frame.size.width / 3) * 1) + ((mSegmentControl.frame.size.width / 3) / 2) + 10),
                                                                                 mSegmentControl.frame.origin.y + mSegmentControl.frame.size.height - 6)];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         mTranslucentOverlayDuringFlavorDropDown.alpha = 0.7;
                         mFlavorDropDownMenuView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                         
                     }];
    
}

- (void)hideFlavorSelectionDropDown
{
    if(mFlavorDropDownMenuView == nil)
        return;
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         mTranslucentOverlayDuringFlavorDropDown.alpha = 0.0;
                         mFlavorDropDownMenuView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                        mTranslucentOverlayDuringFlavorDropDown.hidden = YES;
                        mFlavorDropDownMenuView.viewDelegate = nil;
                        [mFlavorDropDownMenuView removeFromSuperview];
                        [mFlavorDropDownMenuView release];
                        mFlavorDropDownMenuView = nil;
                     }];
}

- (void)hideSegmentedControlAndSearchBarAnimated:(BOOL)animated
{    
    mIsSearchBarAndSegmentedControlHidden = YES;
    if(animated)
    {
        mTableView.frame = CGRectMake(mOriginalFrameOfTableView.origin.x,
                                      mOriginalFrameOfTableView.origin.y,
                                      mOriginalFrameOfTableView.size.width,
                                      mOriginalFrameOfTableView.size.height + mOriginalFrameOfTableView.origin.y);
        
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             mSearchBar.frame = CGRectMake(mOriginalFrameOfSearchBar.origin.x,
                                                           mOriginalFrameOfSearchBar.origin.y - mOriginalFrameOfTableView.origin.y,
                                                           mOriginalFrameOfSearchBar.size.width,
                                                           mOriginalFrameOfSearchBar.size.height);
                             
                             mSegmentControl.frame = CGRectMake(mOriginalFrameOfSegmentControl.origin.x,
                                                                mOriginalFrameOfSegmentControl.origin.y - mOriginalFrameOfTableView.origin.y,
                                                                mOriginalFrameOfSegmentControl.size.width,
                                                                mOriginalFrameOfSegmentControl.size.height);
                             
                             mTableView.frame = CGRectMake(mOriginalFrameOfTableView.origin.x,
                                                           mOriginalFrameOfTableView.origin.y - mOriginalFrameOfTableView.origin.y,
                                                           mOriginalFrameOfTableView.size.width,
                                                           mOriginalFrameOfTableView.size.height + mOriginalFrameOfTableView.origin.y);
                            
                         }
                         completion:^(BOOL finished) {
                             
                             
                         }];
    }
    else
    {
        mSearchBar.frame = CGRectMake(mOriginalFrameOfSearchBar.origin.x,
                                      mOriginalFrameOfSearchBar.origin.y - mOriginalFrameOfTableView.origin.y,
                                      mOriginalFrameOfSearchBar.size.width,
                                      mOriginalFrameOfSearchBar.size.height);
        
        mSegmentControl.frame = CGRectMake(mOriginalFrameOfSegmentControl.origin.x,
                                           mOriginalFrameOfSegmentControl.origin.y - mOriginalFrameOfTableView.origin.y,
                                           mOriginalFrameOfSegmentControl.size.width,
                                           mOriginalFrameOfSegmentControl.size.height);
        
        mTableView.frame = CGRectMake(mOriginalFrameOfTableView.origin.x,
                                      mOriginalFrameOfTableView.origin.y - mOriginalFrameOfTableView.origin.y,
                                      mOriginalFrameOfTableView.size.width,
                                      mOriginalFrameOfTableView.size.height);
    }
}

- (void)showSegmentedControlAndSearchBarAnimated:(BOOL)animated
{
    mIsSearchBarAndSegmentedControlHidden = NO;
    if(animated)
    {
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             mSearchBar.frame = mOriginalFrameOfSearchBar;
                             
                             mSegmentControl.frame = mOriginalFrameOfSegmentControl;
                             
                             mTableView.frame = mOriginalFrameOfTableView;
                         }
                         completion:^(BOOL finished) {
                             
                             
                         }];
    }
    else
    {
        mSearchBar.frame = mOriginalFrameOfSearchBar;
        mSegmentControl.frame = mOriginalFrameOfSegmentControl;
        mTableView.frame = mOriginalFrameOfTableView;
    }
}


- (void)showNoResultsLabel
{
    if(mNoResultsLabel == nil)
    {
        NSString *messageString = @"No recipe found. Please search again.";
        UIFont *messageFont = [UtilityManager fontGetRegularFontOfSize:16];
        CGSize messageSize = [messageString sizeWithFont:messageFont];
        
        mNoResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    mTableView.frame.size.width,
                                                                    messageSize.height)];
        mNoResultsLabel.backgroundColor = [UIColor clearColor];
        mNoResultsLabel.textColor = [UIColor blackColor];
        mNoResultsLabel.text = messageString;
        mNoResultsLabel.textAlignment = UITextAlignmentCenter;
        mNoResultsLabel.hidden = YES;
        mNoResultsLabel.font = messageFont;
        [self.view addSubview:mNoResultsLabel];
    }
    
    mNoResultsLabel.center = CGPointMake(roundf(mTableView.center.x),
                                         roundf(mTableView.center.y));
    
    mNoResultsLabel.hidden = NO;
}

- (void)hideNoResultsLabel
{
    mNoResultsLabel.hidden = YES;
}


#pragma mark - Data Methods

- (NSMutableArray *)dataForTableView
{
    NSMutableArray *array = nil;
    
    if(mIsSearchModeActive)
    {
        array = mSearchModeTableData;
    }
    else
    {
        array = [self dataForSegmentedIndex:mSegmentControl.selectedSegmentIndex];
    }
    
    
    
    // Display and hide of No Results Label
    if(!mIsSearchModeActive)
    {
        if([array count] == 0)
        {
            if(mNoResultsLabel == nil || mNoResultsLabel.hidden)
            {
                [self showNoResultsLabel];
            }
        }
        else
        {
            if(mNoResultsLabel && !mNoResultsLabel.hidden)
            {
                [self hideNoResultsLabel];
            }
        }
    }
    else
    {
        [self hideNoResultsLabel];
    }
    
    
    return array;
}

- (NSMutableArray *)dataForSegmentedIndex:(RecipeViewControllerSegmentedIndex)index
{
    NSMutableArray *array = nil;
    
    switch (index)
    {
        case RecipeViewControllerSegmentedIndexAZ:
        {
            if(mAZTableData == nil)
            {
                [self refreshDataForAZTableView];
            }
            
            array = mAZTableData;
            break;
        }
            
        case RecipeViewControllerSegmentedIndexFlavors:
        {
            if(mFlavorTableData == nil)
            {
                [self refreshDataForFlavorTableView];
            }
            
            array = mFlavorTableData;
            break;
        }
            
        case RecipeViewControllerSegmentedIndexRecipes:
        {
            if(mMixerTableData == nil)
            {
                [self refreshDataForMixerTableView];
            }
            
            array = mMixerTableData;
            break;
        }
            
            
        default:
            break;
    }

    return array;
}

- (NSMutableArray *)currentActiveMixerFilters
{
    if(mSelectedMixerFiltersArray == nil)
    {
        mSelectedMixerFiltersArray = [[NSMutableArray alloc] init];
    }
    
    return mSelectedMixerFiltersArray;
}

- (NSMutableArray *)currentActiveFlavorFilters
{
    if(mSelectedFlavorFiltersArray == nil)
    {
        mSelectedFlavorFiltersArray = [[NSMutableArray alloc] init];
    }
    
    return mSelectedFlavorFiltersArray;
}


- (void)refreshDataForAZTableView
{
    [mAZTableData removeAllObjects];
    [mAZTableData release];
    mAZTableData = [[NSMutableArray alloc] init];
    
    
    NSArray *allRecipes = [[DataManager sharedDataManager] recipesGetAllRecipes];
    NSArray *sortedRecipes = [allRecipes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    NSMutableDictionary *mapForSectionsOfTable = [[NSMutableDictionary alloc] init];
    
    for(Recipe *recipeObject in sortedRecipes)
    {
        if (recipeObject.flavor==Nil) {
            
        }
        else {
            // Grab the first character of the title
            NSString *firstCharacter = [[recipeObject.title substringToIndex:1] uppercaseString];
            
            NSMutableDictionary *sectionDic = [mapForSectionsOfTable valueForKey:firstCharacter];
            if(sectionDic == nil)
            {
                sectionDic = [[NSMutableDictionary alloc] init];
                [sectionDic setValue:firstCharacter forKey:@"sectionTitle"];
                [mapForSectionsOfTable setValue:sectionDic forKey:firstCharacter];
                [sectionDic release];
            }
            
            NSMutableArray *sectionContent = [sectionDic valueForKey:@"sectionContent"];
            if(sectionContent == nil)
            {
                sectionContent = [[NSMutableArray alloc] init];
                [sectionDic setValue:sectionContent forKey:@"sectionContent"];
                [sectionContent release];
            }
            
            [sectionContent addObject:recipeObject];
        }
    }
    
    
    NSArray *allSectionsOfTableInTheMap = [mapForSectionsOfTable allValues];
    NSArray *sortedSections = [allSectionsOfTableInTheMap sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sectionTitle" ascending:YES]]];
    
    for(NSMutableDictionary *sectionDic in sortedSections)
    {
        [mAZTableData addObject:sectionDic];
    }
    
    [mapForSectionsOfTable release];
}


- (void)refreshDataForFlavorTableView
{
    [mFlavorTableData removeAllObjects];
    [mFlavorTableData release];
    mFlavorTableData = [[NSMutableArray alloc] init];
    


    
    NSArray *allFlavors = [[DataManager sharedDataManager] flavorsGetAllFlavors];
    NSMutableArray *flavorsWithAtleastOneRecipe = [[NSMutableArray alloc] init];
    
    for(Flavor *flavorObject in allFlavors)
    {
        if([[flavorObject.recipes allObjects] count] > 0)
        {
            [flavorsWithAtleastOneRecipe addObject:flavorObject];
        }
    }
    
    
    
    
    // Lets apply filters as well.
    
    NSMutableArray *arrayOfFlavorsToBeRemovedBecauseOfFilter = [[NSMutableArray alloc] init];
    if([[self currentActiveFlavorFilters] count] > 0)
    {
        for(Flavor *flavorObject in flavorsWithAtleastOneRecipe)
        {
            BOOL flavorFoundInFilter = NO;
            for(NSString *filterString in [self currentActiveFlavorFilters])
            {                
                if([[flavorObject.title lowercaseString] isEqualToString:[filterString lowercaseString]])
                {
                    flavorFoundInFilter = YES;
                    break;
                }
            }
            
            if(!flavorFoundInFilter)
            {
                [arrayOfFlavorsToBeRemovedBecauseOfFilter addObject:flavorObject];
            }
            
        }
    }
    [flavorsWithAtleastOneRecipe removeObjectsInArray:arrayOfFlavorsToBeRemovedBecauseOfFilter];
    [arrayOfFlavorsToBeRemovedBecauseOfFilter release];
    
    
    
    
    
    
    
    
    [flavorsWithAtleastOneRecipe sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    
    
    for(Flavor *flavorObject in flavorsWithAtleastOneRecipe)
    {
        NSMutableDictionary *sectionDic = [[NSMutableDictionary alloc] init];
        [sectionDic setValue:[NSString stringWithFormat:@"%@ Vodka", flavorObject.title] forKey:@"sectionTitle"];
        
        
        
        
        NSMutableArray *sectionContentArray = [[NSMutableArray alloc] init];
        NSArray *recipes = [flavorObject.recipes allObjects];
        NSArray *sortedRecipes = [recipes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
        for(Recipe *recipeObject in sortedRecipes)
        {
            [sectionContentArray addObject:recipeObject];
        }
        [sectionDic setValue:sectionContentArray forKey:@"sectionContent"];
        [sectionContentArray release];
        
        
        
        
        [mFlavorTableData addObject:sectionDic];
        [sectionDic release];
    }
    
    
    [flavorsWithAtleastOneRecipe release];
}


- (void)refreshDataForMixerTableView
{
    [mMixerTableData removeAllObjects];
    [mMixerTableData release];
    mMixerTableData = [[NSMutableArray alloc] init];

    
    
    NSArray *allRecipes = [[DataManager sharedDataManager] recipesGetAllRecipes];
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    
    for(Recipe *recipeObject in allRecipes)
    {
        if (recipeObject.flavor==Nil) {
            
        }
        else {
            BOOL passesFilterationTest = YES;
            
            for(NSString *filterString in [self currentActiveMixerFilters])
            {
                if(![self isThisString:[filterString lowercaseString] aseperateEntityInTheString:[recipeObject.ingredients lowercaseString]])
                {
                    passesFilterationTest = NO;
                    break;
                }
            }
            
            if(passesFilterationTest)
                [filteredArray addObject:recipeObject];
        }
    }
    

    NSArray *sortedRecipes = [filteredArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    [filteredArray release];
    
    
    NSMutableDictionary *mapForSectionsOfTable = [[NSMutableDictionary alloc] init];
    
    for(Recipe *recipeObject in sortedRecipes)
    {
        // Grab the first character of the title
        NSString *firstCharacter = [[recipeObject.title substringToIndex:1] uppercaseString];
        
        NSMutableDictionary *sectionDic = [mapForSectionsOfTable valueForKey:firstCharacter];
        if(sectionDic == nil)
        {
            sectionDic = [[NSMutableDictionary alloc] init];
            [sectionDic setValue:firstCharacter forKey:@"sectionTitle"];
            [mapForSectionsOfTable setValue:sectionDic forKey:firstCharacter];
            [sectionDic release];
        }
        
        NSMutableArray *sectionContent = [sectionDic valueForKey:@"sectionContent"];
        if(sectionContent == nil)
        {
            sectionContent = [[NSMutableArray alloc] init];
            [sectionDic setValue:sectionContent forKey:@"sectionContent"];
            [sectionContent release];
        }
        
        [sectionContent addObject:recipeObject];
    }
    
    
    NSArray *allSectionsOfTableInTheMap = [mapForSectionsOfTable allValues];
    NSArray *sortedSections = [allSectionsOfTableInTheMap sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sectionTitle" ascending:YES]]];
    
    for(NSMutableDictionary *sectionDic in sortedSections)
    {
        [mMixerTableData addObject:sectionDic];
    }
    
    [mapForSectionsOfTable release];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self dataForTableView] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[[self dataForTableView]  objectAtIndex:section] valueForKey:@"sectionContent"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BVRecipeTabRecipeCell *cell = nil;
    
    NSArray *sectionContentArray = [[[self dataForTableView]  objectAtIndex:indexPath.section] valueForKey:@"sectionContent"];
    
    if([sectionContentArray count] == 1)
    {
        static NSString *CellIdentifier = @"CellFirstAndLast";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[[BVRecipeTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionFirstAndLast] autorelease];
            cell.cellDelegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"CellFirst";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil)
            {
                cell = [[[BVRecipeTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionFirst] autorelease];
                cell.cellDelegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else if(indexPath.row == ([sectionContentArray count] - 1))
        {
            static NSString *CellIdentifier = @"CellLast";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil)
            {
                cell = [[[BVRecipeTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionLast] autorelease];
                cell.cellDelegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else
        {
            static NSString *CellIdentifier = @"CellSandwiched";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil)
            {
                cell = [[[BVRecipeTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionSandwiched] autorelease];
                cell.cellDelegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
    

    
    // Configure the cell...
    Recipe *recipeObject = [sectionContentArray objectAtIndex:indexPath.row];
    [cell updateCellWithRecipe:recipeObject];
    cell.backgroundColor=[UIColor clearColor];
    
    return cell;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *arrayOfIndexTitles = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
        
    return arrayOfIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger closestSection = 0;
    NSInteger storedDifference = 10000000;
    
    unichar indexTitleChar = [[title lowercaseString] characterAtIndex:0];
    NSArray *dataArray = [self dataForTableView];
    for(NSDictionary *sectionDic in dataArray)
    {
        NSString *sectionTitle = [sectionDic valueForKey:@"sectionTitle"];
        unichar firstCharacterOfTitle = [[sectionTitle lowercaseString] characterAtIndex:0];
        
        NSInteger currentDifference = indexTitleChar - firstCharacterOfTitle;
        if(currentDifference < 0)
            currentDifference = -currentDifference;
        
        if(currentDifference < storedDifference)
        {
            storedDifference = currentDifference;
            closestSection = [dataArray indexOfObject:sectionDic];
        }
    }
    
    return closestSection;
}


#pragma mark - Table view Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0;
    
    NSArray *sectionContentArray = [[[self dataForTableView] objectAtIndex:indexPath.section] valueForKey:@"sectionContent"];
    if([sectionContentArray count] == 1)
    {
        rowHeight = [BVRecipeTabRecipeCell rowHeightOfCellWithCellPosition:BVRecipeCellPositionFirstAndLast];
    }
    else
    {
        if(indexPath.row == 0)
        {
            rowHeight = [BVRecipeTabRecipeCell rowHeightOfCellWithCellPosition:BVRecipeCellPositionFirst];
        }
        else if(indexPath.row == ([sectionContentArray count] - 1))
        {
            rowHeight = [BVRecipeTabRecipeCell rowHeightOfCellWithCellPosition:BVRecipeCellPositionLast];
        }
        else
        {
            rowHeight = [BVRecipeTabRecipeCell rowHeightOfCellWithCellPosition:BVRecipeCellPositionSandwiched];
        }
    }
    
    return rowHeight;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImage *sectionHeaderBackgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"TableViewSectionBackgroundImage.png" andAddIfRequired:YES];

    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   tableView.frame.size.width,
                                                                   sectionHeaderBackgroundImage.size.height)] autorelease];
    headerView.backgroundColor = [UIColor clearColor];
    
    
    
    
    // Background Image View
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           tableView.frame.size.width,
                                                                           sectionHeaderBackgroundImage.size.height)];
    imageView.image = sectionHeaderBackgroundImage;
    [headerView addSubview:imageView];
    [imageView release];
    
    
    
    
    NSString *titleString = @"";
    
    if(tableView == mTableView)
    {
        titleString = [[[self dataForTableView] objectAtIndex:section] valueForKey:@"sectionTitle"];
    }
    else
    {
        titleString = @"Section Header Title";
    }
    
    
    
    
    // Title Label
    UIFont *titleFont = [UtilityManager fontGetLightFontOfSize:17];
    CGSize titleSize = [titleString sizeWithFont:titleFont];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                                    0,
                                                                    titleSize.width+20,
                                                                    headerView.frame.size.height)];
    titleLabel.text = titleString;
    titleLabel.font = titleFont;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    [headerView addSubview:titleLabel];
    [titleLabel release];
    
    
    
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Recipe *recipeObject = [[[[self dataForTableView] objectAtIndex:indexPath.section] valueForKey:@"sectionContent"] objectAtIndex:indexPath.row];
    BVRecipeDetailViewController *viewController = [[BVRecipeDetailViewController alloc] initWithRecipe:recipeObject];
    [self.navigationController pushViewController:viewController animated:NO];
    [viewController release];
}

#pragma mark - BVRecipeCell Delegate

- (void)recipeCell:(BVRecipeCell *)cell needsImageReloadForRecipe:(Recipe *)recipeObject
{
    HSLazyLoadImage *lazyImage = [[HSLazyLoadImage alloc] initWithFileName:[recipeObject pngImageFileName]];
    [self startDownloadForLazyLoadImage:lazyImage];
    [lazyImage release];
}



#pragma mark - Helper Methods

- (void)startDownloadForLazyLoadImage:(HSLazyLoadImage *)image
{
    if(mLazyImageDownloader == nil)
    {
        mLazyImageDownloader = [[HSLazyImageDownloader alloc] init];
        mLazyImageDownloader.delegate = self;
    }
    
    [mLazyImageDownloader addLazyLoadImage:image];
}



- (void)reloadCellsWithInfo:(NSDictionary *)infoDic
{
    UIImage *recipeImage = [infoDic valueForKey:@"image"];
    
    
    // Update Cells in AZTableView
    NSArray *arrayOfIndexPathsInAZTableView = [infoDic valueForKey:@"AZTableViewIndexPaths"];
    for(NSIndexPath *indexPath in arrayOfIndexPathsInAZTableView)
    {
        BVRecipeCell *recipeCell = (BVRecipeCell *)[mTableView cellForRowAtIndexPath:indexPath];
        if(recipeCell)
        {
            [recipeCell updateRecipeImageWithImage:recipeImage];
        }
    }
}

- (UITapGestureRecognizer *)tapGestureForSegmentControlForMixers
{
    
    
    if(mTapGestureForSegmentControlForAlreadySelectedMixerSegment == nil)
    {
        mTapGestureForSegmentControlForAlreadySelectedMixerSegment = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnSegmentControlForMixers:)];
    }
    
    return mTapGestureForSegmentControlForAlreadySelectedMixerSegment;
}

- (UITapGestureRecognizer *)tapGestureForSegmentControlForFlavors
{
    
    if(mTapGestureForSegmentControlForAlreadySelectedFlavorSegment == nil)
    {
        mTapGestureForSegmentControlForAlreadySelectedFlavorSegment = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnSegmentControlForFlavors:)];
    }
    
    return mTapGestureForSegmentControlForAlreadySelectedFlavorSegment;
}

- (NSArray *)arrayOfOptionsForMixerDropDownMenuBasedOnCurrentSelectedMixerFilters
{
    NSArray *filterOptionsAvailable = [[DataManager sharedDataManager] mixersGetAllMixers];
    
    NSMutableArray *arrayOfDropDownItems = [[[NSMutableArray alloc] init] autorelease];
    
    for(NSString *filterStringInAllMixers in filterOptionsAvailable)
    {
        BOOL filterAlreadySelected = NO;
        for(NSString *alreadySelectedFilterString in [self currentActiveMixerFilters])
        {
            if([[alreadySelectedFilterString lowercaseString] isEqualToString:[filterStringInAllMixers lowercaseString]])
            {
                filterAlreadySelected = YES;
                break;
            }
        }
        
        
        BVDropDownItem *item = [[BVDropDownItem alloc] init];
        item.itemTitle = filterStringInAllMixers;
        item.isItemSelected = filterAlreadySelected;
        [arrayOfDropDownItems addObject:item];
        [item release];
    }
    
    return [[arrayOfDropDownItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"itemTitle" ascending:YES]]] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"isItemSelected" ascending:NO]]];
}

- (NSArray *)arrayOfOptionsForFlavorDropDownMenuBasedOnCurrentSelectedFlavorFilters
{
    NSArray *filterOptionsAvailable = [[DataManager sharedDataManager] flavorsGetAllFlavors];
    
    NSMutableArray *arrayOfDropDownItems = [[[NSMutableArray alloc] init] autorelease];

    for(Flavor *flavor in filterOptionsAvailable)
    {
        BOOL filterAlreadySelected = NO;
        for(NSString *alreadySelectedFilterString in [self currentActiveFlavorFilters])
        {
            if([[alreadySelectedFilterString lowercaseString] isEqualToString:[flavor.title lowercaseString]])
            {
                filterAlreadySelected = YES;
                break;
            }
        }
        
        
        BVDropDownItem *item = [[BVDropDownItem alloc] init];
        item.itemTitle = flavor.title ;
        item.isItemSelected = filterAlreadySelected;
        [arrayOfDropDownItems addObject:item];
        [item release];
    }

    
    return [[arrayOfDropDownItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"itemTitle" ascending:YES]]] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"isItemSelected" ascending:NO]]];
}

- (BOOL)isThisString:(NSString *)searchString aseperateEntityInTheString:(NSString *)stringToBeSearched
{
    __block BOOL success = NO;
    
    
    NSRegularExpression *regularExpressionForSearchString = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@\\b", searchString] options:NSRegularExpressionCaseInsensitive error:NULL];
    
    
    
    if(mMapOfMixersToFlavorsForMixerFiltering == nil)
    {
        mMapOfMixersToFlavorsForMixerFiltering = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableArray *arrayOfFlavorsHavingSearchStringAsAPart = [mMapOfMixersToFlavorsForMixerFiltering valueForKey:searchString];
    if(arrayOfFlavorsHavingSearchStringAsAPart == nil)
    {
        arrayOfFlavorsHavingSearchStringAsAPart = [[NSMutableArray alloc] init];
        [mMapOfMixersToFlavorsForMixerFiltering setValue:arrayOfFlavorsHavingSearchStringAsAPart forKey:searchString];
        [arrayOfFlavorsHavingSearchStringAsAPart release];
        
        NSArray *allFlavors = [[DataManager sharedDataManager] flavorsGetAllFlavors];
        for(Flavor *flavorObject in allFlavors)
        {
            NSUInteger numberOfMatches = [regularExpressionForSearchString numberOfMatchesInString:flavorObject.title options:NSMatchingReportCompletion range:NSMakeRange(0, [flavorObject.title length])];
            
            if(numberOfMatches > 0)
            {
                [arrayOfFlavorsHavingSearchStringAsAPart addObject:flavorObject];
            }
        }
    }
    

    NSUInteger numberOfMatches = [regularExpressionForSearchString numberOfMatchesInString:stringToBeSearched options:NSMatchingReportCompletion range:NSMakeRange(0, [stringToBeSearched length])];
    if(numberOfMatches > 0)
    {
        if([arrayOfFlavorsHavingSearchStringAsAPart count] > 0)
        {
            [regularExpressionForSearchString enumerateMatchesInString:stringToBeSearched options:0 range:NSMakeRange(0, [stringToBeSearched length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                
                __block BOOL overlapResultFound = NO;
                
                for(Flavor *flavorObject in arrayOfFlavorsHavingSearchStringAsAPart)
                {
                    NSRegularExpression *regularExpressionForFlavor = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@\\b", [flavorObject.title lowercaseString]] options:NSRegularExpressionCaseInsensitive error:NULL];
                    
                    [regularExpressionForFlavor enumerateMatchesInString:stringToBeSearched options:0 range:NSMakeRange(0, [stringToBeSearched length]) usingBlock:^(NSTextCheckingResult *flavorMatch, NSMatchingFlags flavorFlags, BOOL *flavorStop) {
                        
                        NSRange intersection = NSIntersectionRange(flavorMatch.range, match.range);
                        if(intersection.length > 0)
                        {
                            overlapResultFound = YES;
                            *flavorStop = TRUE;
                        }
                        
                    }];
                    
                    [regularExpressionForFlavor release];
                }
                
                if(!overlapResultFound)
                {
                    success = YES;
                }                
            }];
        }
        else
        {
            success = YES;
        }
    }
    
    
    
    
    
    
    
    
    
    [regularExpressionForSearchString release];
    
    return success;
}


- (NSInteger)indexOfSegmentTouchedByUserInSegmentedControl:(UISegmentedControl *)segmentedControl withTouchPoint:(CGPoint)touchPoint
{
    NSInteger index = 0;
    
    CGFloat xCoordinatePointer = 0;
    
    for(int i=0; i<segmentedControl.numberOfSegments; i++)
    {
        if(touchPoint.x >= xCoordinatePointer)
        {
            if(touchPoint.x < (xCoordinatePointer + [segmentedControl widthForSegmentAtIndex:i]))
            {
                index = i;
                break;
            }
        }
        
        xCoordinatePointer = xCoordinatePointer + [segmentedControl widthForSegmentAtIndex:i];
    }
    
    return index;
}


#pragma mark - HSLazyImageDownloader Delegate Methods

- (void)imageDownloader:(HSLazyImageDownloader *)downloader finishedLoadingForImage:(HSLazyLoadImage *)image
{
    // This callback shall be at NON main thread.
        
    // Add it to cache
    [[UtilityManager sharedUtilityManager] cacheAddImage:image.image againstCompleteFileName:image.fileName];
    
    
    
    // Check and find Index Paths for cells in the AZ TableView
    
    NSMutableArray *mutableArrayOfIndexPathsInAZTableView = [[NSMutableArray alloc] init];
    
    for(int i=0; i<[[self dataForTableView] count]; i++)
    {
        NSArray *sectionContentArray = [[[self dataForTableView] objectAtIndex:i] valueForKey:@"sectionContent"];
        for(int j=0; j<[sectionContentArray count]; j++)
        {
            Recipe *recipeObject = [sectionContentArray objectAtIndex:j];
            
            if([image.fileName isEqualToString:[recipeObject pngImageFileName]])
            {                
                [mutableArrayOfIndexPathsInAZTableView addObject:[NSIndexPath indexPathForRow:j inSection:i]];
            }
        }
    }
    
    NSArray *arrayOfIndexPathsInAZTableView = [NSArray arrayWithArray:mutableArrayOfIndexPathsInAZTableView];
    [mutableArrayOfIndexPathsInAZTableView release];
    

    
    
    
    
    
    NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:image.image, @"image", arrayOfIndexPathsInAZTableView, @"AZTableViewIndexPaths", nil];

    [self performSelectorOnMainThread:@selector(reloadCellsWithInfo:) withObject:infoDic waitUntilDone:NO];
}


#pragma mark - Action Methods

- (void)segmentControlValueChanged:(id)sender
{
    if ([mSearchBar.mTextField.text isEqualToString:@""]) {
        [self searchBar:mSearchBar searchTextChangedTo:@""];
    }
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    NSString *segmentNameForWDASubmission = @"";
    
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            segmentNameForWDASubmission = @"A-Z";
            [segmentedControl setImage:[self imageForAZTabSelected:YES] forSegmentAtIndex:0];
            [segmentedControl setImage:[self imageForFlavorTabSelected:NO] forSegmentAtIndex:1];
            [segmentedControl setImage:[self imageForMixersTabSelected:NO] forSegmentAtIndex:2];
            
            UITapGestureRecognizer *tapGestureForMixer = [self tapGestureForSegmentControlForMixers];
            [mSegmentControl removeGestureRecognizer:tapGestureForMixer];
            
            UITapGestureRecognizer *tapGestureForFlavor = [self tapGestureForSegmentControlForFlavors];
            [mSegmentControl removeGestureRecognizer:tapGestureForFlavor];
            
            
            if(mMixerDropDownMenuView)
                [self hideMixerSelectionDropDown];
            
            if(mFlavorDropDownMenuView)
                [self hideFlavorSelectionDropDown];
            
            mMixerDropDownMenuView = [[BVDropDownMenuView alloc] initWithOptions:[self arrayOfOptionsForMixerDropDownMenuBasedOnCurrentSelectedMixerFilters]];
            mMixerDropDownMenuView.viewDelegate = self;
            mMixerDropDownMenuView.alpha = 0.0;
            [mMixerDropDownMenuView resetButtonClicked:nil];
            [mMixerDropDownMenuView continueButtonClicked:nil];
            mTranslucentOverlayDuringMixerDropDown.hidden = YES;
            mMixerDropDownMenuView.viewDelegate = nil;
            [mMixerDropDownMenuView removeFromSuperview];
            [mMixerDropDownMenuView release];
            mMixerDropDownMenuView = nil;

            mFlavorDropDownMenuView = [[BVDropDownMenuView alloc] initWithOptions:[self arrayOfOptionsForFlavorDropDownMenuBasedOnCurrentSelectedFlavorFilters]];
            mFlavorDropDownMenuView.viewDelegate = self;
            mFlavorDropDownMenuView.alpha = 0.0;
            mTranslucentOverlayDuringFlavorDropDown.hidden = YES;
            [mFlavorDropDownMenuView resetButtonClicked:nil];
            [mFlavorDropDownMenuView continueButtonClicked:nil];
            mFlavorDropDownMenuView.viewDelegate = nil;
            [mFlavorDropDownMenuView removeFromSuperview];
            [mFlavorDropDownMenuView release];
            mFlavorDropDownMenuView = nil;

            
            
            break;
        }
            
        case 1:
        {
            segmentNameForWDASubmission = @"Flavor";
            [segmentedControl setImage:[self imageForAZTabSelected:NO] forSegmentAtIndex:0];
            [segmentedControl setImage:[self imageForFlavorTabSelected:YES] forSegmentAtIndex:1];
            [segmentedControl setImage:[self imageForMixersTabSelected:NO] forSegmentAtIndex:2];
            
            
            if(mMixerDropDownMenuView)
                [self hideMixerSelectionDropDown];
            
            
            
            UITapGestureRecognizer *tapGestureForMixer = [self tapGestureForSegmentControlForMixers];
            [mSegmentControl removeGestureRecognizer:tapGestureForMixer];
            
            
            // We shall add a tap gesture to segment control to detect tap on Flavors segment even when it is already selected.
            UITapGestureRecognizer *tapGestureForFlavors = [self tapGestureForSegmentControlForFlavors];
            [mSegmentControl addGestureRecognizer:tapGestureForFlavors];
            
            
            
            if([[self currentActiveFlavorFilters] count] == 0)
            {
                [self showFlavorSelectionDropDownWithOptions:[self arrayOfOptionsForFlavorDropDownMenuBasedOnCurrentSelectedFlavorFilters]];
            }
            
            break;
        }
            
        case 2:
        {
            segmentNameForWDASubmission = @"Mixer";
            [segmentedControl setImage:[self imageForAZTabSelected:NO] forSegmentAtIndex:0];
            [segmentedControl setImage:[self imageForFlavorTabSelected:NO] forSegmentAtIndex:1];
            [segmentedControl setImage:[self imageForMixersTabSelected:YES] forSegmentAtIndex:2];
            
            
            if(mFlavorDropDownMenuView)
                [self hideFlavorSelectionDropDown];
            
            
            UITapGestureRecognizer *tapGestureForFlavor = [self tapGestureForSegmentControlForFlavors];
            [mSegmentControl removeGestureRecognizer:tapGestureForFlavor];
            
            
            // We shall add a tap gesture to segment control to detect tap on Mixers segment even when it is already selected.
            UITapGestureRecognizer *tapGestureForMixer = [self tapGestureForSegmentControlForMixers];
            [mSegmentControl addGestureRecognizer:tapGestureForMixer];
            
            
            
            if([[self currentActiveMixerFilters] count] == 0)
            {
                [self showMixerSelectionDropDownWithOptions:[self arrayOfOptionsForMixerDropDownMenuBasedOnCurrentSelectedMixerFilters]];
            }
            
            break;
        }
            
        default:
            break;
    }
    
    

    
    
    [mTableView reloadData];
    [mTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}





#pragma mark - Getter Methods

- (UIImage *)imageForAZTabSelected:(BOOL)isSelected
{
    UIImage *image = nil;
    
    if(isSelected)
    {
        NSString *imgstr;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            imgstr = @"RecipeTabAZTabSelected";
        }
        else {
            imgstr = @"RecipeTabAZTabSelectedS";
        }

        if(mImageAZTabSelected == nil)
        {
            mImageAZTabSelected = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgstr ofType:@"png"]];

            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 // iOS 7.0 supported
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                UIImage *renderedImage = [mImageAZTabSelected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                
                [mImageAZTabSelected release];
                mImageAZTabSelected = [renderedImage retain];
            }
#endif
        }
        UIColor *color = [UIColor whiteColor];
       mSearchBar.mTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"search all recipes" attributes:@{NSForegroundColorAttributeName: color}];
        image = mImageAZTabSelected;
    }
    else
    {
        NSString *imgstr;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            imgstr = @"RecipeTabAZTabUnselected";
        }
        else {
            imgstr = @"RecipeTabAZTabUnselectedS";
        }

        if(mImageAZTabUnselected == nil)
        {
            mImageAZTabUnselected = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgstr ofType:@"png"]];

            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 // iOS 7.0 supported
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                UIImage *renderedImage = [mImageAZTabUnselected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                
                [mImageAZTabUnselected release];
                mImageAZTabUnselected = [renderedImage retain];
            }
#endif
        }
        
        
        image = mImageAZTabUnselected;
    }
    
    return image;
}

- (UIImage *)imageForFlavorTabSelected:(BOOL)isSelected
{
    UIImage *image = nil;

    
    if(isSelected)
    {
        NSString *imgstr;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            imgstr = @"RecipeTabFlavorsTabSelected";
        }
        else {
            imgstr = @"RecipeTabFlavorsTabSelectedS";
        }
        if(mImageFlavorTabSelected == nil)
        {
            mImageFlavorTabSelected = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgstr ofType:@"png"]];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 // iOS 7.0 supported
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                UIImage *renderedImage = [mImageFlavorTabSelected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                
                [mImageFlavorTabSelected release];
                mImageFlavorTabSelected = [renderedImage retain];
            }
#endif
        }
        UIColor *color = [UIColor whiteColor];
        mSearchBar.mTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: color}];
        image = mImageFlavorTabSelected;
    }
    else
    {
        NSString *imgstr;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            imgstr = @"RecipeTabFlavorsTabUnselected";
        }
        else {
            imgstr = @"RecipeTabFlavorsTabUnselectedS";
        }
        if(mImageFlavorTabUnselected == nil)
        {
            mImageFlavorTabUnselected = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgstr ofType:@"png"]];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 // iOS 7.0 supported
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                UIImage *renderedImage = [mImageFlavorTabUnselected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                
                [mImageFlavorTabUnselected release];
                mImageFlavorTabUnselected = [renderedImage retain];
            }
#endif
        }
        
        
        image = mImageFlavorTabUnselected;
    }
    
    return image;
}

- (UIImage *)imageForMixersTabSelected:(BOOL)isSelected
{
    UIImage *image = nil;

    
    if(isSelected)
    {
        NSString *imgstr;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            imgstr = @"RecipeTabMixersTabSelected";
        }
        else {
            imgstr = @"RecipeTabMixersTabSelectedS";
        }

        if(mImageRecipesTabSelected == nil)
        {
            mImageRecipesTabSelected = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgstr ofType:@"png"]];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 // iOS 7.0 supported
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                UIImage *renderedImage = [mImageRecipesTabSelected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                
                [mImageRecipesTabSelected release];
                mImageRecipesTabSelected = [renderedImage retain];
            }
#endif
        }
        
        UIColor *color = [UIColor whiteColor];
        mSearchBar.mTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: color}];
        image = mImageRecipesTabSelected;
    }
    else
    {
        NSString *imgstr;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            imgstr = @"RecipeTabMixersTabUnselected";
        }
        else {
            imgstr = @"RecipeTabMixersTabUnselectedS";
        }
        if(mImageRecipesTabUnselected == nil)
        {
            mImageRecipesTabUnselected = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgstr ofType:@"png"]];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 // iOS 7.0 supported
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                UIImage *renderedImage = [mImageRecipesTabUnselected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                
                [mImageRecipesTabUnselected release];
                mImageRecipesTabUnselected = [renderedImage retain];
            }
#endif
        }
        
        
        image = mImageRecipesTabUnselected;
    }
    
    return image;
}




#pragma mark - NSNotification Methods

- (void)keyboardWillAppear:(NSNotification *)notificaiton
{
    if(mIsSearchModeActive)
        return;
    
    
    if([self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] -1)] == self)
    {
        mIsSearchModeActive = YES;

        CGRect beginKeyboardRect = [[[notificaiton userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGFloat heightOfTabBar = [(BVTabBarController *)self.parentViewController.parentViewController tabBar].frame.size.height;
        CGRect newFrameOfTheTableAfterAnimation = CGRectMake(mOriginalFrameOfTableView.origin.x,
                                                             mOriginalFrameOfTableView.origin.y - (mOriginalFrameOfSegmentControl.origin.y + mOriginalFrameOfSegmentControl.size.height-20),
                                                             mOriginalFrameOfTableView.size.width,
                                                             mOriginalFrameOfSegmentControl.origin.y + mOriginalFrameOfSegmentControl.size.height + mOriginalFrameOfTableView.size.height + self.navigationController.navigationBar.frame.size.height - (beginKeyboardRect.size.height - heightOfTabBar));
        
        
        // Configure the translucentOverlay
        [mTranslucentOverlayDuringSearchMode removeFromSuperview];
        [mTranslucentOverlayDuringSearchMode release];
        mTranslucentOverlayDuringSearchMode = [[UIView alloc] initWithFrame:mTableView.frame];
        mTranslucentOverlayDuringSearchMode.backgroundColor = [UIColor blackColor];
        mTranslucentOverlayDuringSearchMode.alpha = 0.0;
        
        UITapGestureRecognizer *tapGentureOnOverlay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayInSeachModeTapped:)];
        [mTranslucentOverlayDuringSearchMode addGestureRecognizer:tapGentureOnOverlay];
        [tapGentureOnOverlay release];
        
        [self.view addSubview:mTranslucentOverlayDuringSearchMode];
        
        
        
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             mSearchBar.frame = CGRectMake(mOriginalFrameOfSearchBar.origin.x,
                                                           mOriginalFrameOfSearchBar.origin.y - (mOriginalFrameOfSegmentControl.origin.y + mOriginalFrameOfSegmentControl.size.height-20),
                                                           mOriginalFrameOfSearchBar.size.width,
                                                           mOriginalFrameOfSearchBar.size.height);
                             
                             mSegmentControl.frame = CGRectMake(mOriginalFrameOfSegmentControl.origin.x,
                                                                mOriginalFrameOfSegmentControl.origin.y - (mOriginalFrameOfSegmentControl.origin.y + mOriginalFrameOfSegmentControl.size.height-20),
                                                                mOriginalFrameOfSegmentControl.size.width,
                                                                mOriginalFrameOfSegmentControl.size.height);
                             
                             mTableView.frame = newFrameOfTheTableAfterAnimation;
                             
                             mTranslucentOverlayDuringSearchMode.frame = newFrameOfTheTableAfterAnimation;
                             mTranslucentOverlayDuringSearchMode.alpha = 0.5;
                         }
                         completion:^(BOOL finished) {
                             
                             
                         }];
    }
}

- (void)keyboardDidAppear:(NSNotification *)notificaiton
{
    
}

- (void)keyboardWillHide:(NSNotification *)notificaiton
{

}

- (void)keyboardDidHide:(NSNotification *)notificaiton
{

}


#pragma mark - BVSearchBar Delegate Methods

- (void)searchBar:(BVSearchBar *)searchBar searchTextChangedTo:(NSString *)searchText
{
    if(!mIsSearchModeActive)
        return;
    NSString *event = @"Search";
    NSString *value = [[NSString stringWithFormat:@"%@", searchText] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:@"search_text"]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event    // Event category (required)
                                                          action:@"Search Text"  // Event action (required)
                                                           label:searchText          // Event label
                                                           value:nil] build]];
    
    NSMutableArray *searchResultsArray = [[NSMutableArray alloc] init];
    
    NSArray *completeData = [self dataForSegmentedIndex:mSegmentControl.selectedSegmentIndex];
    for(NSDictionary *sectionDic in completeData)
    {
        NSString *sectionTitle = [sectionDic valueForKey:@"sectionTitle"];
        NSArray *sectionContentArray = [sectionDic valueForKey:@"sectionContent"];
        for(Recipe *recipeObject in sectionContentArray)
        {
            NSRange matchRange = [[recipeObject.title lowercaseString] rangeOfString:[[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString]];
            if(matchRange.location != NSNotFound)
            {
                NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:recipeObject, @"recipe", sectionTitle, @"sectionTitle", nil];
                [searchResultsArray addObject:resultDic];
                [resultDic release];
            }
        }
    }
    
    if([searchResultsArray count] == 0 && (searchText == nil || [[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]))
    {
        mTranslucentOverlayDuringSearchMode.hidden = NO;
        
        [mSearchModeTableData release];
        mSearchModeTableData = [[NSMutableArray alloc] init];
        
        for(NSDictionary *sectionDic in completeData)
        {
            [mSearchModeTableData addObject:sectionDic];
        }
        
        [mTableView reloadData];
    }
    else
    {
        mTranslucentOverlayDuringSearchMode.hidden = YES;
        
        NSInteger countOfRecipeResultsInExistingSearchArray = 0;
        for(NSDictionary *sectionDic in mSearchModeTableData)
        {
            NSArray *sectionContentArray = [sectionDic valueForKey:@"sectionContent"];
            for(Recipe *recipeObject in sectionContentArray)
            {
                countOfRecipeResultsInExistingSearchArray++;
            }
        }
        
        
        if(countOfRecipeResultsInExistingSearchArray != [searchResultsArray count])
        {
            [mSearchModeTableData release];
            mSearchModeTableData = [[NSMutableArray alloc] init];
            
            
            
            NSArray *sortedSearchResultsArray = [searchResultsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"recipe.title" ascending:YES]]];
            NSMutableDictionary *mapForSectionsOfTable = [[NSMutableDictionary alloc] init];
            
            for(NSDictionary *resultDic in sortedSearchResultsArray)
            {
                NSString *sectionTitle = [resultDic valueForKey:@"sectionTitle"];
                
                NSMutableDictionary *sectionDic = [mapForSectionsOfTable valueForKey:sectionTitle];
                if(sectionDic == nil)
                {
                    sectionDic = [[NSMutableDictionary alloc] init];
                    [sectionDic setValue:sectionTitle forKey:@"sectionTitle"];
                    [mapForSectionsOfTable setValue:sectionDic forKey:sectionTitle];
                    [sectionDic release];
                }
                
                NSMutableArray *sectionContent = [sectionDic valueForKey:@"sectionContent"];
                if(sectionContent == nil)
                {
                    sectionContent = [[NSMutableArray alloc] init];
                    [sectionDic setValue:sectionContent forKey:@"sectionContent"];
                    [sectionContent release];
                }
                
                Recipe *recipeObject = [resultDic valueForKey:@"recipe"];
                [sectionContent addObject:recipeObject];
            }
            
            
            NSArray *allSectionsOfTableInTheMap = [mapForSectionsOfTable allValues];
            NSArray *sortedSections = [allSectionsOfTableInTheMap sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sectionTitle" ascending:YES]]];
            
            for(NSMutableDictionary *sectionDic in sortedSections)
            {
                [mSearchModeTableData addObject:sectionDic];
            }
            
            [mapForSectionsOfTable release];
            
            [mTableView reloadData];
        }
    }
    
    [self configureViewOutOfSearchMode];
    
    [searchResultsArray release];
}

- (void)searchBarUserTappedCancel:(BVSearchBar *)searchBar
{
    mIsSearchModeActive = NO;
    
    [mSearchModeTableData release];
    mSearchModeTableData = nil;
    
    
    if([self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] -1)] == self)
    {
        [self configureViewOutOfSearchMode];
    }
}


#pragma mark - UIGesture Action Methods

- (void)overlayInSeachModeTapped:(UITapGestureRecognizer *)gesture
{
    [mSearchBar resignSearchBar];
}

- (void)dropDownTranslucentLayerForMixerTapped:(UITapGestureRecognizer *)gesture
{
    [self hideMixerSelectionDropDown];
}

- (void)dropDownTranslucentLayerForFlavorTapped:(UITapGestureRecognizer *)gesture
{
    [self hideFlavorSelectionDropDown];
}

- (void)tapOnSegmentControlForMixers:(UITapGestureRecognizer *)gesture
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        CGPoint touchPoint = [gesture locationInView:gesture.view];
        NSInteger indexOfSegmentTapped = [self indexOfSegmentTouchedByUserInSegmentedControl:mSegmentControl withTouchPoint:touchPoint];
        if(indexOfSegmentTapped != 2)
        {
            [mSegmentControl setSelectedSegmentIndex:indexOfSegmentTapped];
            [self segmentControlValueChanged:mSegmentControl];
            return;
        }
    }
    
    if(mSegmentControl.selectedSegmentIndex == 2)
    {
        [self showMixerSelectionDropDownWithOptions:[self arrayOfOptionsForMixerDropDownMenuBasedOnCurrentSelectedMixerFilters]];
    }
}

- (void)tapOnSegmentControlForFlavors:(UITapGestureRecognizer *)gesture
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        CGPoint touchPoint = [gesture locationInView:gesture.view];
        NSInteger indexOfSegmentTapped = [self indexOfSegmentTouchedByUserInSegmentedControl:mSegmentControl withTouchPoint:touchPoint];
        if(indexOfSegmentTapped != 1)
        {
            [mSegmentControl setSelectedSegmentIndex:indexOfSegmentTapped];
            [self segmentControlValueChanged:mSegmentControl];
            return;
        }
    }
    
    if(mSegmentControl.selectedSegmentIndex == 1)
    {
        [self showFlavorSelectionDropDownWithOptions:[self arrayOfOptionsForFlavorDropDownMenuBasedOnCurrentSelectedFlavorFilters]];
    }
}


#pragma mark -
#pragma mark NSNotification Methods

- (void)recipeRatingsDataChanged:(NSNotification *)notification
{    
    NSArray *arrayOfRecipesForWhichDataHasChanged = [notification object];
    NSArray *arrayOfIndexPathsOfVisibleCells = [mTableView indexPathsForVisibleRows];
    NSMutableArray *arrayOfIndexPathsToReload = [NSMutableArray array];
    
    for(NSIndexPath *indexPath in arrayOfIndexPathsOfVisibleCells)
    {
        Recipe *recipeObjectInTableView = [[[[self dataForTableView] objectAtIndex:indexPath.section] valueForKey:@"sectionContent"] objectAtIndex:indexPath.row];
        
        if([arrayOfRecipesForWhichDataHasChanged containsObject:recipeObjectInTableView])
        {
            [arrayOfIndexPathsToReload addObject:indexPath];
        }
    }
    
    
    [mTableView beginUpdates];
    [mTableView reloadRowsAtIndexPaths:arrayOfIndexPathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
    [mTableView endUpdates];
}


#pragma mark -
#pragma mark BVDropDownMenuView Delegate Methods

- (void)userPressedResetButtonOnDropDownMenuView:(BVDropDownMenuView *)view withSelectedOptions:(NSArray *)arrayOfSelectedOptions
{
    NSString *stringOfSelectedOptions = @"";
    if([arrayOfSelectedOptions count] > 0)
    {
        NSMutableArray *arrayOfStrings = [[NSMutableArray alloc] init];
        for(BVDropDownItem *item in arrayOfSelectedOptions)
        {
            if(item.itemTitle)
            {
                [arrayOfStrings addObject:item.itemTitle];
            }
        }
        
        stringOfSelectedOptions = [arrayOfStrings componentsJoinedByString:@","];
        [arrayOfStrings release];
    }
    
    NSString *filterTypeString = @"";
    if(view == mMixerDropDownMenuView)
    {
        filterTypeString = @"Mixer";
    }
    else if(view == mFlavorDropDownMenuView)
    {
        filterTypeString = @"Flavor";
    }
    
   
}


- (void)dropDownMenuView:(BVDropDownMenuView *)view userPressedContinueButtonWithSelectedOptions:(NSArray *)arrayOfSelectedOptions
{
    NSString *stringOfSelectedOptions = @"";
    if([arrayOfSelectedOptions count] > 0)
    {
        NSMutableArray *arrayOfStrings = [[NSMutableArray alloc] init];
        for(BVDropDownItem *item in arrayOfSelectedOptions)
        {
            if(item.itemTitle)
            {
                [arrayOfStrings addObject:item.itemTitle];
            }
        }
        
        stringOfSelectedOptions = [arrayOfStrings componentsJoinedByString:@","];
        [arrayOfStrings release];
    }
    
    NSString *filterTypeString = @"";
    
    if(view == mFlavorDropDownMenuView)
    {
        filterTypeString = @"Flavor";
        
        [[self currentActiveFlavorFilters] removeAllObjects];
        for(BVDropDownItem *item in arrayOfSelectedOptions)
        {
            [[self currentActiveFlavorFilters] addObject:item.itemTitle];
        }
        
        [self hideFlavorSelectionDropDown];
        [self refreshDataForFlavorTableView];
        [mTableView reloadData];
    }
    else if(view == mMixerDropDownMenuView)
    {
        filterTypeString = @"Mixer";
        [[self currentActiveMixerFilters] removeAllObjects];
        for(BVDropDownItem *item in arrayOfSelectedOptions)
        {
            [[self currentActiveMixerFilters] addObject:item.itemTitle];
        }
        
        [self hideMixerSelectionDropDown];
        [self refreshDataForMixerTableView];
        [mTableView reloadData];
    }

    
    
}

- (void)userPressedCancelButtonOnDropDownMenuView:(BVDropDownMenuView *)view
{
    NSString *filterTypeString = @"";
    NSArray *arrayOfActiveFilters = nil;
    
    NSString *stringOfSelectedOptions = @"";
    if([arrayOfActiveFilters count] > 0)
    {
        stringOfSelectedOptions = [arrayOfActiveFilters componentsJoinedByString:@","];
    }
    
    
    
    if(view == mFlavorDropDownMenuView)
    {
        filterTypeString = @"Flavor";
        arrayOfActiveFilters = [self currentActiveFlavorFilters];
    }
    else if(view == mMixerDropDownMenuView)
    {
        filterTypeString = @"Mixer";
        arrayOfActiveFilters = [self currentActiveMixerFilters];
    }
    
   
    
    
    
    
    
    if(view == mFlavorDropDownMenuView)
    {
        [self hideFlavorSelectionDropDown];
    }
    else if(view == mMixerDropDownMenuView)
    {
        [self hideMixerSelectionDropDown];
    }
}



#pragma mark -
#pragma mark UIScrollView Delegate Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(mIsSearchModeActive)
        return;
    
    if(mTableView.contentOffset.y > 0 && !mIsSearchBarAndSegmentedControlHidden)
    {
       // [self hideSegmentedControlAndSearchBarAnimated:YES];
    }
    else if(mTableView.contentOffset.y < -kMinimumPullToShowSearchBarAndSegmentedControl && mIsSearchBarAndSegmentedControlHidden)
    {
       // [self showSegmentedControlAndSearchBarAnimated:YES];
    }
}



@end
