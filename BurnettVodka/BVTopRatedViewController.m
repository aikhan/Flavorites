//
//  BVTopRatedViewController.m
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVTopRatedViewController.h"
#import "UtilityManager.h"
#import "DataManager.h"
#import "Recipe.h"
#import "BVRecipeDetailViewController.h"
#import "Constants.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

#define kInformativeMessageForRatingsNotRecieved @"The app has not yet received ratings from server"


@interface BVTopRatedViewController ()

- (void)loadUserInterface;

- (void)createDataForTableView;

- (void)startDownloadForLazyLoadImage:(HSLazyLoadImage *)image;

- (void)showInformativeMessageLabelWithMessage:(NSString *)message;

- (void)hideInformativeMessageLabel;

@end

@implementation BVTopRatedViewController

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
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeRatingsDataChanged:) name:kNotificationRecipeRatingsChanged object:nil];
    

    [UtilityManager addTitle:@"Top Rated" toNavigationItem:self.navigationItem];
    
    [self loadUserInterface];
    
    [self createDataForTableView];
    
    if([mTableData count] == 0)
    {
        [self showInformativeMessageLabelWithMessage:kInformativeMessageForRatingsNotRecieved];
    }
    else
    {
        [self hideInformativeMessageLabel];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   // self.screenName = @"Top Rated View";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    mLazyImageDownloader.delegate = nil;
    [mLazyImageDownloader release];
    
    [mInformatiiveMessageLabel release];
    
    [mBackgroundImageView release];
    [mTableData release];
    [mTableView release];
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
    
    
    
    
    
    // TableView
    [mTableView removeFromSuperview];
    [mTableView release];
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               self.view.frame.size.width,
                                                               self.view.frame.size.height)];
    mTableView.dataSource = self;
    mTableView.delegate = self;
    mTableView.backgroundColor = [UIColor clearColor];
    mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:mTableView];
    
    
    
}


- (void)showInformativeMessageLabelWithMessage:(NSString *)message
{
    if(mInformatiiveMessageLabel == nil)
    {
        mInformatiiveMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                                              0,
                                                                              self.view.frame.size.width - 10 - 10,
                                                                              self.view.frame.size.height)];
        mInformatiiveMessageLabel.font = [UtilityManager fontGetRegularFontOfSize:18];
        mInformatiiveMessageLabel.textColor = [UIColor colorWithRed:0 green:(73.0/256.0) blue:(144.0/256.0) alpha:1.0];
        mInformatiiveMessageLabel.backgroundColor = [UIColor clearColor];
        mInformatiiveMessageLabel.textAlignment = UITextAlignmentCenter;
        mInformatiiveMessageLabel.numberOfLines = 10;
        [self.view addSubview:mInformatiiveMessageLabel];
    }
    
    mInformatiiveMessageLabel.hidden = NO;
    mInformatiiveMessageLabel.text = message;
}

- (void)hideInformativeMessageLabel
{
    mInformatiiveMessageLabel.hidden = YES;
}




#pragma mark - Data Methods

