//
//  BVFlavorViewController.m
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVFlavorViewController.h"
#import "Flavor.h"
#import "UtilityManager.h"
#import "DataManager.h"
#import "BVRecipesForFlavorViewController.h"
#import <Twitter/Twitter.h>
#import "Constants.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"


#define kPaddingLeft 10
#define kPaddingRight 10
#define kPaddingTop 10
#define kPaddingBottom 10

#define kFlavorViewWidth 94
#define kFlavorViewHeight 96

#define kFlavorViewTitlePaddingLeft 2
#define kFlavorViewTitlePaddingRight 2
#define kFlavorViewTitlePaddingBottom 2

#define kFlavorViewGapBetweenFlavorImageAndTitle 5


@interface BVFlavorView ()

- (void)createUIWithFlavorTitle:(NSString *)titleString andImageFileName:(NSString *)imageFileName;

@end

@implementation BVFlavorView

@synthesize viewDelegate;

- (id)initWithFrame:(CGRect)frame andFlavor:(Flavor *)flavorObject
{
    self = [super initWithFrame:frame];
    if(self)
    {
        mFlavor = [flavorObject retain];
        [self createUIWithFlavorTitle:flavorObject.title andImageFileName:flavorObject.imageName];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andFlavorDictionary:(NSDictionary *)flavorDic
{
    self = [super initWithFrame:frame];
    if(self)
    {
        mFlavorInfoDictionary = [flavorDic retain];
        [self createUIWithFlavorTitle:[mFlavorInfoDictionary valueForKey:@"title"] andImageFileName:[mFlavorInfoDictionary valueForKey:@"image_file_name"]];
    }
    return self;
}

- (void)createUIWithFlavorTitle:(NSString *)titleString andImageFileName:(NSString *)imageFileName
{
    self.backgroundColor = [UIColor clearColor];

    
    
    UIButton *invisibleButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           self.frame.size.width,
                                                                           self.frame.size.height)];
    [invisibleButton addTarget:self action:@selector(flavorTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:invisibleButton];
    [invisibleButton release];
    
    
    

    UIImageView *flavorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                 0,
                                                                                 self.frame.size.width,
                                                                                 self.frame.size.height)];
    
    NSString *imageExtention = [imageFileName pathExtension];
    NSString *imageFileNameWithoutExtension = [[imageFileName lastPathComponent] stringByDeletingPathExtension];
    UIImage *flavorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageFileNameWithoutExtension ofType:imageExtention]];
    flavorImageView.image = flavorImage;
    [flavorImage release];

    [self addSubview:flavorImageView];
    [flavorImageView release];
    
    
    
    if([[DataManager sharedDataManager] flavorsIsThisANewFlavor:mFlavor])
    {
        UIImage *newFlavorTagImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"NewFlavorBadge.png" andAddIfRequired:YES];
        UIImageView *badgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    newFlavorTagImage.size.width,
                                                                                    newFlavorTagImage.size.height)];
        badgeImageView.image = newFlavorTagImage;
        [self addSubview:badgeImageView];
        [badgeImageView release];
    }
    
    
    
    
    
    
    
    CGFloat widthAvailableForTitle = self.frame.size.width - kFlavorViewTitlePaddingLeft - kFlavorViewTitlePaddingRight;
    NSString *sampleOneLineString = @"Sample";
    UIFont *titleFont = [UtilityManager fontGetRegularFontOfSize:11];
    CGSize oneLinetitleSize = [sampleOneLineString sizeWithFont:titleFont];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFlavorViewTitlePaddingLeft,
                                                                    self.frame.size.height - (kFlavorViewTitlePaddingBottom + (oneLinetitleSize.height * 2)),
                                                                    widthAvailableForTitle,
                                                                    oneLinetitleSize.height * 2)];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.font = titleFont;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = titleString;
    titleLabel.textColor = [UIColor colorWithRed:0 green:(73.0 / 256.0) blue:(144.0 / 256.0) alpha:1.0];
    titleLabel.numberOfLines = 2;
    [self addSubview:titleLabel];
    [titleLabel release];

}

- (void)dealloc {
    
    [mFlavorInfoDictionary release];
    [mFlavor release];
    [super dealloc];
}

- (void)flavorTapped:(id)sender
{
    if([viewDelegate respondsToSelector:@selector(flavorView:userTappedOnViewWithFlavor:)])
    {
        [viewDelegate flavorView:self userTappedOnViewWithFlavor:mFlavor];
    }
}

@end




@interface BVFlavorViewController ()

- (void)loadUserInterface;

- (NSArray *)sampleDataFlavors;

@end

