//
//  BVAppDelegate.m
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVAppDelegate.h"
#import "BVHomeViewController.h"
#import "BVFlavorViewController.h"
#import "BVRecipeViewController.h"
#import "BVTopRatedViewController.h"
#import "BVFavoritesViewController.h"
#import "BVTabBarController.h"
#import "DataManager.h"
#import "Constants.h"
#import "UtilityManager.h"
#import "BVApp.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Flurry.h"
#import "NewServerFetchOperations.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "UtilityManager.h"


#define kMinimumDurationToShowLoadingScreen 0.0


static NSString *const kTrackingId = @"UA-24508531-2";


@interface BVAppDelegate ()


- (void)showTabBar;
- (void)configureTheApp;

@end


@implementation BVAppDelegate

- (void)dealloc
{
    [_ageGateController release];
    [_tabBarController release];
    [_window release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [super dealloc];
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize ageGateController = _ageGateController;

void myExceptionHandler(NSException *exception)
{
    NSArray *stack = [exception callStackReturnAddresses];
    NSLog(@"Stack trace: %@", stack);
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry startSession:@"X79GF5XK8MPQC8489Q44"];
    [GAI sharedInstance].dispatchInterval = 80;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithName:@"BurnettVodka"
                                              trackingId:kTrackingId];
    
    [self CheckDateGetFeatureRecipes];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    UIImage *navigationBarBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NavigationBarBackground" ofType:@"png"]];
    [[UINavigationBar appearance] setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefaultPrompt];
    
    //.size.height=65.0;
    [navigationBarBackgroundImage release];
    
     NSSetUncaughtExceptionHandler(&myExceptionHandler);
    if(kDisableAgeGateForDevelopment)
    {
        [self showTabBar];
    }
    else
    {
        self.ageGateController = [[[BVAgeGateViewController alloc] init] autorelease];
        self.ageGateController.controllerDelegate = self;
        self.window.rootViewController = self.ageGateController;
    }    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void) CheckDateGetFeatureRecipes {
    NSDate *newdate = [NSDate date];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"DateDict"]==NULL) {
        [self fetchRecipiesFromServer];
        NSMutableDictionary *dateDict = [[NSMutableDictionary alloc] init];
        [dateDict setObject:newdate forKey:@"NewDate"];
        [[NSUserDefaults standardUserDefaults] setObject:dateDict forKey:@"DateDict"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/featured_recipe.php", kAPIServerPathNew];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        request.timeOutSeconds = 30;
        request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
        [request startSynchronous];
        NSError *error = [request error];
        if (!error)
        {
            NSString *responseString = [request responseString];
            NSDictionary *responseDic = [responseString JSONValue];
            NSString *successString = [responseDic valueForKey:@"success"];
            if([[successString lowercaseString] isEqualToString:@"ok"])
            {
                NSString *temporaryFolderInFeaturedRecipesFolder = [UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]];
                NSString *filePathForJSONStringToBeStoredInTempFolder = [temporaryFolderInFeaturedRecipesFolder stringByAppendingPathComponent:kFileNameForFeaturedRecipesJSON];
                
                NSError *jsonFileWriteError = nil;
                BOOL jsonFileWriteSuccess = [responseString writeToFile:filePathForJSONStringToBeStoredInTempFolder atomically:YES encoding:4 error:&jsonFileWriteError];
                NSLog(@"%hhd",jsonFileWriteSuccess);
            }
            else
            {
                // NSString *errorMessage = [responseDic valueForKey:@"error"];
                // TODO: write error log
            }
        }
        else
        {
            NSDictionary *plistdic = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PropertyList" ofType:@"plist"]];
            NSString *pliststr = [plistdic objectForKey:urlString];
            NSDictionary *responseDic = [pliststr JSONValue];
            NSString *successString = [responseDic valueForKey:@"success"];
            if([[successString lowercaseString] isEqualToString:@"ok"])
            {
                NSString *temporaryFolderInFeaturedRecipesFolder = [UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]];
                NSString *filePathForJSONStringToBeStoredInTempFolder = [temporaryFolderInFeaturedRecipesFolder stringByAppendingPathComponent:kFileNameForFeaturedRecipesJSON];
                
                NSError *jsonFileWriteError = nil;
                BOOL jsonFileWriteSuccess = [pliststr writeToFile:filePathForJSONStringToBeStoredInTempFolder atomically:YES encoding:4 error:&jsonFileWriteError];
                NSLog(@"%hhd",jsonFileWriteSuccess);
            }
            else
            {
                // NSString *errorMessage = [responseDic valueForKey:@"error"];
                // TODO: write error log
            }
        }
        [request release];
        BOOL anyRecipeSetCompleted = [self checkAndCompleteARecipeSetFromTemporaryFolder];
        NSLog(@"%hhd",anyRecipeSetCompleted);
        [pool release];
    }
    else {
        
        NSMutableDictionary *OldDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"DateDict"];
        NSDate *olddte = [OldDate objectForKey:@"NewDate"];
        NSTimeInterval timeInterval =[newdate timeIntervalSinceDate:olddte];
        double timecal = (double)timeInterval;
        if (timecal>=172800) {
            [self fetchRecipiesFromServer];

            NSMutableDictionary *dateDict = [[NSMutableDictionary alloc] init];
            [dateDict setObject:newdate forKey:@"NewDate"];
            [[NSUserDefaults standardUserDefaults] setObject:dateDict forKey:@"DateDict"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            NSString *urlString = [NSString stringWithFormat:@"%@/featured_recipe.php", kAPIServerPathNew];
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
            request.timeOutSeconds = 30;
            request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
            [request startSynchronous];
            NSError *error = [request error];
            if (!error)
            {
                NSString *responseString = [request responseString];
                NSDictionary *responseDic = [responseString JSONValue];
                NSString *successString = [responseDic valueForKey:@"success"];
                if([[successString lowercaseString] isEqualToString:@"ok"])
                {
                    NSString *temporaryFolderInFeaturedRecipesFolder = [UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]];
                    
                    NSString *filePathForJSONStringToBeStoredInTempFolder = [temporaryFolderInFeaturedRecipesFolder stringByAppendingPathComponent:kFileNameForFeaturedRecipesJSON];
                    
                    NSError *jsonFileWriteError = nil;
                    BOOL jsonFileWriteSuccess = [responseString writeToFile:filePathForJSONStringToBeStoredInTempFolder atomically:YES encoding:4 error:&jsonFileWriteError];
                    NSLog(@"%hhd",jsonFileWriteSuccess);
                }
                else
                {
                    // NSString *errorMessage = [responseDic valueForKey:@"error"];
                    // TODO: write error log
                }
            }
            else
            {
                NSDictionary *plistdic = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PropertyList" ofType:@"plist"]];
                NSString *pliststr = [plistdic objectForKey:urlString];
                NSDictionary *responseDic = [pliststr JSONValue];
                NSString *successString = [responseDic valueForKey:@"success"];
                if([[successString lowercaseString] isEqualToString:@"ok"])
                {
                    NSString *temporaryFolderInFeaturedRecipesFolder = [UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]];
                    
                    NSString *filePathForJSONStringToBeStoredInTempFolder = [temporaryFolderInFeaturedRecipesFolder stringByAppendingPathComponent:kFileNameForFeaturedRecipesJSON];
                    
                    NSError *jsonFileWriteError = nil;
                    BOOL jsonFileWriteSuccess = [pliststr writeToFile:filePathForJSONStringToBeStoredInTempFolder atomically:YES encoding:4 error:&jsonFileWriteError];
                    NSLog(@"%hhd",jsonFileWriteSuccess);
                }
                else
                {
                    // NSString *errorMessage = [responseDic valueForKey:@"error"];
                    // TODO: write error log
                }
            }
            [request release];
            BOOL anyRecipeSetCompleted = [self checkAndCompleteARecipeSetFromTemporaryFolder];
            NSLog(@"%hhd",anyRecipeSetCompleted);
            [pool release];
        }
        else {
            
        }
    }
}

