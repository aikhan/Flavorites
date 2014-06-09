//
//  BVFetchFeaturedRecipesOperation.h
//  BurnettVodka
//
//  Created by admin on 8/9/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BVFetchFeaturedRecipesOperation;

@protocol BVFetchFeaturedRecipesOperationDelegate <NSObject>

- (void)fetchFeaturedRecipesOperation:(BVFetchFeaturedRecipesOperation *)operation didFinishFetchOperationWithANewRecipeReady:(BOOL)anyNewRecipeSetAvailable;

@end

@interface BVFetchFeaturedRecipesOperation : NSOperation {
    
    id <BVFetchFeaturedRecipesOperationDelegate> operationDelegate;
}

@property (nonatomic, assign) id <BVFetchFeaturedRecipesOperationDelegate> operationDelegate;

@end
