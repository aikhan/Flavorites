//
//  BVRecipesForFlavorViewController.m
//  BurnettVodka
//
//  Created by admin on 7/26/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVRecipesForFlavorViewController.h"
#import "Flavor.h"
#import "UtilityManager.h"
#import "DataManager.h"
#import "Recipe.h"
#import "BVRecipeDetailViewController.h"
#import "Constants.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface BVRecipesForFlavorViewController ()

- (void)loadUserInterface;

- (void)createDataForTableView;

- (void)startDownloadForLazyLoadImage:(HSLazyLoadImage *)image;

@end

@implementation BVRecipesForFlavorViewController

- (id)initWithFlavor:(Flavor *)flavor
{
    self = [super init];
    if(self)
    {
        mFlavor = [flavor retain];
        
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
        iOS7OffsetAdjustmentForStatusBar = 0;
    }
    
    self.view.frame = CGRectMake(0,
                                 0,
                                 self.navigationController.view.frame.size.width,
                                 self.navigationController.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - iOS7OffsetAdjustmentForStatusBar);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeRatingsDataChanged:) name:kNotificationRecipeRatingsChanged object:nil];
    
    
   // [UtilityManager addTitle:mFlavor.title toNavigationItem:self.navigationItem];
    
    
    UIBarButtonItem *backButton = [UtilityManager navigationBarBackButtonItemWithTarget:self andAction:@selector(backButtonClicked:) andHeight:self.navigationController.navigationBar.frame.size.height];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    
    [self loadUserInterface];
    
    [self createDataForTableView];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, 320, 65);

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reciepeTab.png"] forBarMetrics:UIBarMetricsDefault];

   // self.screenName = @"Recipies For Flavor View";
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
    
    [mBackgroundImageView release];
    [mTableData release];
    [mTableView release];
    [mFlavor release];
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
    
    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"reciepebg.png" andAddIfRequired:YES];
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
    mTableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:mTableView];
    
    
    
}


#pragma mark - Data Methods

- (void)createDataForTableView
{
    [mTableData removeAllObjects];
    [mTableData release];
    mTableData = [[NSMutableArray alloc] init];
    
    
    
    NSArray *allRecipes = [mFlavor.recipes allObjects];
    NSArray *sortedRecipes = [allRecipes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
        
    for(Recipe *recipeObject in sortedRecipes)
    {
        [mTableData addObject:recipeObject];
    }
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
    BVRecipeCell *cell = nil;
    if([mTableData count] == 1)
    {
        static NSString *CellIdentifier = @"CellFirstAndLast";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[[BVRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionFirstAndLast] autorelease];
            cell.cellDelegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"CellFirst";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.backgroundColor=[UIColor clearColor];

            if(cell == nil)
            {
                cell = [[[BVRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionFirst] autorelease];
                cell.cellDelegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else if(indexPath.row == ([mTableData count] - 1))
        {
            static NSString *CellIdentifier = @"CellLast";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.backgroundColor=[UIColor clearColor];

            if(cell == nil)
            {
                cell = [[[BVRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionLast] autorelease];
                cell.cellDelegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else
        {
            static NSString *CellIdentifier = @"CellSandwiched";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.backgroundColor=[UIColor clearColor];

            if(cell == nil)
            {
                cell = [[[BVRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionSandwiched] autorelease];
                cell.cellDelegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
    
    
    
    // Configure the cell...
    Recipe *recipeObject = [mTableData objectAtIndex:indexPath.row];
    [cell updateCellWithRecipe:recipeObject];
    
    cell.backgroundColor=[UIColor clearColor];

    return cell;
}


#pragma mark - Table view Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0;
    
    if([mTableData count] == 1)
    {
        rowHeight = [BVRecipeCell rowHeightOfCellWithCellPosition:BVRecipeCellPositionFirstAndLast];
    }
    else
    {
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
    }
    
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Recipe *recipeObject = [mTableData objectAtIndex:indexPath.row];
    NSString *event = @"Recipe for Flavor";
    NSString *recipe = [NSString stringWithFormat:@"%@", mFlavor.title];
    NSString *flavor = [NSString stringWithFormat:@"%@", recipeObject.title];
   // [[NSString stringWithFormat:@"%@_%@", mFlavor.title, recipeObject.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:recipe forKey:flavor]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event     // Event category (required)
                                                          action:recipe  // Event action (required)
                                                           label:flavor          // Event label
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



#pragma mark - Action Methods

- (void)backButtonClicked:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:NO];
}




#pragma mark -
#pragma mark NSNotification Methods

- (void)recipeRatingsDataChanged:(NSNotification *)notification
{
    NSArray *arrayOfRecipesForWhichDataHasChanged = [notification object];
    NSArray *arrayOfIndexPathsOfVisibleCells = [mTableView indexPathsForVisibleRows];
    NSMutableArray *arrayOfIndexPathsToReload = [NSMutableArray array];
    
    for(NSIndexPath *indexPath in arrayOfIndexPathsOfVisibleCells)
    {
        Recipe *recipeObjectInTableView = [mTableData objectAtIndex:indexPath.row];
        
        if([arrayOfRecipesForWhichDataHasChanged containsObject:recipeObjectInTableView])
        {
            [arrayOfIndexPathsToReload addObject:indexPath];
        }
    }
    
    
    [mTableView beginUpdates];
    [mTableView reloadRowsAtIndexPaths:arrayOfIndexPathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
    [mTableView endUpdates];
}


@end