- (BOOL)checkAndCompleteARecipeSetFromTemporaryFolder
{
    BOOL success = YES;
    
    NSString *jsonFilePath = [[UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]] stringByAppendingPathComponent:kFileNameForFeaturedRecipesJSON];
    NSString *jsonString = [NSString stringWithContentsOfFile:jsonFilePath encoding:4 error:nil];
    id recipesArray = [[jsonString JSONValue] valueForKey:@"featured_recipes"];
    if(recipesArray && [recipesArray isKindOfClass:[NSArray class]])
    {
        NSMutableArray *arrayOfFilePathsToDownload = [[NSMutableArray alloc] init];
        for(NSDictionary *recipeDic in recipesArray)
        {
            NSString *imagePath = [recipeDic valueForKey:@"drink_image"];
            NSString *retinaVersionImagePath = [[[[[NSURL URLWithString:imagePath] URLByDeletingPathExtension] absoluteString] stringByAppendingString:@"@2x"] stringByAppendingFormat:@".%@", [imagePath pathExtension]];
            NSString *imagePath1 = [recipeDic valueForKey:@"recipeimage"];
            NSString *retinaVersionImagePath1 = [[[[[NSURL URLWithString:imagePath] URLByDeletingPathExtension] absoluteString] stringByAppendingString:@"@2x"] stringByAppendingFormat:@".%@", [imagePath pathExtension]];
            
            if(imagePath && retinaVersionImagePath)
            {
                [arrayOfFilePathsToDownload addObject:imagePath];
                [arrayOfFilePathsToDownload addObject:retinaVersionImagePath];
                [arrayOfFilePathsToDownload addObject:imagePath1];
                [arrayOfFilePathsToDownload addObject:retinaVersionImagePath1];
            }
            else
            {
                success = NO;
                break;
            }
        }
        if(success)
        {
            for(NSString *filePath in arrayOfFilePathsToDownload)
            {
                NSString *filePathToSaveTheImageTo = [[UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]] stringByAppendingPathComponent:[filePath lastPathComponent]];
                
                NSString *imageFileNameWithoutExtension = [filePathToSaveTheImageTo lastPathComponent];
                if (![[NewServerFetchOperations sharedManager] checkFileExistsLocallyWithFileName:imageFileNameWithoutExtension]) {
                    
                    if(![[NSFileManager defaultManager] fileExistsAtPath:filePathToSaveTheImageTo])
                    {
                        ASIHTTPRequest *fileDownloadRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:filePath]];
                        [fileDownloadRequest startSynchronous];
                        
                        NSError *error = [fileDownloadRequest error];
                        if (!error)
                        {
                            NSData *assetData = [fileDownloadRequest responseData];
                            if(assetData)
                            {
                                NSError *fileWriteError = nil;
                                BOOL fileWritesucces = [assetData writeToFile:filePathToSaveTheImageTo options:NSDataWritingFileProtectionNone error:&fileWriteError];
                                if(!fileWritesucces)
                                {
                                    // TODO: write error log
                                   // success = NO;
                                }
                            }
                            else
                            {
                                // TODO: write error log
                                //success = NO;
                            }
                        }
                        else
                        {
                            // TODO: write error log
                            //success = NO;
                        }
                    }
                }
            }
        }
        [arrayOfFilePathsToDownload release];
    }
    else
    {
        success = NO;
    }
    
    if(success)
    {
        // Before moving the items from Temporary Folder, we need to remove items from Featured Recipes Root Folder
        BOOL completeDeleteProcessSuccess = YES;
        NSArray *filePathsInFeaturedRecipesFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] error:nil];
        for(NSString *itemName in filePathsInFeaturedRecipesFolder)
        {
            if(![[itemName lowercaseString] isEqualToString:@"temp"])
            {
                NSString *filePathToDelete = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:itemName];
                BOOL deleteSuccess = [[NSFileManager defaultManager] removeItemAtPath:filePathToDelete error:nil];
                if(!deleteSuccess)
                {
                    completeDeleteProcessSuccess = NO;
                    break;
                }
            }
        }
        if(completeDeleteProcessSuccess)
        {
            BOOL completeShiftProcessSuccess = YES;
            
            // This means we have to transfer files from Temporary Folder To Featured Recipes Root Folder
            NSArray *filePathsInTemporaryFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]] error:nil];
            for(NSString *itemName in filePathsInTemporaryFolder)
            {
                NSString *filePathToMoveFrom = [[UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]] stringByAppendingPathComponent:itemName];
                NSString *filePathToMoveTo = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:itemName];
                BOOL shiftSuccess = [[NSFileManager defaultManager] moveItemAtPath:filePathToMoveFrom toPath:filePathToMoveTo error:nil];
                if(!shiftSuccess)
                {
                    completeShiftProcessSuccess = NO;
                    break;
                }
            }
            if(!completeShiftProcessSuccess)
            {
                success = NO;
            }
        }
        else
        {
            success = NO;
        }
    }
    return success;
}

