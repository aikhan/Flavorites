//
//  BVCoverFlowScrollView.m
//  BurnettVodka
//
//  Created by admin on 7/27/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVCoverFlowScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "FeaturedRecipeItem.h"
#import "SystemSoundPlayer.h"
#import "BVRecipeDescriptionView.h"


#define kGapBetweenCards 10

#define kFeaturedCardDimensionRatio 0.772

#define kWidthUponWhichCardSizeRemainsMax 10

#define kVariableRatio 0.2



@implementation BVFeaturedRecipeView

@synthesize viewDelegate;

- (id)initWithFrame:(CGRect)frame andFeaturedRecipeItem:(FeaturedRecipeItem *)item andNew:(BOOL)isnew
{
    self = [super initWithFrame:frame];
    if(self)
    {
        mRecipeItem = [item retain];
        
        
        mPosterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         self.frame.size.width,
                                                                         self.frame.size.height)];
        UIImage *posterImage;
        if ([mRecipeItem.imageFilePath componentsSeparatedByString:@"/"].count>1) {
            posterImage = [[UIImage alloc] initWithContentsOfFile:mRecipeItem.imageFilePath];

        }
        else {
            posterImage = [UIImage imageNamed:mRecipeItem.imageFilePath];
 
        }
        mPosterImageView.image = posterImage;
        [posterImage release];
        
        mPosterImageView.layer.masksToBounds = YES;
        mPosterImageView.layer.cornerRadius = 15.0;
        mPosterImageView.userInteractionEnabled = YES;
        mPosterImageView.clipsToBounds = YES;
        mPosterImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        
        [self addSubview:mPosterImageView];
        
        
        if (isnew==TRUE) {
            UIImage *img = [UIImage imageNamed:@"new.png"];
            UIImageView *isnewimagevier = [[UIImageView alloc] initWithFrame:CGRectMake(10,
                                                                             20,
                                                                             img.size.width,
                                                                             img.size.height)];
            isnewimagevier.image= img;
            [mPosterImageView addSubview:isnewimagevier];
        }
        
        
        //        //Now check for image
        //        NSString *imageFilePath = [[DataManager sharedDataManager] filePathOfMoviePosterImageForMovie:mMovie];
        //        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imageFilePath];
        //        if(image)
        //        {
        //            [self setAndModifyPosterImageViewForImage:image];
        //            [image release];
        //        }
        //        else
        //        {
        //            [self showActivityIndicator];
        //            [self performSelector:@selector(downloadAndSavePosterImage) withObject:nil afterDelay:0.01];
        //        }
    }
    return self;
}

- (void)dealloc {
    
    [mPosterImageView release];
    [mActivityIndicator release];
    [mRecipeItem release];
    //[super dealloc];
}




#pragma mark -
#pragma mark Public Methods


- (void)updateDistanceFromCenter:(CGFloat)distanceFromCenter
{
    //    if(mDistanceFromCenter > 0 && distanceFromCenter < 0)
    //    {
    //        [[SystemSoundPlayer sharedSystemSoundPlayer] playCoverFlowMove];
    //    }
    //    else if(mDistanceFromCenter < 0 && distanceFromCenter > 0)
    //    {
    //        [[SystemSoundPlayer sharedSystemSoundPlayer] playCoverFlowMove];
    //    }
    
    mDistanceFromCenter = distanceFromCenter;
}



#pragma mark -
#pragma mark UITouch Methods


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if(touch.view == mPosterImageView)
    {
        if([viewDelegate respondsToSelector:@selector(featuredRecipeView:userTappedWithRecipeID:)])
        {
            [viewDelegate featuredRecipeView:self userTappedWithRecipeID:mRecipeItem.recipeID];
        }
    }
}



@end





@interface BVCoverFlowScrollView ()

- (CGFloat)widthOfFeaturedCardView;

@end


@implementation BVCoverFlowScrollView

@synthesize coverFlowDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGFloat widthOfFeaturedCard = [self widthOfFeaturedCardView];
        mSideSpacingWhenSingleCard = roundf((self.frame.size.width - widthOfFeaturedCard)/2);
        mDistanceUponWhichToVary = roundf((self.frame.size.width - kWidthUponWhichCardSizeRemainsMax) / 2);
        
        self.showsHorizontalScrollIndicator = NO;
        
    }
    return self;
}