- (void)createDataForTableView
{
    [mTableData removeAllObjects];
    [mTableData release];
    mTableData = [[NSMutableArray alloc] init];
    
    
    
    NSMutableArray *finalArrayWithAllSortings = [[NSMutableArray alloc] init];
    
    
    
    NSArray *allRecipes = [[DataManager sharedDataManager] recipesGetAllRecipes];
    
    NSMutableDictionary *mapOfRecipeObjectsCategoriedBySameRatingValue = [[NSMutableDictionary alloc] init];
    
    for(Recipe *recipeObject in allRecipes)
    {
        NSString *ratingValueKey = [NSString stringWithFormat:@"%.2f", [recipeObject.ratingCount floatValue] * [recipeObject.ratingValue floatValue]];
        NSMutableArray *array = [mapOfRecipeObjectsCategoriedBySameRatingValue valueForKey:ratingValueKey];
        if(array == nil)
        {
            array = [[NSMutableArray alloc] init];
            [mapOfRecipeObjectsCategoriedBySameRatingValue setValue:array forKey:ratingValueKey];
            [array release];
        }
        [array addObject:recipeObject];
    }
        
    NSMutableArray *allKeysOfMap = [[NSMutableArray alloc] initWithArray:[mapOfRecipeObjectsCategoriedBySameRatingValue allKeys]];
    [allKeysOfMap sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [((NSString *)obj2) compare:((NSString *)obj1) options:NSNumericSearch];
    }];
    
    
    for(NSString *key in allKeysOfMap)
    {
        NSMutableArray *arrayOfRecipesWithSameRatingValue = [mapOfRecipeObjectsCategoriedBySameRatingValue valueForKey:key];
        
        
        NSMutableDictionary *mapOfRecipeObjectsCategoriedBySameRatingCount = [[NSMutableDictionary alloc] init];
        
        for(Recipe *recipeObject in arrayOfRecipesWithSameRatingValue)
        {
            NSString *ratingCountKey = [NSString stringWithFormat:@"%d", [recipeObject.ratingCount integerValue]];
            NSMutableArray *array = [mapOfRecipeObjectsCategoriedBySameRatingCount valueForKey:ratingCountKey];
            if(array == nil)
            {
                array = [[NSMutableArray alloc] init];
                [mapOfRecipeObjectsCategoriedBySameRatingCount setValue:array forKey:ratingCountKey];
                [array release];
            }
            [array addObject:recipeObject];
        }
        
        NSMutableArray *allKeysOfMapOfRatingCount = [[NSMutableArray alloc] initWithArray:[mapOfRecipeObjectsCategoriedBySameRatingCount allKeys]];
        [allKeysOfMapOfRatingCount sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            return [((NSString *)obj2) compare:((NSString *)obj1) options:NSNumericSearch];
        }];
        
        
        for(NSString *countKey in allKeysOfMapOfRatingCount)
        {
            NSMutableArray *arrayOfRecipesWithSameRatingCount = [mapOfRecipeObjectsCategoriedBySameRatingCount valueForKey:countKey];
            [arrayOfRecipesWithSameRatingCount sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
            
            
            for(Recipe *recipeObject in arrayOfRecipesWithSameRatingCount)
            {
                [finalArrayWithAllSortings addObject:recipeObject];
            }
        }
        
        
        [mapOfRecipeObjectsCategoriedBySameRatingCount release];
        [allKeysOfMapOfRatingCount release];
    }
    
    
    [mapOfRecipeObjectsCategoriedBySameRatingValue release];
    [allKeysOfMap release];
    
    
    
    int count = 0;
    for(int i=0; i<[finalArrayWithAllSortings count]; i++)
    {
        Recipe *recipeObject = [finalArrayWithAllSortings objectAtIndex:i];
        [mTableData addObject:recipeObject];
        count++;
        
        if(count >= 10)
            break;
    }
    
    
    [finalArrayWithAllSortings release];
}










