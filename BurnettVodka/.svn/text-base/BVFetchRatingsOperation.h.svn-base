//
//  BVFetchRatingsOperation.h
//  BurnettVodka
//
//  Created by admin on 7/30/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BVFetchRatingsOperation;

@protocol BVFetchRatingsOperationDelegate <NSObject>

- (void)fetchRatingsOperation:(BVFetchRatingsOperation *)operation didFinishedDownloadingRatingsForRecipes:(NSArray *)recipesArrayWithRatings;

@end

@interface BVFetchRatingsOperation : NSOperation {

    id <BVFetchRatingsOperationDelegate> operationDelegate;
}

@property (nonatomic, assign) id <BVFetchRatingsOperationDelegate> operationDelegate;

@end
