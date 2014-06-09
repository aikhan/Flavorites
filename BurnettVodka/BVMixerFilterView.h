//
//  BVMixerFilterView.h
//  BurnettVodka
//
//  Created by admin on 7/31/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BVFilterItemView;

@protocol BVFilterItemViewDelegate <NSObject>

- (void)filterItemViewDeleteButtonPressed:(BVFilterItemView *)view;

@end

@interface BVFilterItemView : UIView {
    
    UIButton *mDeleteButton;
    UILabel *mTitleLabel;
    
    NSString *mTitle;
    
    id <BVFilterItemViewDelegate> viewDelegate;
}

@property (nonatomic, readonly) NSString *mTitle;
@property (nonatomic, assign) id <BVFilterItemViewDelegate> viewDelegate;

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title;

@end



@class BVMixerFilterView;

@protocol BVMixerFilterViewDelegate <NSObject>

- (void)mixerFilterView:(BVMixerFilterView *)view finishedRemovingFilterWithTitle:(NSString *)filterTitle;

@end

@interface BVMixerFilterView : UIView <BVFilterItemViewDelegate> {
    
    UIImageView *mBackgroundImageView;
    UIScrollView *mScrollView;
    
    id <BVMixerFilterViewDelegate> viewDelegate;
}

@property (nonatomic, assign) id <BVMixerFilterViewDelegate> viewDelegate;

- (void)addFilter:(NSString *)filterString animated:(BOOL)animated;
- (void)removeFilter:(NSString *)filterString animated:(BOOL)animated;

@end
