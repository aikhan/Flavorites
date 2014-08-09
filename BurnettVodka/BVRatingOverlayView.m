//
//  BVRatingOverlayView.m
//  BurnettVodka
//
//  Created by admin on 7/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVRatingOverlayView.h"
#import "UtilityManager.h"
#import "DataManager.h"
#import "BVApp.h"
#import "Constants.h"
#import "JSON.h"

#define kSelfWidth 320
#define kNonCancelRowHeight 40
#define kCancelRowHeight 48
#define kSeperatorHeight 1

#define kGapBetweenActivityIndicatorAndMessageLabel 10
#define kGapBetweenMessageLabelAndCancelButton 10
#define kGapBetweenTwoStars 3


@interface BVRatingOverlayView ()

- (void)processSubmitRatingAPIResponse:(NSDictionary *)responseDic forRecipe:(Recipe *)recipeObject andRatingSubmittedByUser:(NSNumber *)ratingSubmittedByUser;

@end




@implementation BVRatingOverlayView

@synthesize viewDelegate;

- (id)init
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
                                                                  (kNonCancelRowHeight * 6) + (kSeperatorHeight * 6) + kCancelRowHeight)];
        mContainerView.backgroundColor = [UIColor colorWithRed:(40.0/256.0) green:(45.0/256.0) blue:(85.0/256.0) alpha:1];
        [self addSubview:mContainerView];
        
        
        
        
        
        
        
        NSString *title = @"Rate This Recipe";
        UIFont *titleFont = [UtilityManager fontGetRegularFontOfSize:18];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        mContainerView.frame.size.width,
                                                                        kNonCancelRowHeight)];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = titleFont;
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        [mContainerView addSubview:titleLabel];
        [titleLabel release];
        
        
        
        
        
        
        
        CGFloat yCoordinatePointer = titleLabel.frame.origin.y + titleLabel.frame.size.height;
        
        
        for(int i=5; i>0; i--)
        {
            UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                             yCoordinatePointer,
                                                                             mContainerView.frame.size.width,
                                                                             kSeperatorHeight)];
            seperatorView.backgroundColor = [UIColor colorWithRed:(196.0/256.0) green:(196.0/256.0) blue:(196.0/256.0) alpha:1];
            [mContainerView addSubview:seperatorView];
            [seperatorView release];
            
            
            
            
            UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                       seperatorView.frame.origin.y + seperatorView.frame.size.height,
                                                                       mContainerView.frame.size.width,
                                                                       kNonCancelRowHeight)];
            rowView.backgroundColor = [UIColor colorWithRed:(40.0/256.0) green:(45.0/256.0) blue:(85.0/256.0) alpha:1];

            
            
            
            
            
            UIButton *invsibleButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                                  0,
                                                                                  rowView.frame.size.width,
                                                                                  rowView.frame.size.height)];
            invsibleButton.tag = i;
            [invsibleButton addTarget:self action:@selector(ratingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [rowView addSubview:invsibleButton];
            [invsibleButton release];
            
            
            
            
            
            UIImage *bigStarImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"BigRatingStar.png" andAddIfRequired:YES];
            
            CGFloat widthRequiredForStarView = (i * bigStarImage.size.width) + ((i - 1) * kGapBetweenTwoStars);
            
            UIView *starsView = [[UIView alloc] initWithFrame:CGRectMake(roundf((rowView.frame.size.width - widthRequiredForStarView) / 2),
                                                                         roundf((rowView.frame.size.height - bigStarImage.size.height) / 2),
                                                                         widthRequiredForStarView,
                                                                         bigStarImage.size.height)];
            starsView.userInteractionEnabled = NO;
            for(int j=0; j<i; j++)
            {
                UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(j * (bigStarImage.size.width + kGapBetweenTwoStars),
                                                                                           0,
                                                                                           bigStarImage.size.width,
                                                                                           bigStarImage.size.height)];
                starImageView.image = bigStarImage;
                [starsView addSubview:starImageView];
                [starImageView release];
            }
            
            [rowView addSubview:starsView];
            [starsView release];
            

            
            [mContainerView addSubview:rowView];
            [rowView release];
            
            
            
            yCoordinatePointer = rowView.frame.origin.y + rowView.frame.size.height;
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
        [cancelButton setTitleColor: [UIColor whiteColor]forState:UIControlStateNormal];
         [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
         cancelButton.backgroundColor =[UIColor colorWithRed:(236.0/256) green:(0.0/256.0) blue:(139.0/256.0) alpha:1.0];
        cancelButton.titleLabel.font = cancelButtonFont;
        [cancelBackgroundView addSubview:cancelButton];
        [cancelButton release];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self init];
    if(self)
    {
        
    }
    return self;
}

