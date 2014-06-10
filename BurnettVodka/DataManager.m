//
//  DataManager.m
//  BurnettVodka
//
//  Created by admin on 6/30/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "DataManager.h"
#import "BVAppDelegate.h"
#import "CHCSVParser.h"
#import "Recipe.h"
#import "Flavor.h"
#import "BVApp.h"
#import "BVAppDelegate.h"
#import "UtilityManager.h"
#import "Constants.h"
#import "JSON.h"


#define kAlertViewAppUpdateAvailable 1


static DataManager *sharedDataManager = nil;




@interface DataManager ()

- (NSArray *)fetchAllFlavorsFromCoreData;

- (NSArray *)fetchAllRecipesFromCoreData;

- (BVApp *)fetchAppObjectFromCoreData;

- (void)repairCoreDataForFlavorsAndRecipes;

@end





@implementation DataManager


+ (DataManager *)sharedDataManager
{
    @synchronized(self) {
        if (sharedDataManager == nil) {
            [[self alloc] init];
        }
    }
    return sharedDataManager;
}


+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedDataManager == nil) {
            return [super allocWithZone:zone];
        }
    }
    return sharedDataManager;
}


- (id)init
{
    Class myClass = [self class];
    @synchronized(myClass) {
        if (sharedDataManager == nil) {
            if (self = [super init]) {
                sharedDataManager = self;
                // custom initialization here
                
                _operationQueue = [[NSOperationQueue alloc] init];
                _operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
            }
        }
    }
    return sharedDataManager;
}


- (id)copyWithZone:(NSZone *)zone { return self; }


- (id)retain { return self; }


- (unsigned)retainCount { return UINT_MAX; }


- (oneway void) release {}


- (id)autorelease { return self; }





#pragma mark - Private CoreData Methods


