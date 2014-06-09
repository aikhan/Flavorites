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
    
    

    
    if(rating <= 0.25)
    {
        mStarView1.image = emptyImage;
        mStarView2.image = emptyImage;
        mStarView3.image = emptyImage;
        mStarView4.image = emptyImage;
        mStarView5.image = emptyImage;
    }
    else if(rating > 0.25 && rating <= 0.75)
    {
        mStarView1.image = halfImage;
        mStarView2.image = emptyImage;
        mStarView3.image = emptyImage;
        mStarView4.image = emptyImage;
        mStarView5.image = emptyImage;
    }
    else if(rating > 0.75 && rating <= 1.25)
    {
        mStarView1.image = fullImage;
        mStarView2.image = emptyImage;
        mStarView3.image = emptyImage;
        mStarView4.image = emptyImage;
        mStarView5.image = emptyImage;
    }
    else if(rating > 1.25 && rating <= 1.75)
    {
        mStarView1.image = fullImage;
        mStarView2.image = halfImage;
        mStarView3.image = emptyImage;
        mStarView4.image = emptyImage;
        mStarView5.image = emptyImage;
    }
    else if(rating > 1.75 && rating <= 2.25)
    {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        mStarView3.image = emptyImage;
        mStarView4.image = emptyImage;
        mStarView5.image = emptyImage;
    }
    else if(rating > 2.25 && rating <= 2.75)
    {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        mStarView3.image = halfImage;
        mStarView4.image = emptyImage;
        mStarView5.image = emptyImage;
    }
    else if(rating > 2.75 && rating <= 3.25)
    {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        mStarView3.image = fullImage;
        mStarView4.image = emptyImage;
        mStarView5.image = emptyImage;
    }
    else if(rating > 3.25 && rating <= 3.75)
    {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        mStarView3.image = fullImage;
        mStarView4.image = halfImage;
        mStarView5.image = emptyImage;
    }
    else if(rating > 3.75 && rating <= 4.25)
    {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        mStarView3.image = fullImage;
        mStarView4.image = fullImage;
        mStarView5.image = emptyImage;
    }
    else if(rating > 4.25 && rating <= 4.75)
    {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        mStarView3.image = fullImage;
        mStarView4.image = fullImage;
        mStarView5.image = halfImage;
    }
    else if(rating > 4.75)
    {
        mStarView1.image = fullImage;
        mStarView2.image = fullImage;
        mStarView3.image = fullImage;
        mStarView4.image = fullImage;
        mStarView5.image = fullImage;
    }
}


@end
