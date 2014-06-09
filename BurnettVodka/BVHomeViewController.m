//
//  BVHomeViewController.m
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVHomeViewController.h"
#import "FeaturedRecipeItem.h"
#import "BVRecipesForFlavorViewController.h"
#import "DataManager.h"
#import "UtilityManager.h"
#import "Constants.h"
#import "Flavor.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

#define kFeaturedRecipeCardMaxHeight3Point5InchScreen 294
#define kFeaturedRecipeCardMaxHeight4InchScreen 300

#define kHeightOfTitleTextInBackgroundImage 100




@interface BVHomeViewController ()

- (void)loadUserInterface;
- (void)loadRecipesFromDiskAndShowInScrollView;

@end

@implementation BVHomeViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    
    }
    return self;
}

- (void)loadView {
    
    [super loadView];
    
    self.view.frame = CGRectMake(0,
                                 0,
                                 self.navigationController.view.frame.size.width,
                                 self.navigationController.view.frame.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadUserInterface];
    
    [self loadRecipesFromDiskAndShowInScrollView];
}

- (void) viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.screenName = @"Home Screen";
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
    CGFloat iOS7OffsetAdjustmentForStatusBar = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        iOS7OffsetAdjustmentForStatusBar = 20;
    }
    
    
    // Background Image View
    [mBackgroundImageView removeFromSuperview];
    [mBackgroundImageView release];
    mBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                         0 + iOS7OffsetAdjustmentForStatusBar,
                                                                         self.view.frame.size.width,
                                                                         self.view.frame.size.height)];
    
   
    
    NSString *backgroundImageFileName = @"";
    if([UtilityManager isThisDeviceA4InchIphone])
    {
        backgroundImageFileName = @"burnett_home_datestring_4inch.png";
    }
    else
    {
        backgroundImageFileName = @"burnett_home_datestring.png";
    }
    
    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:backgroundImageFileName andAddIfRequired:YES];
    mBackgroundImageView.image = backgroundImage;
    mBackgroundImageView.contentMode = UIViewContentModeTop;
    [self.view addSubview:mBackgroundImageView];
    
    
    
    CGFloat heightOfScrollView = kFeaturedRecipeCardMaxHeight3Point5InchScreen;
    if([UtilityManager isThisDeviceA4InchIphone])
    {
        heightOfScrollView = kFeaturedRecipeCardMaxHeight4InchScreen;
    }
    
    CGFloat heightLeftAfterTitleTextInBackground = self.view.frame.size.height - kHeightOfTitleTextInBackgroundImage - iOS7OffsetAdjustmentForStatusBar;
    
    mScrollView = [[BVCoverFlowScrollView alloc] initWithFrame:CGRectMake(0,
                                                                          iOS7OffsetAdjustmentForStatusBar +  kHeightOfTitleTextInBackgroundImage + roundf((heightLeftAfterTitleTextInBackground - heightOfScrollView) / 2),
                                                                          self.view.frame.size.width,
                                                                          heightOfScrollView)];
    mScrollView.delegate = self;
    mScrollView.coverFlowDelegate = self;
    [self.view addSubview:mScrollView];
}


- (void)loadRecipesFromDiskAndShowInScrollView
{
    NSMutableArray *mutableArrayOfFeaturedItems = [NSMutableArray array];
    
    
    NSArray *featuredRecipesLatest = [[DataManager sharedDataManager] featuredRecipesLatest];
    for(NSDictionary *recipeDic in featuredRecipesLatest)
    {
        FeaturedRecipeItem *item = [[FeaturedRecipeItem alloc] init];
        
        NSString *imagePath = [recipeDic valueForKey:@"imagePath"];
        NSString *filePathInLocalSystem = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:[imagePath lastPathComponent]];
        item.imageFilePath = filePathInLocalSystem;
        item.recipeID = [[recipeDic valueForKey:@"db_id"] integerValue];
        
        [mutableArrayOfFeaturedItems addObject:item];
        [item release];
        
        
    }
    
    if([mutableArrayOfFeaturedItems count] == 0)
    {
        NSArray *featuredRecipesDefault = [[DataManager sharedDataManager] featuredRecipesDefault];
        for(NSDictionary *recipeDic in featuredRecipesDefault)
        {
            FeaturedRecipeItem *item = [[FeaturedRecipeItem alloc] init];
            
            NSString *fileName = [recipeDic valueForKey:@"defaultImageName"];
            item.imageFilePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
            
            item.recipeID = [[recipeDic valueForKey:@"db_id"] integerValue];
            
            [mutableArrayOfFeaturedItems addObject:item];
            [item release];
        }
    }
    
    [mScrollView resetScrollViewWithRecipesArray:[NSArray arrayWithArray:mutableArrayOfFeaturedItems]];
}


#pragma mark - UIScrollView Delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [mScrollView scrollViewScrolled];
}



#pragma mark - BVCoverFlowScrollView Delegate methods

- (void)coverFlowScrollView:(BVCoverFlowScrollView *)scrollView userTappedWithRecipeID:(NSInteger)recipeID
{
    Flavor *flavor = nil;
    if(recipeID != 0)
    {
        Recipe *recipeObject = [[DataManager sharedDataManager] recipesGetRecipeWithRecipeID:recipeID];
        flavor = recipeObject.flavor;
    }
    else
    {
        flavor = [[DataManager sharedDataManager] flavorsGetFlavorWithFlavorTitle:@"Pumpkin Spice"];
    }
    NSString *event = @"home";
    NSString *value = [[NSString stringWithFormat:@"%@", flavor.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:event]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"home"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];    // Event value

    
    BVRecipesForFlavorViewController *viewController = [[BVRecipesForFlavorViewController alloc] initWithFlavor:flavor];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}


#pragma mark - Public methods

- (void)reload
{
    [self loadRecipesFromDiskAndShowInScrollView];
}

@end
