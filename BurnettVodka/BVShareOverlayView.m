//
//  BVShareOverlayView.m
//  BurnettVodka
//
//  Created by admin on 7/27/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVShareOverlayView.h"
#import "UtilityManager.h"

#define kSelfWidth 320
#define kSelfHeight 160
#define kItemImageSide 61
#define kPaddingLeft 14
#define kPaddingTop 18
#define kCancelRowHeight 48




@implementation BVShareItem

@synthesize itemName;
@synthesize iconImage;

- (id)initWithItemName:(NSString *)name andIconImage:(UIImage *)image
{
    self = [super init];
    if(self)
    {
        itemName = [name copy];
        iconImage = [image retain];
    }
    return self;
}

- (void)dealloc {
    
    [itemName release];
    [iconImage release];
    [super dealloc];
}

@end


@implementation BVShareOverlayView

@synthesize viewDelegate;

- (id)initWithShareItems:(NSArray *)itemsArray
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
     
        self.backgroundColor = [UIColor clearColor];
        
        self.clipsToBounds = YES;
        
        
        // Create the Background Translucent Layer
        mBackgroundTranslucentView = [[UIView alloc] initWithFrame:CGRectZero];
        mBackgroundTranslucentView.backgroundColor = [UIColor blackColor];
        [self addSubview:mBackgroundTranslucentView];
        
        
        
        
        // Create the Container Layer with white Background
        mContainerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  kSelfWidth,
                                                                  kSelfHeight)];
        mContainerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:mContainerView];
        
        
        
        
        
        
        mItemsArray = [itemsArray retain];
        
        
        for(int i=0; i<[mItemsArray count]; i++)
        {
            BVShareItem *item = [mItemsArray objectAtIndex:i];
            
            
            UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeft + (i * (kPaddingLeft + kItemImageSide)),
                                                                        kPaddingTop,
                                                                        kItemImageSide,
                                                                        0)];
            
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          kItemImageSide,
                                                                          kItemImageSide)];
            [button setImage:item.iconImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i + 1;
            [itemView addSubview:button];
            [button release];
            
            
            
            UIFont *titleFont = [UtilityManager fontGetRegularFontOfSize:13];
            CGSize sampleTitleSize = [[NSString stringWithFormat:@"sample"] sizeWithFont:titleFont];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                            button.frame.origin.y + button.frame.size.height,
                                                                            button.frame.size.width,
                                                                            sampleTitleSize.height)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.text = item.itemName;
            titleLabel.font = titleFont;
            titleLabel.textAlignment = UITextAlignmentCenter;
            [titleLabel adjustsFontSizeToFitWidth];
            [itemView addSubview:titleLabel];
            [titleLabel release];
            
            
            itemView.frame = CGRectMake(itemView.frame.origin.x,
                                        itemView.frame.origin.y,
                                        itemView.frame.size.width,
                                        titleLabel.frame.origin.y + titleLabel.frame.size.height);

            
            [mContainerView addSubview:itemView];
            [itemView release];
        }
        
        
        
        
        UIView *cancelBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                mContainerView.frame.size.height - kCancelRowHeight,
                                                                                mContainerView.frame.size.width,
                                                                                kCancelRowHeight)];
        cancelBackgroundView.backgroundColor = [UIColor colorWithRed:(235.0/256.0) green:(235.0/256.0) blue:(235.0/256.0) alpha:1.0];
        [mContainerView addSubview:cancelBackgroundView];
        [cancelBackgroundView release];
        
        
        CGFloat extraPaddingInCancelButton = 5;
        UIFont *cancelButtonFont = [UtilityManager fontGetRegularFontOfSize:24];
        NSString *cancelButtonTitle = @"Cancel";
        CGSize cancelButtonSize = [cancelButtonTitle sizeWithFont:cancelButtonFont];
        CGSize cancelButtonSizeWithExtraPadding = CGSizeMake(cancelButtonSize.width + extraPaddingInCancelButton + extraPaddingInCancelButton,
                                                             cancelButtonSize.height + extraPaddingInCancelButton + extraPaddingInCancelButton);
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(roundf((cancelBackgroundView.frame.size.width - cancelButtonSizeWithExtraPadding.width) / 2),
                                                                            roundf((cancelBackgroundView.frame.size.height - cancelButtonSizeWithExtraPadding.height) / 2),
                                                                            cancelButtonSizeWithExtraPadding.width,
                                                                            cancelButtonSizeWithExtraPadding.height)];
        [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setBackgroundColor:[UIColor colorWithRed:(236.0/256.0) green:(0.0/256.0) blue:(139.0/256.0) alpha:1.0]];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        cancelButton.titleLabel.font = cancelButtonFont;
        [cancelBackgroundView addSubview:cancelButton];
        [cancelButton release];
    }
    return self;
}

- (void)dealloc {
    
    [mContainerView release];
    [mBackgroundTranslucentView release];
    [mItemsArray release];
    [super dealloc];
}

- (void)buttonTapped:(id)sender
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         mBackgroundTranslucentView.alpha = 0.0;
                         
                         mContainerView.frame = CGRectMake(mContainerView.frame.origin.x,
                                                           self.frame.size.height,
                                                           mContainerView.frame.size.width,
                                                           mContainerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                         UIButton *button = (UIButton *)sender;
                         
                         NSInteger itemIndex = button.tag - 1;
                         if([mItemsArray count] > itemIndex)
                         {
                             BVShareItem *item = [mItemsArray objectAtIndex:itemIndex];
                             if([viewDelegate respondsToSelector:@selector(shareOverlayView:shareItemPressed:)])
                             {
                                 [viewDelegate shareOverlayView:self shareItemPressed:item];
                             }
                         }
                     }];

}

- (void)cancel:(id)sender
{
    [UIView animateWithDuration:0.0
                     animations:^{
                         
                         mBackgroundTranslucentView.alpha = 0.0;
                         
                         mContainerView.frame = CGRectMake(mContainerView.frame.origin.x,
                                                           self.frame.size.height,
                                                           mContainerView.frame.size.width,
                                                           mContainerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                         if([viewDelegate respondsToSelector:@selector(shareOverlayViewCancelButtonTapped:)])
                         {
                             [viewDelegate shareOverlayViewCancelButtonTapped:self];
                         }
                     }];
}



- (void)showInView:(UIView *)view
{
    // Configure self frame to cover up the complete view in which it is to be show.
    self.frame = CGRectMake(0,
                            0,
                            view.frame.size.width,
                            view.frame.size.height);
    
    
    
    // Configure the background translucent layer
    mBackgroundTranslucentView.frame = CGRectMake(0,
                                                  0,
                                                  self.frame.size.width,
                                                  self.frame.size.height);
    mBackgroundTranslucentView.alpha = 0.0;
    
    
    
    
    // Configure the Share Layer
    mContainerView.frame = CGRectMake(mContainerView.frame.origin.x,
                                      self.frame.size.height,
                                      mContainerView.frame.size.width,
                                      mContainerView.frame.size.height);
    
    
    [view addSubview:self];
    
    
    [UIView animateWithDuration:0.25
                     animations:^{
                        
                         mBackgroundTranslucentView.alpha = 0.5;
                         
                         mContainerView.frame = CGRectMake(mContainerView.frame.origin.x,
                                                           self.frame.size.height - mContainerView.frame.size.height,
                                                           mContainerView.frame.size.width,
                                                           mContainerView.frame.size.height);
                         
                     }];
    
}



@end
