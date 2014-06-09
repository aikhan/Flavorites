//
//  BVCheckAppUpdateOperation.h
//  BurnettVodka
//
//  Created by admin on 9/24/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BVCheckAppUpdateOperation;

@protocol BVCheckAppUpdateOperationDelegate <NSObject>

- (void)checkAppUpdateOperation:(BVCheckAppUpdateOperation *)operation didFinishCheckingAppUpdateWithAppUpdateAvailable:(BOOL)appUpdateAvailable andAppstoreURLString:(NSString *)appStoreURLString;

@end

@interface BVCheckAppUpdateOperation : NSOperation {
    
    id <BVCheckAppUpdateOperationDelegate> operationDelegate;
}

@property (nonatomic, assign) id <BVCheckAppUpdateOperationDelegate> operationDelegate;

@end