- (NSArray *)fetchAllFlavorsFromCoreData
{    
    NSManagedObjectContext *context = [(BVAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Flavor" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"recipes", nil]];
    
	NSError *error = nil;
    NSArray *resultArray = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    if(error)
    {
        NSLog(@"Error: There was an error trying to fetch the Flavor objects from the database: %@", error);
    }
    
    if([resultArray count] == 0 || resultArray == nil)
    {
        return nil;
    }
    
    return resultArray;
}

- (NSArray *)fetchAllRecipesFromCoreData
{
    NSManagedObjectContext *context = [(BVAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipe" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"flavor", nil]];
    
	NSError *error = nil;
    NSArray *resultArray = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    if(error)
    {
        NSLog(@"Error: There was an error trying to fetch the Recipe objects from the database: %@", error);
    }
    
    if([resultArray count] == 0 || resultArray == nil)
    {
        return nil;
    }
    
    return resultArray;
}

- (BVApp *)fetchAppObjectFromCoreData
{
    BVApp *app = nil;
    
    NSManagedObjectContext *context = [DataManager managedObjectContextOnMainThread];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BVApp" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"favoriteRecipes", nil]];
    
	NSError *error = nil;
    NSArray *resultArray = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    if(error)
    {
        NSLog(@"Erro: There was an error trying to fetch the FDApp object from the database: %@", error);
    }
    else if([resultArray count] == 1)
    {
        app = [resultArray objectAtIndex:0];
    }
    else if([resultArray count] == 0 || resultArray == nil)
    {
        // Create an object for FDAppOwner
        app = (BVApp *)[NSEntityDescription insertNewObjectForEntityForName:@"BVApp" inManagedObjectContext:context];
        
        // Caution: The following line is a special case for FDAppOwner. Dont follow this approach for any other entity unless you are sure of what you are doing
        [DataManager saveDatabaseOnMainThread];
    }
    else if([resultArray count] > 1)
    {
        app = [resultArray objectAtIndex:0];
        
        NSLog(@"Error: While trying to fetch BVApp from database, we have found more than 1 object for BVApp which is something that should not happen.");
    }
    
    return app;
}




- (void)repairCoreDataForFlavorsAndRecipes
{
    
    DebugLog(@"%s", __PRETTY_FUNCTION__);
    return;
    // Fetch Array Of Recipes In Current CSV File
    NSDictionary *recipesCSVFilesInfoDicFromDisk = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeFilesInfo" ofType:@"plist"]];
    NSString *latestVersion = [NSString stringWithString:[recipesCSVFilesInfoDicFromDisk valueForKey:@"latest_version"]];
    NSString *originalLatestVersion = latestVersion;
    if([latestVersion intValue] > 3){
        latestVersion = @"3";
    }
    NSString *nameOfRecipeFile = [[recipesCSVFilesInfoDicFromDisk valueForKey:@"files"] valueForKey:latestVersion];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[nameOfRecipeFile stringByDeletingPathExtension]  ofType:[nameOfRecipeFile pathExtension]];
    NSArray *rawDataInCurrentCSVFile = [NSArray arrayWithContentsOfCSVFile:filePath];
    [recipesCSVFilesInfoDicFromDisk release];
    if([rawDataInCurrentCSVFile count] <= 0)
    {
        return;
    }
    
    
    // Prepare the data from CSV into usable format and filter out flavored vodka's
    
    NSMutableArray *usableRowsFromSCVFile = [[NSMutableArray alloc] init];
    
    NSArray *columnNamesFromCSVFile = [rawDataInCurrentCSVFile objectAtIndex:0];
    
    for(int i=1; i<[rawDataInCurrentCSVFile count]; i++)
    {
        NSArray *rowContentColumnWise = [rawDataInCurrentCSVFile objectAtIndex:i];
        NSMutableDictionary *rowDic = [[NSMutableDictionary alloc] init];
        
        for(int j=0; j<[rowContentColumnWise count]; j++)
        {
            if(j < [columnNamesFromCSVFile count])
            {
                NSString *keyName = [columnNamesFromCSVFile objectAtIndex:j];
                NSString *cellString = [rowContentColumnWise objectAtIndex:j];
                
                if([keyName isEqualToString:@"Drink Name"])
                    cellString = [[[[[cellString stringByReplacingOccurrencesOfString:@"burnett's" withString:@""] stringByReplacingOccurrencesOfString:@"Burnett's" withString:@""] stringByReplacingOccurrencesOfString:@"burnett" withString:@""] stringByReplacingOccurrencesOfString:@"Burnett" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if(keyName && cellString)
                {
                    NSString *processedCellString = [UtilityManager stringBystrippngUwantedSpaceAndInvertedCommasInString:cellString];
                    [rowDic setValue:processedCellString forKey:keyName];
                }
            }
        }
        
        NSString *recipeTitle = [rowDic valueForKey:@"Drink Name"];  
        NSString *recipeImage = [rowDic valueForKey:@"image"];        
        NSString *ingredients = [rowDic valueForKey:@"Ingredients"];        
        NSString *directions = [rowDic valueForKey:@"Directions"];        
        NSString *flavorName = [rowDic valueForKey:@"Product"];
        NSString *category = [rowDic valueForKey:@"Category"];
        
        if([category isEqualToString:@"Flavored Vodkas"])
        {
           if(recipeTitle && recipeImage && ingredients && directions && flavorName && category)
           {
               [usableRowsFromSCVFile addObject:rowDic];
           }
           else
           {
               NSMutableString *errorString = [[NSMutableString alloc] initWithString:@"\nInfo Missing In Row:"];
               [errorString appendFormat:@"\nDrink Name: %@", recipeTitle];
               [errorString appendFormat:@"\nimage: %@", recipeImage];
               [errorString appendFormat:@"\nIngredients: %@", ingredients];
               [errorString appendFormat:@"\nDirections: %@", directions];
               [errorString appendFormat:@"\nProduct: %@", flavorName];
               [errorString appendFormat:@"\nCategory: %@", category];
               NSLog(@"%@", errorString);
               [errorString release];
           }
        }

        [rowDic release];
    }
    
    
    
    // Test the CSV file data for Duplicate Recipe ID presence. Each row should have a unique RecipeID
    NSMutableDictionary *duplicateTestMap = [[NSMutableDictionary alloc] init];
    for(NSDictionary *rowDic in usableRowsFromSCVFile)
    {
        NSString *recipeID = [rowDic valueForKey:@"ID"];
        
        if([[duplicateTestMap valueForKey:recipeID] boolValue])
        {
            // Duplicate RecipeID Found.
            // TODO: Write a NSAssert Statement
            break;
        }
        else
        {
            [duplicateTestMap setValue:[NSNumber numberWithBool:YES] forKey:recipeID];
        }
    }
    [duplicateTestMap release];
    
  
    
    
    
    
    
    
    
    
    
    
    
    
    // Fetch the flavors data from disk
    
    NSDictionary *flavorsFilesInfoDicFromDisk = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FlavorFilesInfo" ofType:@"plist"]];
    NSString *latestVersionOfFlavorFile = [NSString stringWithString:[flavorsFilesInfoDicFromDisk valueForKey:@"latest_version"]];
    NSString *originalLatestVersionOfFlavorFile = latestVersionOfFlavorFile;
    if([latestVersionOfFlavorFile intValue] > 1){
        latestVersionOfFlavorFile = @"1";
    }
    NSString *nameOfFlavorFile = [[flavorsFilesInfoDicFromDisk valueForKey:@"files"] valueForKey:latestVersionOfFlavorFile];
    NSString *filePathForFlavorFile = [[NSBundle mainBundle] pathForResource:[nameOfFlavorFile stringByDeletingPathExtension]  ofType:[nameOfFlavorFile pathExtension]];
    NSArray *flavorDataFromDisk = [[NSDictionary dictionaryWithContentsOfFile:filePathForFlavorFile] valueForKey:@"Flavors_Array"];
    [flavorsFilesInfoDicFromDisk release];
    
    
    // Test the flavor file data for Duplicate Flavor Name presence. Each row should have a unique flavor name
    NSMutableDictionary *duplicateTestMapForFlavors = [[NSMutableDictionary alloc] init];
    for(NSDictionary *rowDic in flavorDataFromDisk)
    {
        NSString *flavorName = [rowDic valueForKey:@"title"];
        
        if([[duplicateTestMapForFlavors valueForKey:flavorName] boolValue])
        {
            // Duplicate RecipeID Found.
            // TODO: Write a NSAssert Statement
            break;
        }
        else
        {
            [duplicateTestMapForFlavors setValue:[NSNumber numberWithBool:YES] forKey:flavorName];
        }
    }
    [duplicateTestMapForFlavors release];
    
    
    
    
    
    
    
    // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    // From here onwards, we are clear that we have a consistent Recipe and Flavor Data
    
    
    // Process FLAVOR DATA first
    NSArray *existingFlavorsArrayInCoreData = [self fetchAllFlavorsFromCoreData];
    NSMutableDictionary *mapOfExistingFlavorObjectsFromCoreData = [[NSMutableDictionary alloc] init];
    for(Flavor *flavorObject in existingFlavorsArrayInCoreData)
    {
        if(flavorObject.title)
        {
            [mapOfExistingFlavorObjectsFromCoreData setValue:flavorObject forKey:flavorObject.title];
        }
        else
        {
            [[DataManager managedObjectContextOnMainThread] deleteObject:flavorObject];
        }
    }
    
    
    NSMutableDictionary *mapOfLatestFlavorObjectsInCoreData = [[NSMutableDictionary alloc] init];
    for(NSDictionary *flavorDic in flavorDataFromDisk)
    {
        NSString *flavorName = [flavorDic valueForKey:@"title"];
        if(flavorName)
        {
            Flavor *flavorObject = [mapOfExistingFlavorObjectsFromCoreData valueForKey:flavorName];
            if(flavorObject == nil)
            {
                flavorObject = (Flavor *)[NSEntityDescription insertNewObjectForEntityForName:@"Flavor" inManagedObjectContext:[DataManager managedObjectContextOnMainThread]];
                flavorObject.title = flavorName;
            }
            else
            {
                [mapOfExistingFlavorObjectsFromCoreData setValue:nil forKey:flavorName];
            }
            
            // Update the imageName from the latest flavor data on disk
            flavorObject.imageName = [flavorDic valueForKey:@"image_file_name"];
            
            // Unlink all the Recipe Objects from the Flavor Object as the links will again be built.
            NSArray *allLinkedRecipeObjects = [flavorObject.recipes allObjects];
            for(Recipe *recipeObject in allLinkedRecipeObjects)
            {
                [flavorObject removeRecipesObject:recipeObject];
            }
            
            [mapOfLatestFlavorObjectsInCoreData setValue:flavorObject forKey:flavorName];
        }
    }
    
    
    // All the Flavor Objects that remain in mapOfExistingFlavorObjectsFromCoreData needs to be deleted because they were not present in the latest flavors data file
    NSArray *allFlavorObjectsNotPresentInLatestFlavorDataFile = [mapOfExistingFlavorObjectsFromCoreData allValues];
    for(Flavor *flavorObject in allFlavorObjectsNotPresentInLatestFlavorDataFile)
    {
        [[DataManager managedObjectContextOnMainThread] deleteObject:flavorObject];
    }
    
    [mapOfExistingFlavorObjectsFromCoreData release];
    
    
    
    
    
    
    
    
    // Now Process RECIPE DATA
    
    NSArray *existingRecipesArrayInCoreData = [self fetchAllRecipesFromCoreData];
    NSMutableDictionary *mapOfExistingRecipeObjectsFromCoreData = [[NSMutableDictionary alloc] init];
    for(Recipe *recipeObject in existingRecipesArrayInCoreData)
    {
        if(recipeObject.recipeID)
        {
            [mapOfExistingRecipeObjectsFromCoreData setValue:recipeObject forKey:[NSString stringWithFormat:@"%@", recipeObject.recipeID]];
        }
        else
        {
            [[DataManager managedObjectContextOnMainThread] deleteObject:recipeObject];
        }
    }
    
    NSMutableDictionary *mapOfLatestRecipeObjectsInCoreData = [[NSMutableDictionary alloc] init];
    for(NSDictionary *recipeDic in usableRowsFromSCVFile)
    {
        NSString *recipeID = [recipeDic valueForKey:@"ID"];
        if(recipeID)
        {
            NSString *flavorName = [recipeDic valueForKey:@"Product"];
            NSString *recipeTitle = [recipeDic valueForKey:@"Drink Name"];
            
            Flavor *flavorObject = [mapOfLatestFlavorObjectsInCoreData valueForKey:flavorName];
            if(flavorObject == nil)
            {
                // TODO: Write a NSAssert Statement
                NSLog(@"Flavor not found with name: %@ for recipe: %@", flavorName, recipeTitle);
            }
            else
            {
                Recipe *recipeObject = [mapOfExistingRecipeObjectsFromCoreData valueForKey:recipeID];
                if(recipeObject == nil)
                {
                    recipeObject = (Recipe *)[NSEntityDescription insertNewObjectForEntityForName:@"Recipe" inManagedObjectContext:[DataManager managedObjectContextOnMainThread]];
                    recipeObject.recipeID = [NSNumber numberWithInteger:[recipeID integerValue]];
                }
                else
                {
                    [mapOfExistingRecipeObjectsFromCoreData setValue:nil forKey:recipeID];
                }
                
                // Update latest data from file on disk
                recipeObject.title = recipeTitle;
                
                NSString *recipeImage = [recipeDic valueForKey:@"image"];
                recipeObject.imageName = recipeImage;
                
                NSString *ingredients = [recipeDic valueForKey:@"Ingredients"];
                recipeObject.ingredients = ingredients;
                
                NSString *directions = [recipeDic valueForKey:@"Directions"];
                recipeObject.directions = directions;
                
                recipeObject.flavor = flavorObject;
                
                [mapOfLatestRecipeObjectsInCoreData setValue:recipeObject forKey:recipeID];
            }
        }
    }
    
    // All the Recipe Objects that remain in mapOfExistingRecipeObjectsFromCoreData needs to be deleted because they were not present in the latest recipes data file
    NSArray *allRecipeObjectsNotPresentInLatestRecipeDataFile = [mapOfExistingRecipeObjectsFromCoreData allValues];
    for(Recipe *recipeObject in allRecipeObjectsNotPresentInLatestRecipeDataFile)
    {
        [[DataManager managedObjectContextOnMainThread] deleteObject:recipeObject];
    }
    
    [mapOfExistingRecipeObjectsFromCoreData release];
    
    
    
    
    
    
    // Update the version numbers of the latest files being used
    BVApp *app = [[DataManager sharedDataManager] app];
    app.currentVersionOfFlavorData = originalLatestVersionOfFlavorFile;
    app.currentVersionOfRecipeData = originalLatestVersion;
    
    

    
    // Commit the changes in the database.
    [DataManager saveDatabaseOnMainThread];
    
    
    // Clean Up
    [usableRowsFromSCVFile release];
    [mapOfLatestRecipeObjectsInCoreData release];
    [mapOfLatestFlavorObjectsInCoreData release];
}



#pragma mark - Public Methods

+ (NSManagedObjectContext *)managedObjectContextOnMainThread
{
    return [(BVAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

+ (void)saveDatabaseOnMainThread
{
    [(BVAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}




- (BVApp *)app
{
    if(_app == nil)
    {
        _app = [[self fetchAppObjectFromCoreData] retain];
    }
        
    return _app;
}




- (NSArray *)mixersGetAllMixers
{
    if(_allMixersArray == nil)
    {
        NSDictionary *mixersDicFromDisk = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Mixers" ofType:@"plist"]];
        _allMixersArray = [[NSArray arrayWithArray:[mixersDicFromDisk valueForKey:@"mixers"]] retain];
        [mixersDicFromDisk release];
    }
    
    return _allMixersArray;
}


- (NSArray *)flavorsGetAllFlavors
{
    if(_allFlavorsArray == nil)
    {
        _allFlavorsArray = [[self fetchAllFlavorsFromCoreData] retain];
        
        if(_allFlavorsArray == nil)
        {
            [self repairCoreDataForFlavorsAndRecipes];
            _allFlavorsArray = [[self fetchAllFlavorsFromCoreData] retain];
        }
    }
    
    return _allFlavorsArray;
}

- (Flavor *)flavorsGetFlavorWithFlavorTitle:(NSString *)flavorTitle
{
    Flavor *flavorObject = nil;
    
    NSArray *allFlavors = [self flavorsGetAllFlavors];
    for(Flavor *flavorObjectInArray in allFlavors)
    {
        if([[flavorObjectInArray.title lowercaseString] isEqualToString:[flavorTitle lowercaseString]])
        {
            flavorObject = flavorObjectInArray;
            break;
        }
    }
    
    return flavorObject;
}

- (BOOL)flavorsIsThisANewFlavor:(Flavor *)flavor
{
    if(_allFlavorTitlesToBeTaggedNew == nil)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"NewFlavorsTaggingInfo" ofType:@"plist"];
        NSDictionary *fileDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSArray *newFlavorsArray = [fileDic valueForKey:@"FlavorsToBeTaggedNew"];
        _allFlavorTitlesToBeTaggedNew = [[NSArray alloc] initWithArray:newFlavorsArray];
    }
    
    BOOL isNew = NO;
    
    for(NSString *flavorTitleInPlist in _allFlavorTitlesToBeTaggedNew)
    {
        if([[flavorTitleInPlist lowercaseString] isEqualToString:[flavor.title lowercaseString]])
        {
            isNew = YES;
            break;
        }
    }
    
    return isNew;
}

- (NSArray *)recipesGetAllRecipes
{
    if(_allRecipesArray == nil)
    {
        _allRecipesArray = [[self fetchAllRecipesFromCoreData] retain];
        
        if(_allRecipesArray == nil)
        {
            [self repairCoreDataForFlavorsAndRecipes];
            _allRecipesArray = [[self fetchAllRecipesFromCoreData] retain];
        }
    }
    
    return _allRecipesArray;
}

- (Recipe *)recipesGetRecipeWithRecipeID:(NSInteger)recipeID
{
    Recipe *recipe = nil;
    
    NSArray *allRecipes = [self recipesGetAllRecipes];
    for(Recipe *recipeObjectInArray in allRecipes)
    {
        if([recipeObjectInArray.recipeID integerValue] == recipeID)
        {
            recipe = recipeObjectInArray;
            break;
        }
    }
    
    return recipe;
}
#pragma mark - New Methods Assad
- (Flavor *)flavorsGetFlavorWithFlavorID:(NSInteger)flavorID
{
    Flavor *flavor = nil;
    
    NSArray *allFlavors = [self flavorsGetAllFlavors];
    for(Flavor *flavorObjectInArray in allFlavors)
    {
        if([flavorObjectInArray.flavorID integerValue] == flavorID)
        {
            flavor = flavorObjectInArray;
            break;
        }
    }
    
    return flavor;
}

- (void)checkAndRepairAppData
{
    BVApp *app = [self app];
    
    BOOL doWeNeedToRepairData = NO;
    NSAssert(NO, @"Data should not be rebuilt from local database");
    
    // Condition 1
    if(!doWeNeedToRepairData)
    {
        NSDictionary *recipesCSVFilesInfoDicFromDisk = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeFilesInfo" ofType:@"plist"]];
        NSString *latestVersionOfRecipeDataAvailable = [recipesCSVFilesInfoDicFromDisk valueForKey:@"latest_version"];
        if([latestVersionOfRecipeDataAvailable floatValue] > [app.currentVersionOfRecipeData floatValue])
        {
            doWeNeedToRepairData = YES;
        }
        [recipesCSVFilesInfoDicFromDisk release];
    }
    
    
    // Condition 2
    if(!doWeNeedToRepairData)
    {
        NSDictionary *flavorsFilesInfoDicFromDisk = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FlavorFilesInfo" ofType:@"plist"]];
        NSString *latestVersionOfFlavorFile = [flavorsFilesInfoDicFromDisk valueForKey:@"latest_version"];
        if([latestVersionOfFlavorFile floatValue] > [app.currentVersionOfFlavorData floatValue])
        {
            doWeNeedToRepairData = YES;
        }
        [flavorsFilesInfoDicFromDisk release];
    }
    
    
    
    // Condition 3
    if(!doWeNeedToRepairData)
    {
        if([[self flavorsGetAllFlavors] count] <= 0)
        {
            doWeNeedToRepairData = YES;
        }
    }
    
    
    // Condition 4
    if(!doWeNeedToRepairData)
    {
        if([[self recipesGetAllRecipes] count] <= 0)
        {
            doWeNeedToRepairData = YES;
        }
    }
    
    
    if(doWeNeedToRepairData)
        [self repairCoreDataForFlavorsAndRecipes];
}






- (void)fetchRecipesRatingsFromServer
{
    BOOL doesThisAlreadyExistInQueue = NO;
    
    NSArray *operationsArray = [_operationQueue operations];
    for(NSOperation *operation in operationsArray)
    {
        if([operation isKindOfClass:[BVFetchRatingsOperation class]])
        {
            doesThisAlreadyExistInQueue = YES;
            break;
        }
    }
    
    if(!doesThisAlreadyExistInQueue)
    {
        BVFetchRatingsOperation *operation = [[BVFetchRatingsOperation alloc] init];
        operation.operationDelegate = self;
        [_operationQueue addOperation:operation];
        [operation release];
    }
}


- (void)fetchFeaturedRecipesDataFromServer
{
    BOOL doesThisAlreadyExistInQueue = NO;
    
    NSArray *operationsArray = [_operationQueue operations];
    for(NSOperation *operation in operationsArray)
    {
        if([operation isKindOfClass:[BVFetchFeaturedRecipesOperation class]])
        {
            doesThisAlreadyExistInQueue = YES;
            break;
        }
    }
    
    if(!doesThisAlreadyExistInQueue)
    {
        BVFetchFeaturedRecipesOperation *operation = [[BVFetchFeaturedRecipesOperation alloc] init];
        operation.operationDelegate = self;
        [_operationQueue addOperation:operation];
        [operation release];
    }
}


- (void)fetchLaterAppVersionAvailableFromServer
{
    BOOL doesThisAlreadyExistInQueue = NO;
    
    NSArray *operationsArray = [_operationQueue operations];
    for(NSOperation *operation in operationsArray)
    {
        if([operation isKindOfClass:[BVCheckAppUpdateOperation class]])
        {
            doesThisAlreadyExistInQueue = YES;
            break;
        }
    }
    
    if(!doesThisAlreadyExistInQueue)
    {
        BVCheckAppUpdateOperation *operation = [[BVCheckAppUpdateOperation alloc] init];
        operation.operationDelegate = self;
        [_operationQueue addOperation:operation];
        [operation release];
    }
}











- (NSArray *)featuredRecipesLatest
{
    NSArray *featureRecipes = nil;
    
    NSString *folderPathForFeaturedRecipes = [UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData];
    NSString *filePath = [folderPathForFeaturedRecipes stringByAppendingPathComponent:kFileNameForFeaturedRecipesJSON];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSString *jsonString = [NSString stringWithContentsOfFile:filePath encoding:4 error:nil];
        featureRecipes = [[jsonString JSONValue] valueForKey:@"featured_recipes"];
        if(featureRecipes)
        {
            for(NSDictionary *recipeDic in featureRecipes)
            {
                NSString *imagePath = [recipeDic valueForKey:@"imagePath"];
                NSString *filePathInLocalSystem = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:[imagePath lastPathComponent]];
                if(![[NSFileManager defaultManager] fileExistsAtPath:filePathInLocalSystem])
                {
                    //TODO: write statement here to delete all files in the featured recipe foleder as one of the images missing
                    featureRecipes = nil;
                    break;
                }
            }
        }
        else
        {
            //TODO: write statement here to delete all files in the featured recipe foleder as the JSON is not readable
        }
    }

    return featureRecipes;
}

- (NSArray *)featuredRecipesDefault
{
    NSString *jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[kFileNameForFeaturedRecipesJSON stringByDeletingPathExtension] ofType:[kFileNameForFeaturedRecipesJSON pathExtension]] encoding:4 error:nil];
    NSArray *defaultFeaturedRecipes = [[jsonString JSONValue] valueForKey:@"featured_recipes"];
    return defaultFeaturedRecipes;
}






#pragma mark - BVFetchRatingsOperation Delegate Methods

- (void)fetchRatingsOperation:(BVFetchRatingsOperation *)operation didFinishedDownloadingRatingsForRecipes:(NSArray *)recipesArrayWithRatings
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *arrayRecipeObjectsForWhichRatingHasChanged = [[NSMutableArray alloc] init];
        
        NSArray *allRecipes = [self recipesGetAllRecipes];
        NSMutableDictionary *mapOfAllRecipes = [[NSMutableDictionary alloc] init];
        
        for(Recipe *recipeObject in allRecipes)
        {
            NSString *recipeIDString = [NSString stringWithFormat:@"%@", recipeObject.recipeID];
            [mapOfAllRecipes setValue:recipeObject forKey:recipeIDString];
        }
        
        for(NSDictionary *recipeDic in recipesArrayWithRatings)
        {
            NSNumber *recipeIDNumber = nil;
            
            id recipeIDObjectInDic = [recipeDic valueForKey:@"recipe_id"];
            if(recipeIDObjectInDic && ![recipeIDObjectInDic isKindOfClass:[NSNull class]])
            {
                recipeIDNumber = [NSNumber numberWithInteger:[recipeIDObjectInDic integerValue]];
            }
            else
            {
                continue;
            }
            
            
            NSNumber *numberOfSubmissionsNumber = nil;
            
            id numberOfSubmissionsObjectInDic = [recipeDic valueForKey:@"finalTotalNumOfSubmission"];
            if(numberOfSubmissionsObjectInDic && ![numberOfSubmissionsObjectInDic isKindOfClass:[NSNull class]])
            {
                numberOfSubmissionsNumber = [NSNumber numberWithInteger:[numberOfSubmissionsObjectInDic integerValue]];
            }
            
            
            
            NSNumber *averageRatingNumber = nil;
            
            id averageRatingObjectInDic = [recipeDic valueForKey:@"finalAverageRating"];
            if(averageRatingObjectInDic && ![averageRatingObjectInDic isKindOfClass:[NSNull class]])
            {
                averageRatingNumber = [NSNumber numberWithFloat:[averageRatingObjectInDic floatValue]];
            }
            
            
            Recipe *recipeObject = [mapOfAllRecipes valueForKey:[NSString stringWithFormat:@"%@", recipeIDNumber]];
            if(recipeObject)
            {
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
                
                
                if(hasAnythingChanged)
                {
                    [arrayRecipeObjectsForWhichRatingHasChanged addObject:recipeObject];
                }
            }
        }
        
        [DataManager saveDatabaseOnMainThread];
        
        [mapOfAllRecipes release];
        
        NSArray *nonMutableArrayOfRecipesWhichChanged = [NSArray arrayWithArray:arrayRecipeObjectsForWhichRatingHasChanged];
        [arrayRecipeObjectsForWhichRatingHasChanged release];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationRecipeRatingsChanged object:nonMutableArrayOfRecipesWhichChanged]];
    });
}