#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [mTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BVTopRatedTabRecipeCell *cell = nil;
    
    if(indexPath.row == 0)
    {
        static NSString *CellIdentifier = @"CellFirst";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[[BVTopRatedTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionFirst] autorelease];
            cell.cellDelegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else if(indexPath.row == ([mTableData count] - 1))
    {
        static NSString *CellIdentifier = @"CellLast";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[[BVTopRatedTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionLast] autorelease];
            cell.cellDelegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else
    {
        static NSString *CellIdentifier = @"CellSandwiched";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[[BVTopRatedTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionSandwiched] autorelease];
            cell.cellDelegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    
    
    // Configure the cell...
    Recipe *recipeObject = [mTableData objectAtIndex:indexPath.row];
    [cell updateCellWithRecipe:recipeObject andRatingNumber:(indexPath.row + 1)];
    
    
    return cell;
}


#pragma mark - Table view Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0;
    
    
    if(indexPath.row == 0)
    {
        rowHeight = [BVRecipeCell rowHeightOfCellWithCellPosition:BVRecipeCellPositionFirst];
    }
    else if(indexPath.row == ([mTableData count] - 1))
    {
        rowHeight = [BVRecipeCell rowHeightOfCellWithCellPosition:BVRecipeCellPositionLast];
    }
    else
    {
        rowHeight = [BVRecipeCell rowHeightOfCellWithCellPosition:BVRecipeCellPositionSandwiched];
    }

    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Recipe *recipeObject = [mTableData objectAtIndex:indexPath.row];
    NSString *event = @"Top Rated";
    NSString *value = [[NSString stringWithFormat:@"%@", recipeObject.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:event]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];
    
    BVRecipeDetailViewController *viewController = [[BVRecipeDetailViewController alloc] initWithRecipe:recipeObject];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}



#pragma mark - BVRecipeCell Delegate

- (void)recipeCell:(BVRecipeCell *)cell needsImageReloadForRecipe:(Recipe *)recipeObject
{
    HSLazyLoadImage *lazyImage = [[HSLazyLoadImage alloc] initWithFileName:[recipeObject pngImageFileName]];
    [self startDownloadForLazyLoadImage:lazyImage];
    [lazyImage release];
}



#pragma mark - Helper Methods

- (void)startDownloadForLazyLoadImage:(HSLazyLoadImage *)image
{
    if(mLazyImageDownloader == nil)
    {
        mLazyImageDownloader = [[HSLazyImageDownloader alloc] init];
        mLazyImageDownloader.delegate = self;
    }
    
    [mLazyImageDownloader addLazyLoadImage:image];
}



- (void)reloadCellsWithInfo:(NSDictionary *)infoDic
{
    UIImage *recipeImage = [infoDic valueForKey:@"image"];
    
    
    // Update Cells in AZTableView
    NSArray *arrayOfIndexPathsInTableView = [infoDic valueForKey:@"tableViewIndexPaths"];
    for(NSIndexPath *indexPath in arrayOfIndexPathsInTableView)
    {
        BVRecipeCell *recipeCell = (BVRecipeCell *)[mTableView cellForRowAtIndexPath:indexPath];
        if(recipeCell)
        {
            [recipeCell updateRecipeImageWithImage:recipeImage];
        }
    }
}



#pragma mark - HSLazyImageDownloader Delegate Methods

- (void)imageDownloader:(HSLazyImageDownloader *)downloader finishedLoadingForImage:(HSLazyLoadImage *)image
{
    // This callback shall be at NON main thread.
    
    
    // Add it to cache
    [[UtilityManager sharedUtilityManager] cacheAddImage:image.image againstCompleteFileName:image.fileName];
    
    
    
    // Check and find Index Paths for cells in the TableView
    
    NSMutableArray *mutableArrayOfIndexPathsInTableView = [[NSMutableArray alloc] init];
    
    for(int i=0; i<[mTableData count]; i++)
    {
        Recipe *recipeObject = [mTableData objectAtIndex:i];
        
        if([image.fileName isEqualToString:[recipeObject pngImageFileName]])
        {
            [mutableArrayOfIndexPathsInTableView addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    
    NSArray *arrayOfIndexPathsInTableView = [NSArray arrayWithArray:mutableArrayOfIndexPathsInTableView];
    [mutableArrayOfIndexPathsInTableView release];
    
    
    
    
    
    
    
    NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:image.image, @"image", arrayOfIndexPathsInTableView, @"tableViewIndexPaths", nil];
    
    [self performSelectorOnMainThread:@selector(reloadCellsWithInfo:) withObject:infoDic waitUntilDone:NO];
}



#pragma mark -
#pragma mark NSNotification Methods

- (void)recipeRatingsDataChanged:(NSNotification *)notification
{
    [self createDataForTableView];
    
    if([mTableData count] == 0)
    {
        [self showInformativeMessageLabelWithMessage:kInformativeMessageForRatingsNotRecieved];
    }
    else
    {
        [self hideInformativeMessageLabel];
    }
    
    [mTableView reloadData];
}

@end
