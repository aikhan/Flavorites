//
//  Recipe.m
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "Recipe.h"


@implementation Recipe

@dynamic title;
@dynamic ratingValue;
@dynamic ratingCount;
@dynamic imageName;
@dynamic flavor;
@dynamic recipeID;
@dynamic ingredients;
@dynamic directions;
@dynamic associatedApp;
@dynamic ratingValueSubmittedByUser;


- (NSString *)usableImageName
{
    return [[self.imageName lastPathComponent] stringByDeletingPathExtension];
}

- (NSString *)pngImageFileName
{
    NSString *stringByReplacingJPGWithPNG = [self.imageName stringByReplacingOccurrencesOfString:@"jpg" withString:@"png"];
    
    NSString *stringWithoutGetParams = nil;
    
    NSRange rangeOfQuestionMark = [stringByReplacingJPGWithPNG rangeOfString:@"?"];
    if(rangeOfQuestionMark.location != NSNotFound)
    {
        stringWithoutGetParams = [stringByReplacingJPGWithPNG substringToIndex:rangeOfQuestionMark.location];
    }
    else
    {
        stringWithoutGetParams = stringByReplacingJPGWithPNG;
    }
    
    return stringWithoutGetParams;
}

- (NSArray *)arrayOfIngredients
{
    return [self.ingredients componentsSeparatedByString:@"\n"];
}

- (NSString *)urlLinkForRecipe
{
    return [NSString stringWithFormat:@"http://burnettsvodka.com/recipe/%@", self.recipeID];
}


@end
