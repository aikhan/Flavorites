//
//  BVShareOverlayView.h
//  BurnettVodka
//
//  Created by admin on 7/27/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BVShareItem : NSObject {
    
    NSString *itemName;
    UIImage *iconImage;
}

@property (nonatomic, readonly) NSString *itemName;
@property (nonatomic, readonly) UIImage *iconImage;

- (id)initWithItemName:(NSString *)itemName andIconImage:(UIImage *)iconImage;


@end


@class BVShareOverlayView;

@protocol BVShareOverlayViewDelegate <NSObject>

- (void)shareOverlayViewCancelButtonTapped:(BVShareOverlayView *)view;
- (void)shareOverlayView:(BVShareOverlayView *)view shareItemPressed:(BVShareItem *)item;

@end

@interface BVShareOverlayView : UIView {
    
    UIView *mBackgroundTranslucentView;
    UIView *mContainerView;
    
    NSArray *mItemsArray;
    
    id <BVShareOverlayViewDelegate> viewDelegate;
}

@property (nonatomic, assign) id <BVShareOverlayViewDelegate> viewDelegate;

- (id)initWithShareItems:(NSArray *)itemsArray;
- (void)showInView:(UIView *)view;

@end