- (void)dealloc {
    
    mRatingSubmissionRequest.delegate = nil;
    [mRatingSubmissionRequest cancel];
    [mRatingSubmissionRequest release];
    
    [mRecipe release];
    [mSubmissionCancelButton release];
    [mMessageLabel release];
    [mActivityIndicatorView release];
    [mContainerView release];
    [mBackgroundTranslucentView release];
    [super dealloc];
}



- (void)cancel:(id)sender
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
                         
                         if([viewDelegate respondsToSelector:@selector(ratingOverlayViewCancelButtonTapped:)])
                         {
                             [viewDelegate ratingOverlayViewCancelButtonTapped:self];
                         }
                     }];
}

- (void)ratingButtonTapped:(id)sender
{
    
    
    
    [mActivityIndicatorView removeFromSuperview];
    [mActivityIndicatorView release];
    mActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    mActivityIndicatorView.alpha = 0.0;
    [self addSubview:mActivityIndicatorView];
    
    
    
    
    NSString *titleString = @"Saving your rating...";
    UIFont *titleFont = [UtilityManager fontGetRegularFontOfSize:15];
    CGSize titleSize = [titleString sizeWithFont:titleFont];
    [mMessageLabel removeFromSuperview];
    [mMessageLabel release];
    mMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                              0,
                                                              self.frame.size.width,
                                                              titleSize.height)];
    mMessageLabel.backgroundColor = [UIColor clearColor];
    mMessageLabel.textColor = [UIColor whiteColor];
    mMessageLabel.text = titleString;
    mMessageLabel.font = titleFont;
    mMessageLabel.textAlignment = UITextAlignmentCenter;
    mMessageLabel.alpha = 0.0;
    [self addSubview:mMessageLabel];
    
    
    
    

    UIImage *cancelButtonImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CancelButton" ofType:@"png"]];
    
    [mSubmissionCancelButton removeFromSuperview];
    [mSubmissionCancelButton release];
    mSubmissionCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(roundf((self.frame.size.width - cancelButtonImage.size.width) / 2),
                                                                         0,
                                                                         cancelButtonImage.size.width,
                                                                         cancelButtonImage.size.height)];
    [mSubmissionCancelButton setImage:cancelButtonImage forState:UIControlStateNormal];
    [cancelButtonImage release];
    [mSubmissionCancelButton addTarget:self action:@selector(cancelRatingSubmission:) forControlEvents:UIControlEventTouchUpInside];
    mSubmissionCancelButton.alpha = 0.0;
    [self addSubview:mSubmissionCancelButton];
    
    
    
    
    // Rearrange Y Coordinates of above elements
    CGFloat yCoordinatesOfActivityIndicator = roundf((self.frame.size.height - (mActivityIndicatorView.frame.size.height + kGapBetweenActivityIndicatorAndMessageLabel + mMessageLabel.frame.size.height + kGapBetweenMessageLabelAndCancelButton + mSubmissionCancelButton.frame.size.height)) / 2);
    mActivityIndicatorView.frame = CGRectMake(roundf((self.frame.size.width - mActivityIndicatorView.frame.size.width) / 2),
                                              yCoordinatesOfActivityIndicator,
                                              mActivityIndicatorView.frame.size.width,
                                              mActivityIndicatorView.frame.size.height);
    
    mMessageLabel.frame = CGRectMake(mMessageLabel.frame.origin.x,
                                     mActivityIndicatorView.frame.origin.y + mActivityIndicatorView.frame.size.height + kGapBetweenActivityIndicatorAndMessageLabel,
                                     mMessageLabel.frame.size.width,
                                     mMessageLabel.frame.size.height);
    
    mSubmissionCancelButton.frame = CGRectMake(roundf((self.frame.size.width - mSubmissionCancelButton.frame.size.width) / 2),
                                               mMessageLabel.frame.origin.y + mMessageLabel.frame.size.height + kGapBetweenMessageLabelAndCancelButton,
                                               mSubmissionCancelButton.frame.size.width,
                                               mSubmissionCancelButton.frame.size.height);
    
    
    
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         
                         mActivityIndicatorView.alpha = 1.0;
                         mMessageLabel.alpha = 1.0;
                         mSubmissionCancelButton.alpha = 1.0;
                         
                         mContainerView.frame = CGRectMake(mContainerView.frame.origin.x,
                                                           self.frame.size.height,
                                                           mContainerView.frame.size.width,
                                                           mContainerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                         UIButton *button = (UIButton *)sender;
                         NSInteger ratingValue = button.tag;
                    
                         NSInteger deviceID = [[[[DataManager sharedDataManager] app] deviceID] integerValue];

                         Recipe *recipeObject = [[viewDelegate recipeObjectForRatingSubmissionByBVRatingOverlayView:self] retain];
                         [mRecipe release];
                         mRecipe = recipeObject;
                         
                                                
                         NSString *urlString = [NSString stringWithFormat:@"%@/rating.php?type=write&reciepe_id=%@&rating=%d", kAPIServerPath, mRecipe.recipeID, ratingValue];
                         
                         
                         if(deviceID > 0)
                         {
                             urlString = [NSString stringWithFormat:@"%@&device_id=%d", urlString, deviceID];
                         }
                         
                         mRatingSubmissionRequest.delegate = nil;
                         [mRatingSubmissionRequest cancel];
                         [mRatingSubmissionRequest release];
                         mRatingSubmissionRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
                         mRatingSubmissionRequest.delegate = self;
                         mRatingSubmissionRequest.timeOutSeconds = 30;
                         mRatingSubmissionRequest.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
                         mRatingSubmissionRequest.didFinishSelector = @selector(submitRatingsRequestFinished:);
                         mRatingSubmissionRequest.didFailSelector = @selector(submitRatingsRequestFailed:);
                         
                         NSDictionary *infoDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:ratingValue] forKey:@"ratingValueSubmitted"];
                         mRatingSubmissionRequest.userInfo = infoDic;
                         
                         [mRatingSubmissionRequest startAsynchronous];
                         
                         [mActivityIndicatorView startAnimating];
                        
                     }];
}

