//
//  BVRecipesForFlavorViewController.h
//  BurnettVodka
//
//  Created by admin on 7/26/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVRecipeCell.h"
#import "HSLazyImageDownloader.h"
#import "GAITrackedViewController.h"

@class Flavor;

@interface BVRecipesForFlavorViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, HSLazyImageDownloaderDelegate, BVRecipeCellDelegate> {
    
    UITableView *mTableView;
    UIImageView *mBackgroundImageView;
    
    NSMutableArray *mTableData;
    HSLazyImageDownloader *mLazyImageDownloader;
    Flavor *mFlavor;
}

- (id)initWithFlavor:(Flavor *)flavor;

@end
