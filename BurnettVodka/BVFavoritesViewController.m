//
//  BVFavoritesViewController.m
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVFavoritesViewController.h"
#import "UtilityManager.h"
#import "DataManager.h"
#import "Recipe.h"
#import "BVRecipeDetailViewController.h"
#import "BVApp.h"
#import "Constants.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

#define kInformativeMessageForNoFavoriteRecipes @"Please add recipes to My Faves"



@interface BVFavoritesViewController ()

- (void)loadUserInterface;

- (void)createDataForTableView;

- (void)startDownloadForLazyLoadImage:(HSLazyLoadImage *)image;

- (void)ifDeleteViewIsActiveOnAnyCellThenHideItAnimated:(BOOL)animated;

- (void)showInformativeMessageLabelWithMessage:(NSString *)message;

@end

@implementation BVFavoritesViewController

@synthesize indexPathForCellWithActiveDeleteView = _indexPathForCellWithActiveDeleteView;

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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeAddedToFavorites:) name:kNotificationRecipeAddedToFavorite object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeRemovedFromFavorites:) name:kNotificationRecipeRemovedFromFavoriteFromRecipeDetailScreen object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeRatingsDataChanged:) name:kNotificationRecipeRatingsChanged object:nil];
    
    
    [UtilityManager addTitle:@"My Faves" toNavigationItem:self.navigationItem];
    
    [self loadUserInterface];
    
    [self createDataForTableView];
    
    if([mTableData count] == 0)
    {
        [self showInformativeMessageLabelWithMessage:kInformativeMessageForNoFavoriteRecipes];
    }
    else
    {
        [self hideInformativeMessageLabel];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self ifDeleteViewIsActiveOnAnyCellThenHideItAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //self.screenName = @"Favorites View";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [mInformatiiveMessageLabel release];
    
    [_indexPathForCellWithActiveDeleteView release];
    
    mLazyImageDownloader.delegate = nil;
    [mLazyImageDownloader release];
    
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
    
    
    
    NSArray *allRecipes = [[[[DataManager sharedDataManager] app] favoriteRecipes] allObjects];
    NSArray *allSortedRecipes = [allRecipes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    
    for(Recipe *recipeObject in allSortedRecipes)
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
    BVFavTabRecipeCell *cell = nil;
    
    if([mTableData count] == 1)
    {
        static NSString *CellIdentifier = @"CellFirstAndLast";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[[BVFavTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionFirstAndLast] autorelease];
            cell.cellDelegate = self;
            cell.favTabRecipeCellDelegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"CellFirst";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil)
            {
                cell = [[[BVFavTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionFirst] autorelease];
                cell.cellDelegate = self;
                cell.favTabRecipeCellDelegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else if(indexPath.row == ([mTableData count] - 1))
        {
            static NSString *CellIdentifier = @"CellLast";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil)
            {
                cell = [[[BVFavTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionLast] autorelease];
                cell.cellDelegate = self;
                cell.favTabRecipeCellDelegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else
        {
            static NSString *CellIdentifier = @"CellSandwiched";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil)
            {
                cell = [[[BVFavTabRecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andCellPosition:BVRecipeCellPositionSandwiched] autorelease];
                cell.cellDelegate = self;
                cell.favTabRecipeCellDelegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
    
    
    
    
    // Configure the cell...
    Recipe *recipeObject = [mTableData objectAtIndex:indexPath.row];
    [cell updateCellWithRecipe:recipeObject];
    
    
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
    NSString *event = @"Favorites";
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

- (void)ifDeleteViewIsActiveOnAnyCellThenHideItAnimated:(BOOL)animated
{
    if(self.indexPathForCellWithActiveDeleteView)
    {
        BVFavTabRecipeCell *previousCellWithDeleteActive = (BVFavTabRecipeCell *)[mTableView cellForRowAtIndexPath:self.indexPathForCellWithActiveDeleteView];
        
        if(previousCellWithDeleteActive)
        {
            [previousCellWithDeleteActive hideDeleteViewAnimated:animated];
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



#pragma mark - BVFavTabRecipeCell Delegate Methods

- (void)favTabRecipeCell:(BVFavTabRecipeCell *)cell deleteViewActive:(BOOL)isActive
{
    if(isActive)
    {
        NSIndexPath *indexPathForNewCellWithActiveDeleteView = [mTableView indexPathForCell:cell];
        
        if(self.indexPathForCellWithActiveDeleteView)
        {
            
            if(indexPathForNewCellWithActiveDeleteView.row == self.indexPathForCellWithActiveDeleteView.row && indexPathForNewCellWithActiveDeleteView.section == self.indexPathForCellWithActiveDeleteView.section)
            {
                return;
            }
            else
            {
                BVFavTabRecipeCell *previousCellWithDeleteActive = (BVFavTabRecipeCell *)[mTableView cellForRowAtIndexPath:self.indexPathForCellWithActiveDeleteView];
                
                if(previousCellWithDeleteActive)
                {
                    [previousCellWithDeleteActive hideDeleteViewAnimated:YES];
                }
            }
        }
        
        
        self.indexPathForCellWithActiveDeleteView = indexPathForNewCellWithActiveDeleteView;
    }
    else
    {
        NSIndexPath *indexPathForCellWhoseDeleteButtonGotInActive = [mTableView indexPathForCell:cell];
        if(indexPathForCellWhoseDeleteButtonGotInActive.row == self.indexPathForCellWithActiveDeleteView.row && indexPathForCellWhoseDeleteButtonGotInActive.section == self.indexPathForCellWithActiveDeleteView.section)
        {
            self.indexPathForCellWithActiveDeleteView = nil;
        }
    }
}

- (void)favTabRecipeCellUserConfirmedDeletion:(BVFavTabRecipeCell *)cell
{
    NSIndexPath *indexPathForCell = [mTableView indexPathForCell:cell];
    if(indexPathForCell)
    {
        Recipe *recipeObject = [mTableData objectAtIndex:indexPathForCell.row];
        BVApp *app = [[DataManager sharedDataManager] app];
        [app removeFavoriteRecipesObject:recipeObject];
        [DataManager saveDatabaseOnMainThread];
        
        

        [mTableData removeObjectAtIndex:indexPathForCell.row];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationRecipeRemovedFromFavoriteFromFavoriteTab object:recipeObject]];
        
        if([mTableData count] == 0)
        {
            [self showInformativeMessageLabelWithMessage:kInformativeMessageForNoFavoriteRecipes];
        }
        else
        {
            [self hideInformativeMessageLabel];
        }
        
        
        // When after deleting a recipe only 1 row remains, then we see some unwanted viusal effects. Hence when only 1 row or 1 zeor rows remain after deleting, we reload the complete tableview.
        if([mTableData count] < 2)
        {
            [mTableView reloadData];
        }
        else
        {
            [mTableView beginUpdates];
            [mTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForCell] withRowAnimation:UITableViewRowAnimationAutomatic];
            [mTableView endUpdates];
        }
    }
}



#pragma mark - UIScrolView Delegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self ifDeleteViewIsActiveOnAnyCellThenHideItAnimated:YES];
}



#pragma mark -
#pragma mark NSNotification Methods

- (void)recipeAddedToFavorites:(NSNotification *)notification
{
    [self createDataForTableView];
    [mTableView reloadData];
    
    if([mTableData count] == 0)
    {
        [self showInformativeMessageLabelWithMessage:kInformativeMessageForNoFavoriteRecipes];
    }
    else
    {
        [self hideInformativeMessageLabel];
    }
}

- (void)recipeRemovedFromFavorites:(NSNotification *)notification
{
    [self createDataForTableView];
    [mTableView reloadData];
    
    if([mTableData count] == 0)
    {
        [self showInformativeMessageLabelWithMessage:kInformativeMessageForNoFavoriteRecipes];
    }
    else
    {
        [self hideInformativeMessageLabel];
    }
}



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