- (void)cancelRatingSubmission:(id)sender
{
    mRatingSubmissionRequest.delegate = nil;
    [mRatingSubmissionRequest cancel];
    [mRatingSubmissionRequest release];
    mRatingSubmissionRequest = nil;
    
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                        
                         mActivityIndicatorView.alpha = 0.0;
                         mMessageLabel.alpha = 0.0;
                         mSubmissionCancelButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.15
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              
                                              mBackgroundTranslucentView.alpha = 0.0;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              if([viewDelegate respondsToSelector:@selector(ratingOverlayView:didCancelWhileSubmittingRatingsForRecipe:)])
                                              {
                                                  [viewDelegate ratingOverlayView:self didCancelWhileSubmittingRatingsForRecipe:mRecipe];
                                              }

                                              
                                          }];
                         
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




#pragma mark - ASIHTTPRequest Delegate Methods

- (void)submitRatingsRequestFinished:(ASIHTTPRequest *)request
{
    [mRatingSubmissionRequest cancel];
    [mRatingSubmissionRequest release];
    mRatingSubmissionRequest = nil;
    
    
    NSString *responseString = [request responseString];
    NSDictionary *responseDic = [responseString JSONValue];
    NSString *success = [responseDic valueForKey:@"success"];
    if([[success lowercaseString] isEqualToString:@"yes"])
    {
        BVApp *app = [[DataManager sharedDataManager] app];
        if(app.deviceID == nil || [app.deviceID integerValue] == 0)
        {
            id deviceIDObjectInDic = [responseDic valueForKey:@"device_id"];
            if(deviceIDObjectInDic && ![deviceIDObjectInDic isKindOfClass:[NSNull class]])
            {
                
                app.deviceID = [NSNumber numberWithInteger:[deviceIDObjectInDic integerValue]];
            }
        }
        
        [self processSubmitRatingAPIResponse:responseDic forRecipe:mRecipe andRatingSubmittedByUser:[request.userInfo valueForKey:@"ratingValueSubmitted"]];
        
        [DataManager saveDatabaseOnMainThread];
        
        
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             mActivityIndicatorView.alpha = 0.0;
                             mMessageLabel.alpha = 0.0;
                             mSubmissionCancelButton.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:0.15
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  
                                                  mBackgroundTranslucentView.alpha = 0.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  if([viewDelegate respondsToSelector:@selector(ratingOverlayView:didFinishSubmittingRatingsForRecipe:)])
                                                  {
                                                      [viewDelegate ratingOverlayView:self didFinishSubmittingRatingsForRecipe:mRecipe];
                                                  }
                                                  
                                              }];
                         }];
    }
    else
    {
        NSString *errorMessage = [responseDic valueForKey:@"error"];
        
        NSLog(@"Submit Rating API Call With URL %@ failed because of error: %@", [[request url] absoluteString], errorMessage);
        
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             mActivityIndicatorView.alpha = 0.0;
                             mMessageLabel.alpha = 0.0;
                             mSubmissionCancelButton.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:0.15
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  
                                                  mBackgroundTranslucentView.alpha = 0.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  if([viewDelegate respondsToSelector:@selector(ratingOverlayView:didFailToSubmitRatingsForRecipe:)])
                                                  {
                                                      [viewDelegate ratingOverlayView:self didFailToSubmitRatingsForRecipe:mRecipe];
                                                  }

                                              }];
                         }];
    }
}