- (void)resetScrollViewWithRecipesArray:(NSArray *)recipesArray
{
    [recipesArray retain];
    [recipesArray release];
    mFeaturedRecipeItemsArray = recipesArray;
    
    
    
    for(BVFeaturedRecipeView *view in mHomeScreenRecipeCardViewsArray)
    {
        [view removeFromSuperview];
    }
    
    [mHomeScreenRecipeCardViewsArray release];
    mHomeScreenRecipeCardViewsArray = [[NSMutableArray alloc] init];
    
    
    CGFloat yCoord = 0;
    CGFloat xCoord = 0;
    CGFloat widthOfFeaturedCard = [self widthOfFeaturedCardView];
    
    for(int i=0; i<[mFeaturedRecipeItemsArray count]; i++)
    {
        id obj = [mFeaturedRecipeItemsArray objectAtIndex:i];
        if ([obj isKindOfClass:[FeaturedRecipeItem class]]) {
            FeaturedRecipeItem *recipeItem = [mFeaturedRecipeItemsArray objectAtIndex:i];
            
            
            BVFeaturedRecipeView *cardView = [[BVFeaturedRecipeView alloc] initWithFrame:CGRectMake(xCoord,
                                                                                                    yCoord,
                                                                                                    widthOfFeaturedCard,
                                                                                                    self.frame.size.height)
                                                                   andFeaturedRecipeItem:recipeItem
                                              andNew:recipeItem.isNewimg];
            cardView.viewDelegate = self;
            cardView.backgroundColor = [UIColor clearColor];
            cardView.tag = i + 1;
            [self addSubview:cardView];
            [mHomeScreenRecipeCardViewsArray addObject:cardView];
            xCoord = xCoord + widthOfFeaturedCard + kGapBetweenCards;
            [cardView release];

        }
        else {
            [mHomeScreenRecipeCardViewsArray addObject:[mFeaturedRecipeItemsArray objectAtIndex:i]];
            BVRecipeDescriptionView *obj1 = [mFeaturedRecipeItemsArray objectAtIndex:i];
            obj1.frame = CGRectMake(xCoord, yCoord, 180, 340);
            
            [self addSubview:obj1];
            xCoord = xCoord + 180 + kGapBetweenCards;

        }
        
        
        
//        if(i == ([mFeaturedRecipeItemsArray count]  - 1))
//        {
//            xCoord = xCoord + widthOfFeaturedCard + mSideSpacingWhenSingleCard;
//        }
//        else
        {
        }
    }
    
    
    
    
    self.contentSize = CGSizeMake(xCoord,
                                  self.frame.size.height);
    
    
    
    
    
    // Set up the initial position of the Feature Recipe Views to display the second card in the middle if possible.
    if([mHomeScreenRecipeCardViewsArray count] >= 1)
    {
        NSInteger totalCount = [mHomeScreenRecipeCardViewsArray count];
        NSInteger initialPositionIndex = roundf(((float)totalCount / 2.0)) - 1;
        
        BVFeaturedRecipeView *secondCardView = [mHomeScreenRecipeCardViewsArray  objectAtIndex:initialPositionIndex];
        
        CGFloat centrePointInVisibleScrollView = (self.frame.size.width / 2);
        
        CGFloat difference = centrePointInVisibleScrollView - secondCardView.center.x;
        
        [self setContentOffset:CGPointMake(0 - difference, 0)];
    }
    else
    {
        [self setContentOffset:CGPointMake(0, 0)];
    }
    //To force UI update right from the beginning of the dispay of the movie cards
  //  [self scrollViewScrolled];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    NSLog(@"%f", scrollView.contentOffset.x);
    
}