- (void)updateAppStartupCount{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.appStartupCount = [standardUserDefaults integerForKey:@"startupcount"];
    self.appStartupCount++;
    [standardUserDefaults setInteger:self.appStartupCount forKey:@"startupcount"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSettings setDefaultAppID:@"587896904602773"];
    [FBAppEvents activateApp];
    if(_ageGateController == nil)
    {
        DebugLog(@"Inside Fetch Recipes");
        [[DataManager sharedDataManager] fetchRecipesRatingsFromServer];
        [self CheckDateGetFeatureRecipes];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BurnettVodka" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BurnettVodka.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Initial Loading Methods

- (void)showTabBar
{
    BVHomeViewController *viewController1 = [[BVHomeViewController alloc] init];
    
    UIImage *itemImage1 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TabBarHome" ofType:@"png"]];
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:nil image:itemImage1 tag:0];
    [itemImage1 release];
    viewController1.tabBarItem = item1;
    [item1 release];
    
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    [viewController1 release];
    navController1.navigationBarHidden = YES;
    
    BVFlavorViewController *viewController2 = [[BVFlavorViewController alloc] init];
    
    UIImage *itemImage2 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TabBarFlavors" ofType:@"png"]];
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:nil image:itemImage2 tag:0];
    [itemImage2 release];
    viewController2.tabBarItem = item2;
    [item2 release];
    
    UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    [viewController2 release];
    
    BVRecipeViewController *viewController3 = [[BVRecipeViewController alloc] init];
    
    UIImage *itemImage3 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TabBarRecipes" ofType:@"png"]];
    UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:nil image:itemImage3 tag:0];
    [itemImage3 release];
    viewController3.tabBarItem = item3;
    [item3 release];
    
    UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    [viewController3 release];
    
    BVTopRatedViewController *viewController4 = [[BVTopRatedViewController alloc] init];
    
    UIImage *itemImage4 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TabBarTopRated" ofType:@"png"]];
    UITabBarItem *item4 = [[UITabBarItem alloc] initWithTitle:nil image:itemImage4 tag:0];
    [itemImage4 release];
    viewController4.tabBarItem = item4;
    [item4 release];
    
    UINavigationController *navController4 = [[UINavigationController alloc] initWithRootViewController:viewController4];
    [viewController4 release];
    
    BVFavoritesViewController *viewController5 = [[BVFavoritesViewController alloc] init];
    
    UIImage *itemImage5 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TabBarMyFav" ofType:@"png"]];
    UITabBarItem *item5 = [[UITabBarItem alloc] initWithTitle:nil image:itemImage5 tag:0];
    [itemImage5 release];
    viewController5.tabBarItem = item5;
    [item5 release];
    
    UINavigationController *navController5 = [[UINavigationController alloc] initWithRootViewController:viewController5];
    [viewController5 release];
    
    self.tabBarController = [[[BVTabBarController alloc] initWithViewControllers:[NSArray arrayWithObjects:navController1, navController2, navController3, navController4, navController5, nil]] autorelease];
    
    [self.tabBarController showLoadingScreenAnimated:NO];
    
    [navController1 release];
    [navController2 release];
    [navController3 release];
    [navController4 release];
    [navController5 release];

    self.window.rootViewController = self.tabBarController;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        
        [self configureTheApp];
    });
}

