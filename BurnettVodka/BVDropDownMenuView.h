//
//  BVDropDownMenuView.h
//  BurnettVodka
//
//  Created by admin on 7/31/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BVDropDownItem : NSObject {
    
    NSString *_itemTitle;
    BOOL _isItemSelected;
}

@property (nonatomic, copy) NSString *itemTitle;
@property (nonatomic, assign) BOOL isItemSelected;

@end



@class BVDropDownMenuView;

@protocol BVDropDownMenuViewDelegate <NSObject>

- (void)dropDownMenuView:(BVDropDownMenuView *)view userPressedContinueButtonWithSelectedOptions:(NSArray *)arrayOfSelectedOptions;
- (void)userPressedCancelButtonOnDropDownMenuView:(BVDropDownMenuView *)view;
- (void)userPressedResetButtonOnDropDownMenuView:(BVDropDownMenuView *)view withSelectedOptions:(NSArray *)arrayOfSelectedOptions;

@end

@interface BVDropDownMenuView : UIView <UITableViewDelegate, UITableViewDataSource> {
    
    UIImageView *mBackgroundImageView;
    UIImageView *mArrowImageView;
    UIView *mContentView;
    UITableView *mTableView;
    UILabel *mMessageLabel;
    UIButton *mContinueButton;
    UIButton *mResetButton;
    UIButton *mCancelButton;
    
    NSArray *mTableData;
    
    id <BVDropDownMenuViewDelegate> viewDelegate;
}

@property (nonatomic, assign) id <BVDropDownMenuViewDelegate> viewDelegate;

- (void)resetButtonClicked:(id)sender;
- (void)continueButtonClicked:(id)sender;
- (id)initWithOptions:(NSArray *)arrayOfOptions;
- (void)showInView:(UIView *)view withArrowPointingAt:(CGPoint)arrowPoint;
- (NSArray *)arrayOfSelectedItems;

@end
