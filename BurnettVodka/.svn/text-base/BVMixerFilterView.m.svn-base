//
//  BVMixerFilterView.m
//  BurnettVodka
//
//  Created by admin on 7/31/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVMixerFilterView.h"
#import "UtilityManager.h"


#define kPaddingLeft 2
#define kPaddingRight 2
#define kPaddingTop 2
#define kPaddingBottom 2


#define kBVFilterItemViewGapBetweenTitleAndDeleteButton 2

#define kGapBetweenTwoFilterItemViews 10

#define kScrollViewPaddingLeft 4
#define kScrollViewPaddingRight 4


@implementation BVFilterItemView

@synthesize mTitle;
@synthesize viewDelegate;

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title
{
    self = [super initWithFrame:frame];
    if(self)
    {
        mTitle = [title copy];
        
        
        UIFont *titleFont = [UtilityManager fontGetRegularFontOfSize:15];
        CGSize titleSize = [mTitle sizeWithFont:titleFont];
        mTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                titleSize.width,
                                                                titleSize.height)];
        mTitleLabel.backgroundColor = [UIColor clearColor];
        mTitleLabel.textColor = [UIColor colorWithRed:(179.0/256.0) green:(179.0/256.0) blue:(179.0/256.0) alpha:1.0];
        mTitleLabel.font = titleFont;
        mTitleLabel.text = mTitle;
        [self addSubview:mTitleLabel];
        
        
        
        UIImage *deleteButtonImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"MixerFilterDeleteButton.png" andAddIfRequired:YES];
        mDeleteButton = [[UIButton alloc] initWithFrame:CGRectMake(mTitleLabel.frame.origin.x + mTitleLabel.frame.size.width + kBVFilterItemViewGapBetweenTitleAndDeleteButton,
                                                                   0,
                                                                   deleteButtonImage.size.width,
                                                                   deleteButtonImage.size.height)];
        [mDeleteButton setImage:deleteButtonImage forState:UIControlStateNormal];
        [mDeleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mDeleteButton];
        

        
        if(mDeleteButton.frame.size.height > mTitleLabel.frame.size.height)
        {
            mTitleLabel.frame = CGRectMake(mTitleLabel.frame.origin.x,
                                           roundf((mDeleteButton.frame.size.height - mTitleLabel.frame.size.height) / 2),
                                           mTitleLabel.frame.size.width,
                                           mTitleLabel.frame.size.height);
            
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y,
                                    mDeleteButton.frame.origin.x + mDeleteButton.frame.size.width,
                                    mDeleteButton.frame.size.height);
        }
        else
        {
            mDeleteButton.frame = CGRectMake(mDeleteButton.frame.origin.x,
                                             roundf((mTitleLabel.frame.size.height - mDeleteButton.frame.size.height) / 2),
                                             mDeleteButton.frame.size.width,
                                             mDeleteButton.frame.size.height);
            
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y,
                                    mDeleteButton.frame.origin.x + mDeleteButton.frame.size.width,
                                    mTitleLabel.frame.size.height);
        }
    }
    return self;
}

- (void)dealloc {
    
    [mTitleLabel release];
    [mDeleteButton release];
    [mTitle release];
    [super dealloc];
}

- (void)delete:(id)sender
{
    if([viewDelegate respondsToSelector:@selector(filterItemViewDeleteButtonPressed:)])
    {
        [viewDelegate filterItemViewDeleteButtonPressed:self];
    }
}

@end



@implementation BVMixerFilterView

@synthesize viewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeTabSearchBarBackground" ofType:@"png"]];
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                backgroundImage.size.width,
                                backgroundImage.size.height);
        
        
        
        mBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                             0,
                                                                             self.frame.size.width,
                                                                             self.frame.size.height)];
        mBackgroundImageView.image = backgroundImage;
        [backgroundImage release];
        
        [self addSubview:mBackgroundImageView];
        
        
        
        
        
        mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kPaddingLeft,
                                                                     kPaddingTop,
                                                                     self.frame.size.width - kPaddingLeft - kPaddingRight,
                                                                     self.frame.size.height - kPaddingTop - kPaddingBottom)];
        mScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:mScrollView];
        
    }
    return self;
}

- (void)dealloc {
    
    [mBackgroundImageView release];
    [mScrollView release];
    [super dealloc];
}


- (void)addFilter:(NSString *)filterString animated:(BOOL)animated
{
    CGFloat xCoordinateForThisNewFitlerView = 0;
    
    NSInteger numberOfExistingFilterItemViews = 0;
    
    NSArray *subViews = [mScrollView subviews];
    for(UIView *subView in subViews)
    {
        if([subView isKindOfClass:[BVFilterItemView class]])
        {
            if((subView.frame.origin.x + subView.frame.size.width) > xCoordinateForThisNewFitlerView)
            {
                xCoordinateForThisNewFitlerView = subView.frame.origin.x + subView.frame.size.width;
            }
            
            numberOfExistingFilterItemViews++;
        }
    }
    
    if(xCoordinateForThisNewFitlerView == 0)
    {
        xCoordinateForThisNewFitlerView = kScrollViewPaddingLeft;
    }
    else
    {
        xCoordinateForThisNewFitlerView = xCoordinateForThisNewFitlerView + kGapBetweenTwoFilterItemViews;
    }
    
    
    
    
    BVFilterItemView *itemView = [[BVFilterItemView alloc] initWithFrame:CGRectMake(xCoordinateForThisNewFitlerView,
                                                                                    0,
                                                                                    0,
                                                                                    0)
                                                                andTitle:filterString];
    itemView.viewDelegate = self;
    itemView.tag = numberOfExistingFilterItemViews + 1;
    itemView.frame = CGRectMake(itemView.frame.origin.x,
                                roundf((mScrollView.frame.size.height - itemView.frame.size.height) / 2),
                                itemView.frame.size.width,
                                itemView.frame.size.height);
    [mScrollView addSubview:itemView];
    [itemView release];
    
    
    mScrollView.contentSize = CGSizeMake(itemView.frame.origin.x + itemView.frame.size.width + kScrollViewPaddingRight,
                                         mScrollView.frame.size.height);
    
    [mScrollView scrollRectToVisible:itemView.frame animated:YES];
}

- (void)removeFilter:(NSString *)filterString animated:(BOOL)animated
{
    
}


- (void)filterItemViewDeleteButtonPressed:(BVFilterItemView *)view
{
    
}

@end