- (void)configureTheApp
{
    NSTimeInterval timeStampBeforeTasks = [[NSDate date] timeIntervalSinceReferenceDate];
    NSTimeInterval timeStampeAfterTasks = [[NSDate date] timeIntervalSinceReferenceDate];
    
    NSTimeInterval difference = timeStampeAfterTasks - timeStampBeforeTasks;
    if(difference > kMinimumDurationToShowLoadingScreen)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [self.tabBarController hideLoadingScreenAnimated:YES];
        });
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (kMinimumDurationToShowLoadingScreen - difference) * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [self.tabBarController hideLoadingScreenAnimated:YES];
        });
    }
}

#pragma mark - BVAgeGateViewController Delegate Methods

- (void)userDeterminedAsLegalOnBVAgeGateViewController:(BVAgeGateViewController *)controller
{
    [self showTabBar];
    
    [[DataManager sharedDataManager] fetchRecipesRatingsFromServer];
    [[DataManager sharedDataManager] fetchLaterAppVersionAvailableFromServer];
    
    _ageGateController.controllerDelegate = nil;
    [_ageGateController release];
    _ageGateController = nil;
}

#pragma mark - Fetch Recipies From Server

- (void)fetchRecipiesFromServer{
    [self managedObjectContext];
    [self deleteAllObjects:@"Flavor"];
    [self deleteAllObjects:@"Recipe"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
    
    NSLog(@"files array %@", filePathsArray);
    [[NewServerFetchOperations sharedManager] fetchLatestFlavors];
}

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    
    for (NSManagedObject *managedObject in items) {
    	[_managedObjectContext deleteObject:managedObject];
    	DebugLog(@"%@ object deleted",entityDescription);
    }
    if (![_managedObjectContext save:&error]) {
    	DebugLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
}

@end
