//
//  BVHomeViewController.h
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVCoverFlowScrollView.h"
#import "GAITrackedViewController.h"


@interface BVHomeViewController : GAITrackedViewController <UIScrollViewDelegate, BVCoverFlowScrollViewDelegate> {
    
    BVCoverFlowScrollView *mScrollView;
    UIImageView *mBackgroundImageView;
}

- (void)reload;

@end
