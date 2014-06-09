//
//  BVFavoritesViewController.h
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSLazyImageDownloader.h"
#import "BVFavTabRecipeCell.h"
#import "GAITrackedViewController.h"

@interface BVFavoritesViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, HSLazyImageDownloaderDelegate, BVRecipeCellDelegate, BVFavTabRecipeCellDelegate> {
    
    UITableView *mTableView;
    UIImageView *mBackgroundImageView;
    UILabel *mInformatiiveMessageLabel;
    
    NSMutableArray *mTableData;
    HSLazyImageDownloader *mLazyImageDownloader;
    
    NSIndexPath *_indexPathForCellWithActiveDeleteView;
}

@property (nonatomic, retain) NSIndexPath *indexPathForCellWithActiveDeleteView;

@end
