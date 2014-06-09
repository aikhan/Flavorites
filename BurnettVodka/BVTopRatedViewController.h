//
//  BVTopRatedViewController.h
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSLazyImageDownloader.h"
#import "BVTopRatedTabRecipeCell.h"
#import "GAITrackedViewController.h"

@interface BVTopRatedViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, HSLazyImageDownloaderDelegate, BVRecipeCellDelegate> {
    
    UITableView *mTableView;
    UIImageView *mBackgroundImageView;
    UILabel *mInformatiiveMessageLabel;
    
    NSMutableArray *mTableData;
    HSLazyImageDownloader *mLazyImageDownloader;
}

@end
