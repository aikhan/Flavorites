//
//  BVApp.h
//  BurnettVodka
//
//  Created by admin on 7/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipe;

@interface BVApp : NSManagedObject

@property (nonatomic, retain) NSString * currentVersionOfFlavorData;
@property (nonatomic, retain) NSString * currentVersionOfRecipeData;
@property (nonatomic, retain) NSNumber * deviceID;
@property (nonatomic, retain) NSSet *favoriteRecipes;

@end

@interface BVApp (CoreDataGeneratedAccessors)

- (void)addFavoriteRecipesObject:(Recipe *)value;
- (void)removeFavoriteRecipesObject:(Recipe *)value;
- (void)addFavoriteRecipes:(NSSet *)values;
- (void)removeFavoriteRecipes:(NSSet *)values;

@end
