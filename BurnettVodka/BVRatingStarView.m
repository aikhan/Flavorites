//
//  BVRatingStarView.m
//  BurnettVodka
//
//  Created by admin on 7/18/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVRatingStarView.h"
#import "UtilityManager.h"

#define kDefaultGapBetweenTwoStars 5

@implementation BVRatingStarView

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame andGapBetweenTwoStars:kDefaultGapBetweenTwoStars];
    if (self) {
        // Initialization code

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andGapBetweenTwoStars:(CGFloat)gap
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImage *emptyStarImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"RatingStarGray.png" andAddIfRequired:YES];
        
        
        
        mStarView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   emptyStarImage.size.width,
                                                                   emptyStarImage.size.height)];
        mStarView1.image = emptyStarImage;
        [self addSubview:mStarView1];
        
        
        mStarView2 = [[UIImageView alloc] initWithFrame:CGRectMake(mStarView1.frame.origin.x + mStarView1.frame.size.width + gap,
                                                                   0,
                                                                   emptyStarImage.size.width,
                                                                   emptyStarImage.size.height)];
        mStarView2.image = emptyStarImage;
        [self addSubview:mStarView2];
        
        
        mStarView3 = [[UIImageView alloc] initWithFrame:CGRectMake(mStarView2.frame.origin.x + mStarView2.frame.size.width + gap,
                                                                   0,
                                                                   emptyStarImage.size.width,
                                                                   emptyStarImage.size.height)];
        mStarView3.image = emptyStarImage;
        [self addSubview:mStarView3];
        
        
        mStarView4 = [[UIImageView alloc] initWithFrame:CGRectMake(mStarView3.frame.origin.x + mStarView3.frame.size.width + gap,
                                                                   0,
                                                                   emptyStarImage.size.width,
                                                                   emptyStarImage.size.height)];
        mStarView4.image = emptyStarImage;
        [self addSubview:mStarView4];
        
        
        mStarView5 = [[UIImageView alloc] initWithFrame:CGRectMake(mStarView4.frame.origin.x + mStarView4.frame.size.width + gap,
                                                                   0,
                                                                   emptyStarImage.size.width,
                                                                   emptyStarImage.size.height)];
        mStarView5.image = emptyStarImage;
        [self addSubview:mStarView5];
        
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                mStarView5.frame.origin.x + mStarView5.frame.size.width,
                                mStarView5.frame.origin.y + mStarView5.frame.size.height);
    }
    return self;
}

- (void)dealloc {
    
    [mStarView1 release];
    [mStarView2 release];
    [mStarView3 release];
    [mStarView4 release];
    [mStarView5 release];
    [super dealloc];
}


- (void)updateViewWithRatingOutOfFive:(CGFloat)newRating
{
    if(rating == newRating)
        return;
    
    
    rating = newRating;
    

    
    UIImage *fullImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"RatingStarBlue.png" andAddIfRequired:YES];
    UIImage *emptyImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"RatingStarGray.png" andAddIfRequired:YES];
    UIImage *halfImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"RatingStarHalfBlue.png" andAddIfRequired:YES];    
    
    UIImage *QuaterImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"RatingStarOneQuater.png" andAddIfRequired:YES];
    UIImage *TwoQuaterImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"RatingStarThreeQuater.png" andAddIfRequired:YES];
    
    
    NSString *str = [NSString stringWithFormat:@"%f",rating];
    NSArray *strarr = [str componentsSeparatedByString:@"."];
    int integerpart = [[strarr firstObject] intValue];
    float decimalpart = [[strarr lastObject] floatValue];
    if (integerpart==0) {
        if (decimalpart>000000 && decimalpart<500000) {
            mStarView1.image = QuaterImage;
        }
        else if (decimalpart==500000) {
            mStarView1.image = halfImage;
        }
        else if (decimalpart>500000 && decimalpart<1000000) {
            mStarView1.image = TwoQuaterImage;
        }
        else {
            mStarView1.image = emptyImage;
            mStarView2.image = emptyImage;
            mStarView3.image = emptyImage;
            mStarView4.image = emptyImage;
            mStarView5.image = emptyImage;
        }
    }
    else if (integerpart==1) {
        mStarView1.image = fullImage;
        if (decimalpart>000000 && decimalpart<500000) {
            mStarView2.image = QuaterImage;
        }
        else if (decimalpart==500000) {
            mStarView2.image = halfImage;
        }
        else if (decimalpart>500000 && decimalpart<1000000) {
            mStarView2.image = TwoQuaterImage;
        }
        else {
            mStarView2.image = emptyImage;
        }
        mStarView3.image = emptyImage;
        mStarView4.image = emptyImage;
        mStarView5.image = emptyImage;
    }
    else if (integerpart==2) {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        if (decimalpart>000000 && decimalpart<500000) {
            mStarView3.image = QuaterImage;
        }
        else if (decimalpart==500000) {
            mStarView3.image = halfImage;
        }
        else if (decimalpart>500000 && decimalpart<1000000) {
            mStarView3.image = TwoQuaterImage;
        }
        else {
            mStarView3.image = emptyImage;
        }
        mStarView4.image = emptyImage;
        mStarView5.image = emptyImage;
    }
    else if (integerpart==3) {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        mStarView3.image = fullImage;
        if (decimalpart>000000 && decimalpart<500000) {
            mStarView4.image = QuaterImage;
        }
        else if (decimalpart==500000) {
            mStarView4.image = halfImage;
        }
        else if (decimalpart>500000 && decimalpart<1000000) {
            mStarView4.image = TwoQuaterImage;
        }
        else {
            mStarView4.image = emptyImage;
        }
        mStarView5.image = emptyImage;
    }
    else if (integerpart==4) {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        mStarView3.image = fullImage;
        mStarView4.image = fullImage;
        if (decimalpart>000000 && decimalpart<500000) {
            mStarView5.image = QuaterImage;
        }
        else if (decimalpart==500000) {
            mStarView5.image = halfImage;
        }
        else if (decimalpart>500000 && decimalpart<1000000) {
            mStarView5.image = TwoQuaterImage;
        }
        else {
            mStarView5.image = emptyImage;
        }
    }
    else if (integerpart==5) {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        mStarView3.image = fullImage;
        mStarView4.image = fullImage;
        mStarView5.image = fullImage;
    }
    
    
