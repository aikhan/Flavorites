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
    
#ifdef DEBUG
   // [Flurry setLogLevel:FlurryLogLevelAll];
#endif
    //Olf Flurry ID
    //[Flurry startSession:@"WX88JJD4DMS6PBS83JD2"];
    [self fetchRecipiesFromServer];
    [Flurry startSession:@"X79GF5XK8MPQC8489Q44"];
    //Google Analytics Code
    // Initialize Google Analytics with a 120-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].dispatchInterval = 80;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithName:@"BurnettVodka"
                                              trackingId:kTrackingId];
    
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    // Change the appearance of UINavigationBar Application Wide
    UIImage *navigationBarBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NavigationBarBackground" ofType:@"png"]];
    [[UINavigationBar appearance] setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
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


- (void)updateAppStartupCount{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.appStartupCount = [standardUserDefaults integerForKey:@"startupcount"];
    self.appStartupCount++;
    [standardUserDefaults setInteger:self.appStartupCount forKey:@"startupcount"];
}

#pragma mark -
#pragma mark
/*
+ (NSString *) publisherId: (id) theWidget{
    return @"";
}

+ (void) initialize {
    [super initialize];
    [JTAdWidget initializeAdService:YES];
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if (url == nil) {
        return NO;
    }
    
    [JumpTapAppReport handleApplicationLaunchUrl:url];
    return YES;
}
- (void) doJumptapReport {
    [JumpTapAppReport submitReportWithExtraInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"Bootup", @"event",    // the conversion type
                                                  nil, nil
                                                  ]
     ];
}
 */
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSettings setDefaultAppID:@"587896904602773"];
    [FBAppEvents activateApp];
    
    
    if(_ageGateController == nil)
    {
        DebugLog(@"Inside Fetch Recipes");
        [[DataManager sharedDataManager] fetchRecipesRatingsFromServer];
        //[[DataManager sharedDataManager] fetchFeaturedRecipesDataFromServer];
        
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];

}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
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

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BurnettVodka" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BurnettVodka.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
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
    
    
    
   // [[DataManager sharedDataManager] checkAndRepairAppData];
    
    
    
    
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
//    [[DataManager sharedDataManager] fetchFeaturedRecipesDataFromServer];
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
    //[[DataManager sharedDataManager] checkAndRepairAppData];
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