#pragma mark - BVFetchFeaturedRecipesOperation Delegate Methods



- (void)fetchFeaturedRecipesOperation:(BVFetchFeaturedRecipesOperation *)operation didFinishFetchOperationWithANewRecipeReady:(BOOL)anyNewRecipeSetAvailable
{
    if(anyNewRecipeSetAvailable)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationNewFeaturedRecipesDownloaded object:nil]];
        });
        
    }
}




#pragma mark - BVCheckAppUpdateOperation Delegate Methods

- (void)checkAppUpdateOperation:(BVCheckAppUpdateOperation *)operation didFinishCheckingAppUpdateWithAppUpdateAvailable:(BOOL)appUpdateAvailable andAppstoreURLString:(NSString *)appStoreURLString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_appstoreURLForTheApp release];
        _appstoreURLForTheApp = [appStoreURLString copy];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update" message:@"There is an update available for your Burnett's Flavorite Occasions recipe app.\nWould you like to update now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag = kAlertViewAppUpdateAvailable;
        [alertView show];
        [alertView release];
    });
}










#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kAlertViewAppUpdateAvailable)
    {
        if(buttonIndex == 1)
        {
            NSURL *url = [NSURL URLWithString:_appstoreURLForTheApp];
            if([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"An error occured while opening the Appstore app. Please update the app from Appstore." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
            }
        }
    }
}

@end