@implementation BVFlavorViewController

@synthesize mScrollView;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 // iOS 7.0 supported
        
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
        
#endif

    }
    return self;
}


- (void)loadView {
    
    [super loadView];
    
    CGFloat iOS7OffsetAdjustmentForStatusBar = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        iOS7OffsetAdjustmentForStatusBar = 20;
    }
    
    self.view.frame = CGRectMake(0,
                                 0,
                                 self.navigationController.view.frame.size.width,
                                 self.navigationController.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - iOS7OffsetAdjustmentForStatusBar);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flavorImageUpdated) name:@"notification" object:nil];
}

- (void)flavorImageUpdated{
    DebugLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [UtilityManager addTitle:@"Flavors" toNavigationItem:self.navigationItem];
    
    [self loadUserInterface];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //self.screenName = @"Flavor View";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [mBackgroundImageView release];
    [mScrollView release];
    [super dealloc];
}


#pragma mark - UI Methods

- (void)loadUserInterface
{
    // Background Image View
    [mBackgroundImageView removeFromSuperview];
    [mBackgroundImageView release];
    mBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         self.view.frame.size.width,
                                                                         self.view.frame.size.height)];

    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"GeneralBackground.png" andAddIfRequired:YES];
    mBackgroundImageView.image = backgroundImage;
    mBackgroundImageView.contentMode = UIViewContentModeTop;
    [self.view addSubview:mBackgroundImageView];
    
    
    
    
    // Setup Scroll View
    [mScrollView removeFromSuperview];
    [mScrollView release];
    mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 self.view.frame.size.width,
                                                                 self.view.frame.size.height)];
    [self.view addSubview:mScrollView];
    
    
    

    // Remove Previous Subviews Of Type BVFlavorView from scroll view.
    NSArray *previousArrayOfSubViews = [mScrollView subviews];
    for(UIView *previousSubView in previousArrayOfSubViews)
    {
        if([previousSubView isKindOfClass:[BVFlavorView class]])
        {
            [previousSubView removeFromSuperview];
        }
    }
    

    
    NSArray *arrayOfFlavors = [[[DataManager sharedDataManager] flavorsGetAllFlavors] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];

    
    
    
    CGFloat yCoordinatePointer = kPaddingTop;
    CGFloat gapBetweenFlavors = roundf((self.view.frame.size.width - (kPaddingLeft + kPaddingRight + (3 * kFlavorViewWidth))) / 2);
    
    for(int i=0; i<[arrayOfFlavors count]; i++)
    {
        Flavor *flavor = [arrayOfFlavors objectAtIndex:i];
        
        NSInteger horizontalPositionIndex = i % 3;
        BVFlavorView *flavorView = [[BVFlavorView alloc] initWithFrame:CGRectMake(kPaddingLeft + (horizontalPositionIndex * (kFlavorViewWidth + gapBetweenFlavors)),
                                                                                  yCoordinatePointer,
                                                                                  kFlavorViewWidth,
                                                                                  kFlavorViewHeight)
                                                             andFlavor:flavor];
        flavorView.viewDelegate = self;
        
        if((i + 1) < [arrayOfFlavors count])
        {
            if(horizontalPositionIndex >= 2)
            {
                yCoordinatePointer = flavorView.frame.origin.y + flavorView.frame.size.height;
                yCoordinatePointer = yCoordinatePointer + gapBetweenFlavors;
            }
        }
        else
        {
            yCoordinatePointer = flavorView.frame.origin.y + flavorView.frame.size.height + kPaddingBottom;
        }

        
        [mScrollView addSubview:flavorView];
    }
    
    mScrollView.contentSize = CGSizeMake(mScrollView.frame.size.width,
                                         yCoordinatePointer);
    
}



#pragma mark - Sample Data Methods

- (NSArray *)sampleDataFlavors
{    
    NSDictionary *flavorDicFromDisk = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Flavors" ofType:@"plist"]];
    NSArray *flavorsArrayFromDisk = [NSArray arrayWithObject:[flavorDicFromDisk valueForKey:@"Flavors_Array"]];
    [flavorDicFromDisk release];

    return flavorsArrayFromDisk;
}


#pragma mark - BVFlavorView Delegate Methods

- (void)flavorView:(BVFlavorView *)flavorView userTappedOnViewWithFlavor:(Flavor *)flavor
{
    NSString *event = @"flavor";
    NSString *value =[[NSString stringWithFormat:@"%@", flavor.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:event]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];
    
    BVRecipesForFlavorViewController *viewController = [[BVRecipesForFlavorViewController alloc] initWithFlavor:flavor];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

@end
