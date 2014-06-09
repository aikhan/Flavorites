//
//  Recipe.h
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Flavor, BVApp;

@interface Recipe : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * ratingValue;
@property (nonatomic, retain) NSNumber * ratingCount;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) Flavor *flavor;
@property (nonatomic, retain) NSNumber * recipeID;
@property (nonatomic, retain) NSString * ingredients;
@property (nonatomic, retain) NSString * directions;
@property (nonatomic, retain) BVApp *associatedApp;
@property (nonatomic, retain) NSNumber * ratingValueSubmittedByUser;



- (NSString *)usableImageName;
- (NSString *)pngImageFileName;
- (NSArray *)arrayOfIngredients;
- (NSString *)urlLinkForRecipe;

@end
