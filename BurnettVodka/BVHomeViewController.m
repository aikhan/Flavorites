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
    Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(onTimer) userInfo: nil repeats: YES];

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
    [mScrollView setCanCancelContentTouches:YES];
    [self.view addSubview:mScrollView];
}


- (void)loadRecipesFromDiskAndShowInScrollView
{
    NSMutableArray *mutableArrayOfFeaturedItems = [NSMutableArray array];
    
    
    NSArray *featuredRecipesLatest = [[DataManager sharedDataManager] featuredRecipesLatest];
    for(NSDictionary *recipeDic in featuredRecipesLatest)
    {
        FeaturedRecipeItem *item = [[FeaturedRecipeItem alloc] init];
        
        NSString *imagePath = [recipeDic valueForKey:@"drink_image"];
        NSString *filePathInLocalSystem = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:[imagePath lastPathComponent]];
        item.imageFilePath = filePathInLocalSystem;
        item.recipeID = [[recipeDic valueForKey:@"id"] integerValue];
        
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

-(void) onTimer {
    if (mScrollView.contentOffset.x<mScrollView.contentSize.width-[[UIScreen mainScreen] bounds].size.width) {
        mScrollView.contentOffset = CGPointMake(mScrollView.contentOffset.x+2.0,0);
    }
    else {
        [Scrolltimer invalidate];
        Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(onTimer2) userInfo: nil repeats: YES];
    }
}

-(void)onTimer2 {
    if (mScrollView.contentOffset.x>0) {
        mScrollView.contentOffset = CGPointMake(mScrollView.contentOffset.x-2.0,0);
    }
    else {
        [Scrolltimer invalidate];
        Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(onTimer) userInfo: nil repeats: YES];
    }
}


#pragma mark - UIScrollView Delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // [mScrollView scrollViewScrolled];
}



#pragma mark - BVCoverFlowScrollView Delegate methods

- (void)coverFlowScrollView:(BVCoverFlowScrollView *)scrollView userTappedWithRecipeID:(NSInteger)recipeID
{
    int count=0;
    int finalCount=0;;
    RecipeDescription = [[BVRecipeDescriptionView alloc] initWithFrame:CGRectMake(0,0/*
                                                                                  [UIScreen mainScreen].bounds.size.width/2-750, [UIScreen mainScreen].bounds.size.height/2-170*/, 150, 340)];
    
    NSMutableArray *mutableArrayOfFeaturedItems = [NSMutableArray array];
    NSArray *featuredRecipesLatest = [[DataManager sharedDataManager] featuredRecipesLatest];
    
    for(NSDictionary *recipeDic in featuredRecipesLatest)
    {
        count++;
        NSString *fileName = [recipeDic valueForKey:@"id"];
        if ([fileName integerValue]==recipeID) {
            finalCount=count;
            FeaturedRecipeItem *item = [[FeaturedRecipeItem alloc] init];
            NSString *imagePath = [recipeDic valueForKey:@"drink_image"];
            NSString *filePathInLocalSystem = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:[imagePath lastPathComponent]];
            item.imageFilePath = filePathInLocalSystem;
            item.recipeID = [[recipeDic valueForKey:@"id"] integerValue];
            [mutableArrayOfFeaturedItems addObject:item];
            [item release];
            [RecipeDescription.Heading setText:[NSString stringWithFormat:@"%@",[recipeDic valueForKey:@"name"]]];
            [RecipeDescription.Ingredients setText:[NSString stringWithFormat:@"%@",[recipeDic valueForKey:@"ingredients"]]];
            [RecipeDescription.Procedure setText:[NSString stringWithFormat:@"%@",[recipeDic valueForKey:@"directions"]]];
            NSString *imagePath1 = [recipeDic valueForKey:@"recipeimage"];
            NSString *filePathInLocalSystem1 = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:[imagePath1 lastPathComponent]];
            [RecipeDescription.RecipeTmg setImage:[UIImage imageWithContentsOfFile:filePathInLocalSystem1]];
            [RecipeDescription.CrossBtn addTarget:self
                                           action:@selector(CrossTarget:)
                                 forControlEvents:UIControlEventTouchUpInside];
            [RecipeDescription.LoadmoreBtn addTarget:self
                                              action:@selector(ViewMore:)
                                    forControlEvents:UIControlEventTouchUpInside];
            [RecipeDescription.LoadmoreBtn setTag:recipeID];
            [mutableArrayOfFeaturedItems addObject:RecipeDescription];
        }
        else {
            FeaturedRecipeItem *item = [[FeaturedRecipeItem alloc] init];
            NSString *imagePath = [recipeDic valueForKey:@"drink_image"];
            NSString *filePathInLocalSystem = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:[imagePath lastPathComponent]];
            item.imageFilePath = filePathInLocalSystem;
            item.recipeID = [[recipeDic valueForKey:@"id"] integerValue];
            [mutableArrayOfFeaturedItems addObject:item];
            [item release];
        }
    }
    [mScrollView resetScrollViewWithRecipesArray:[NSArray arrayWithArray:mutableArrayOfFeaturedItems]];
    [mScrollView setContentOffset:CGPointMake(150*finalCount ,[UIScreen mainScreen].bounds.origin.y)];
    [Scrolltimer invalidate];
}

-(void)CrossTarget:(id)sender {
    [RecipeDescription removeFromSuperview];
    [self loadRecipesFromDiskAndShowInScrollView];
    Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(onTimer) userInfo: nil repeats: YES];
}

- (void)ViewMore:(id)Sender {
    NSUInteger recipeID = [Sender tag];
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
    [RecipeDescription removeFromSuperview];
    [self loadRecipesFromDiskAndShowInScrollView];
    Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(onTimer) userInfo: nil repeats: YES];
}

#pragma mark - Public methods

- (void)reload
{
    [self loadRecipesFromDiskAndShowInScrollView];
}

@end