- (void)scrollViewScrolled
{
    CGFloat contentOffsetX = self.contentOffset.x;
    
    NSInteger index = (contentOffsetX - mSideSpacingWhenSingleCard) / ([self widthOfFeaturedCardView] + kGapBetweenCards);
    CGFloat centrePointInVisibleScrollView = contentOffsetX + (self.frame.size.width / 2);
    
    
    
    
    
    UIView *firstView = [self viewWithTag:index + 1];
    
    if([firstView isKindOfClass:[BVFeaturedRecipeView class]])
    {
        CGFloat distanceFromCenter = centrePointInVisibleScrollView - (firstView.center.x);
        
        [(BVFeaturedRecipeView *)firstView updateDistanceFromCenter:distanceFromCenter];
        
        if(distanceFromCenter < 0)
        {
            distanceFromCenter = - distanceFromCenter;
        }
        
        
        
        CGFloat distanceFromVaryingPoint = distanceFromCenter - roundf(kWidthUponWhichCardSizeRemainsMax / 2);
        
        
        
        CGFloat variableRatio = kVariableRatio;
        
        if(distanceFromVaryingPoint > 0)
        {
            CGFloat ratio = 1.0 - (distanceFromVaryingPoint / mDistanceUponWhichToVary);
            variableRatio = ratio * kVariableRatio;
        }
        
        
        
        CGFloat alphaRatio = (1.0 - kVariableRatio) + variableRatio;
        firstView.transform = CGAffineTransformMakeScale(alphaRatio, alphaRatio);
    }
    
    
    NSInteger secondVisibleViewIndex = index + 1;
    if(secondVisibleViewIndex < [mHomeScreenRecipeCardViewsArray count])
    {
        UIView *secondView = [self viewWithTag:secondVisibleViewIndex + 1];
        
        if([secondView isKindOfClass:[BVFeaturedRecipeView class]])
        {
            CGFloat distanceFromCenter = centrePointInVisibleScrollView - (secondView.center.x);
            
            [(BVFeaturedRecipeView *)secondView updateDistanceFromCenter:distanceFromCenter];
            
            if(distanceFromCenter < 0)
            {
                distanceFromCenter = - distanceFromCenter;
            }
            
            
            CGFloat distanceFromVaryingPoint = distanceFromCenter - roundf(kWidthUponWhichCardSizeRemainsMax / 2);
            
            CGFloat variableRatio = kVariableRatio;
            
            if(distanceFromVaryingPoint > 0)
            {
                CGFloat ratio = 1.0 - (distanceFromVaryingPoint / mDistanceUponWhichToVary);
                variableRatio = ratio * kVariableRatio;
            }
            
            
            CGFloat alphaRatio = (1.0 - kVariableRatio) + variableRatio;
            secondView.transform = CGAffineTransformMakeScale(alphaRatio, alphaRatio);
        }
    }
    
    
    NSInteger thirdVisibleViewIndex = secondVisibleViewIndex + 1;
    if(thirdVisibleViewIndex < [mHomeScreenRecipeCardViewsArray count])
    {
        UIView *thirdView = [self viewWithTag:thirdVisibleViewIndex + 1];
        
        if([thirdView isKindOfClass:[BVFeaturedRecipeView class]])
        {
            CGFloat distanceFromCenter = centrePointInVisibleScrollView - (thirdView.center.x);
            
            [(BVFeaturedRecipeView *)thirdView updateDistanceFromCenter:distanceFromCenter];
            
            if(distanceFromCenter < 0)
            {
                distanceFromCenter = - distanceFromCenter;
            }
            CGFloat distanceFromVaryingPoint = distanceFromCenter - roundf(kWidthUponWhichCardSizeRemainsMax / 2);
            
            CGFloat variableRatio = kVariableRatio;
            
            if(distanceFromVaryingPoint > 0)
            {
                CGFloat ratio = 1.0 - (distanceFromVaryingPoint / mDistanceUponWhichToVary);
                variableRatio = ratio * kVariableRatio;
            }
            
            
            CGFloat alphaRatio = (1.0 - kVariableRatio) + variableRatio;
            thirdView.transform = CGAffineTransformMakeScale(alphaRatio, alphaRatio);
        }
    }
}

- (void)featuredRecipeView:(BVFeaturedRecipeView *)view userTappedWithRecipeID:(NSInteger)recipeID
{
    CGFloat contentOffsetX = self.contentOffset.x;
    
    CGFloat centrePointInVisibleScrollView = contentOffsetX + (self.frame.size.width / 2);
    
    if(view.center.x != centrePointInVisibleScrollView)
    {
        CGFloat difference = centrePointInVisibleScrollView - view.center.x;
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             [self setContentOffset:CGPointMake(contentOffsetX - difference, self.contentOffset.y)];
                             
                         }
                         completion:^(BOOL finished) {
                             
                             if([coverFlowDelegate respondsToSelector:@selector(coverFlowScrollView:userTappedWithRecipeID:)])
                             {
                                 [coverFlowDelegate coverFlowScrollView:self userTappedWithRecipeID:recipeID];
                             }
                             
                         }];
    }
    else
    {
        if([coverFlowDelegate respondsToSelector:@selector(coverFlowScrollView:userTappedWithRecipeID:)])
        {
            [coverFlowDelegate coverFlowScrollView:self userTappedWithRecipeID:recipeID];
        }
    }
    
    
    
}

- (CGFloat)widthOfFeaturedCardView
{
    return 120;
    //return (kFeaturedCardDimensionRatio * self.frame.size.height);
}

@end
