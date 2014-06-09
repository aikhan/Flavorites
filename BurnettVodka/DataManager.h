//
//  DataManager.h
//  BurnettVodka
//
//  Created by admin on 6/30/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BVFetchRatingsOperation.h"
#import "BVFetchFeaturedRecipesOperation.h"
#import "BVCheckAppUpdateOperation.h"

@class BVApp;
@class Recipe;
@class Flavor;

@interface DataManager : NSObject <BVFetchRatingsOperationDelegate, BVFetchFeaturedRecipesOperationDelegate, BVCheckAppUpdateOperationDelegate> {
    
    NSArray *_allFlavorsArray;
    NSArray *_allRecipesArray;
    NSArray *_allMixersArray;
    NSArray *_allFlavorTitlesToBeTaggedNew;
    BVApp *_app;
    
    NSOperationQueue *_operationQueue;
    
    NSString *_appstoreURLForTheApp;
}

+ (DataManager *)sharedDataManager;

+ (void)saveDatabaseOnMainThread;
+ (NSManagedObjectContext *)managedObjectContextOnMainThread;

- (NSArray *)mixersGetAllMixers;
- (NSArray *)flavorsGetAllFlavors;
- (Flavor *)flavorsGetFlavorWithFlavorTitle:(NSString *)flavorTitle;
- (BOOL)flavorsIsThisANewFlavor:(Flavor *)flavor;
- (NSArray *)recipesGetAllRecipes;
- (Recipe *)recipesGetRecipeWithRecipeID:(NSInteger)recipeID;
- (Flavor *)flavorsGetFlavorWithFlavorID:(NSInteger)flavorID;
- (BVApp *)app;

- (void)checkAndRepairAppData;

- (void)fetchRecipesRatingsFromServer;
- (void)fetchFeaturedRecipesDataFromServer;
- (void)fetchLaterAppVersionAvailableFromServer;

- (NSArray *)featuredRecipesLatest;
- (NSArray *)featuredRecipesDefault;

@end
