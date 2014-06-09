//
//  Flavor.h
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipe;

@interface Flavor : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSSet *recipes;
@property (nonatomic, retain) NSNumber * flavorID;

@end

@interface Flavor (CoreDataGeneratedAccessors)

- (void)addRecipesObject:(Recipe *)value;
- (void)removeRecipesObject:(Recipe *)value;
- (void)addRecipes:(NSSet *)values;
- (void)removeRecipes:(NSSet *)values;

@end
