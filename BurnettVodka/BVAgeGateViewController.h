//
//  BVAgeGateViewController.h
//  BurnettVodka
//
//  Created by admin on 8/15/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class BVAgeGateViewController;

@protocol BVAgeGateViewControllerDelegate <NSObject>

- (void)userDeterminedAsLegalOnBVAgeGateViewController:(BVAgeGateViewController *)controller;

@end

@interface BVAgeGateViewController : GAITrackedViewController {
    
    UIImageView *mBackgroundImageView;
    UIDatePicker *mDatePickerView;
    UIButton *rememberButton;
    UILabel *datelbl;
    BOOL remmberfl;
    
    id <BVAgeGateViewControllerDelegate> controllerDelegate;
}

@property (nonatomic, assign) id <BVAgeGateViewControllerDelegate> controllerDelegate;

@end
