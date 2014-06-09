//
//  BVFlavorViewController.h
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class Flavor;

@class BVFlavorView;

@protocol BVFlavorViewDelegate <NSObject>

- (void)flavorView:(BVFlavorView *)flavorView userTappedOnViewWithFlavor:(Flavor *)flavor;

@end

@interface BVFlavorView : UIView {
    
    Flavor *mFlavor;
    NSDictionary *mFlavorInfoDictionary;
    
    id <BVFlavorViewDelegate> viewDelegate;
}

@property (nonatomic, assign) id <BVFlavorViewDelegate> viewDelegate;

- (id)initWithFrame:(CGRect)frame andFlavor:(Flavor *)flavorObject;
- (id)initWithFrame:(CGRect)frame andFlavorDictionary:(NSDictionary *)flavorDic;

@end


@interface BVFlavorViewController : GAITrackedViewController <BVFlavorViewDelegate> {
    
    UIScrollView *mScrollView;
    UIImageView *mBackgroundImageView;
}

@property (nonatomic, retain) UIScrollView *mScrollView;

@end
