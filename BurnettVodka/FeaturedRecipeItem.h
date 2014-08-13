//
//  FeaturedRecipeItem.h
//  BurnettVodka
//
//  Created by admin on 7/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeaturedRecipeItem : NSObject {
    
    NSInteger recipeID;
    NSString *imageFilePath;
    BOOL isNewimg;
}
@property (nonatomic, assign) BOOL isNewimg;
@property (nonatomic, assign) NSInteger recipeID;
@property (nonatomic, copy) NSString *imageFilePath;

@end