- (void)submitRatingsRequestFailed:(ASIHTTPRequest *)request
{
    [mRatingSubmissionRequest cancel];
    [mRatingSubmissionRequest release];
    mRatingSubmissionRequest = nil;
    
    
    NSLog(@"Submit Rating API Call With URL %@ failed because of error: %@", [[request url] absoluteString], [request error]);
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         mActivityIndicatorView.alpha = 0.0;
                         mMessageLabel.alpha = 0.0;
                         mSubmissionCancelButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.15
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              
                                              mBackgroundTranslucentView.alpha = 0.0;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              if([viewDelegate respondsToSelector:@selector(ratingOverlayView:didFailToSubmitRatingsForRecipe:)])
                                              {
                                                  [viewDelegate ratingOverlayView:self didFailToSubmitRatingsForRecipe:mRecipe];
                                              }
                                              
                                          }];
                     }];
}

- (void)processSubmitRatingAPIResponse:(NSDictionary *)responseDic forRecipe:(Recipe *)recipeObject andRatingSubmittedByUser:(NSNumber *)ratingSubmittedByUser
{
    
    NSNumber *numberOfSubmissionsNumber = nil;
    
    id numberOfSubmissionsObjectInDic = [responseDic valueForKey:@"finalTotalNumOfSubmission"];
    if(numberOfSubmissionsObjectInDic && ![numberOfSubmissionsObjectInDic isKindOfClass:[NSNull class]])
    {
        numberOfSubmissionsNumber = [NSNumber numberWithInteger:[numberOfSubmissionsObjectInDic integerValue]];
    }
    
    NSNumber *averageRatingNumber = nil;
    
    id averageRatingObjectInDic = [responseDic valueForKey:@"finalAverageRating"];
    if(averageRatingObjectInDic && ![averageRatingObjectInDic isKindOfClass:[NSNull class]])
    {
        averageRatingNumber = [NSNumber numberWithFloat:[averageRatingObjectInDic floatValue]];
    }
    
    BOOL hasAnythingChanged = NO;
    
    if(averageRatingNumber)
    {
        if([recipeObject.ratingValue floatValue] != [averageRatingNumber floatValue])
        {
            hasAnythingChanged = YES;
            recipeObject.ratingValue = [NSNumber numberWithFloat:[averageRatingNumber floatValue]];
        }
    }
    
    if(numberOfSubmissionsNumber)
    {
        if([recipeObject.ratingCount integerValue] != [numberOfSubmissionsNumber integerValue])
        {
            hasAnythingChanged = YES;
            recipeObject.ratingCount = [NSNumber numberWithInteger:[numberOfSubmissionsNumber integerValue]];
        }
    }
    
    if(ratingSubmittedByUser)
    {
        if([recipeObject.ratingValueSubmittedByUser floatValue] != [ratingSubmittedByUser floatValue])
        {
            hasAnythingChanged = YES;
            recipeObject.ratingValueSubmittedByUser = [NSNumber numberWithFloat:[ratingSubmittedByUser floatValue]];
        }
    }
    
    if(hasAnythingChanged)
    {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationRecipeRatingsChanged object:[NSArray arrayWithObject:recipeObject]]];
    }
}


@end
