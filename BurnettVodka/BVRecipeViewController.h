//
//  BVRecipeViewController.h
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVSearchBar.h"
#import "HSLazyImageDownloader.h"
#import "BVRecipeTabRecipeCell.h"
#import "BVDropDownMenuView.h"
#import "GAITrackedViewController.h"

typedef enum {
    RecipeViewControllerSegmentedIndexAZ,
    RecipeViewControllerSegmentedIndexFlavors,
    RecipeViewControllerSegmentedIndexRecipes
} RecipeViewControllerSegmentedIndex;


@interface BVRecipeViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, BVSearchBarDelegate, HSLazyImageDownloaderDelegate, BVRecipeCellDelegate, BVDropDownMenuViewDelegate> {
    
    UITableView *mTableView;
    UIImageView *mBackgroundImageView;
    UISegmentedControl *mSegmentControl;
    BVSearchBar *mSearchBar;
    UIView *mTranslucentOverlayDuringSearchMode;
    BVDropDownMenuView *mMixerDropDownMenuView;
    BVDropDownMenuView *mFlavorDropDownMenuView;
    UIView *mTranslucentOverlayDuringMixerDropDown;
    UIView *mTranslucentOverlayDuringFlavorDropDown;
    UILabel *mNoResultsLabel;
    
    NSMutableArray *mAZTableData;
    NSMutableArray *mFlavorTableData;
    NSMutableArray *mMixerTableData;
    NSMutableArray *mSearchModeTableData;
    NSMutableArray *mSelectedMixerFiltersArray;
    NSMutableArray *mSelectedFlavorFiltersArray;
    NSMutableDictionary *mMapOfMixersToFlavorsForMixerFiltering;
    UIImage *mImageAZTabSelected;
    UIImage *mImageAZTabUnselected;
    UIImage *mImageFlavorTabSelected;
    UIImage *mImageFlavorTabUnselected;
    UIImage *mImageRecipesTabSelected;
    UIImage *mImageRecipesTabUnselected;
    
    UITapGestureRecognizer *mTapGestureForSegmentControlForAlreadySelectedMixerSegment;
    UITapGestureRecognizer *mTapGestureForSegmentControlForAlreadySelectedFlavorSegment;
    
    HSLazyImageDownloader *mLazyImageDownloader;
    
    CGRect mOriginalFrameOfSearchBar;
    CGRect mOriginalFrameOfSegmentControl;
    CGRect mOriginalFrameOfTableView;
    
    BOOL mIsSearchModeActive;
    BOOL mIsSearchBarAndSegmentedControlHidden;
}

@end