//    
//    
//    if(rating < 0.5)
//    {
//        mStarView1.image = QuaterImage;
//        mStarView2.image = emptyImage;
//        mStarView3.image = emptyImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 0.5 && rating <1.0)
//    {
//        mStarView1.image = TwoQuaterImage;
//        mStarView2.image = emptyImage;
//        mStarView3.image = emptyImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating >1.0 && rating<=1.0)
//    {
//        mStarView1.image = fullImage;
//        mStarView2.image = emptyImage;
//        mStarView3.image = emptyImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 1.0 && rating <= 1.25)
//    {
//        mStarView1.image = QuaterImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = emptyImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 1.25 && rating <= 1.5)
//    {
//        mStarView1.image = halfImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = emptyImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 1.5 && rating <= 1.75)
//    {
//        mStarView1.image = TwoQuaterImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = emptyImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating >1.75 && rating<=2.0)
//    {
//        mStarView1.image = fullImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = emptyImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 2.0 && rating <= 2.25)
//    {
//        mStarView1.image = QuaterImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 2.25 && rating <= 2.5)
//    {
//        mStarView1.image = halfImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 2.5 && rating <= 2.75)
//    {
//        mStarView1.image = TwoQuaterImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating >2.75 && rating<=3.0)
//    {
//        mStarView1.image = fullImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = emptyImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 3.0 && rating <= 3.25)
//    {
//        mStarView1.image = QuaterImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = fullImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 3.25 && rating <= 3.5)
//    {
//        mStarView1.image = halfImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = fullImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 3.5 && rating <= 3.75)
//    {
//        mStarView1.image = TwoQuaterImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = fullImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating >3.75 && rating<=4.0)
//    {
//        mStarView1.image = fullImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = fullImage;
//        mStarView5.image = emptyImage;
//    }
//    else if(rating > 4.0 && rating <= 4.25)
//    {
//        mStarView1.image = QuaterImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = fullImage;
//        mStarView5.image = fullImage;
//    }
//    else if(rating > 4.25 && rating <= 4.5)
//    {
//        mStarView1.image = halfImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = fullImage;
//        mStarView5.image = fullImage;
//    }
//    else if(rating > 4.5 && rating <= 4.75)
//    {
//        mStarView1.image = TwoQuaterImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = fullImage;
//        mStarView5.image = fullImage;
//    }
//    else if(rating >4.75 && rating<=5.0)
//    {
//        mStarView1.image = fullImage;
//        mStarView2.image = fullImage;
//        mStarView3.image = fullImage;
//        mStarView4.image = fullImage;
//        mStarView5.image = fullImage;
//    }
}


@end
