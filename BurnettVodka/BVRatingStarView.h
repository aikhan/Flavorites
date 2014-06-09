//
//  BVRatingStarView.h
//  BurnettVodka
//
//  Created by admin on 7/18/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BVRatingStarView : UIView {
    
    UIImageView *mStarView1;
    UIImageView *mStarView2;
    UIImageView *mStarView3;
    UIImageView *mStarView4;
    UIImageView *mStarView5;
    
    CGFloat rating;
}

- (id)initWithFrame:(CGRect)frame andGapBetweenTwoStars:(CGFloat)gap;

- (void)updateViewWithRatingOutOfFive:(CGFloat)newRating;

@end
