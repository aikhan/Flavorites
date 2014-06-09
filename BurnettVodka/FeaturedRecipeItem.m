//
//  FeaturedRecipeItem.m
//  BurnettVodka
//
//  Created by admin on 7/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "FeaturedRecipeItem.h"

@implementation FeaturedRecipeItem

@synthesize recipeID;
@synthesize imageFilePath;

- (void)dealloc {
    
    [imageFilePath release];
    [super dealloc];
}

@end
