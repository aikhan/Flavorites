//
//  HSLazyImageDownloadOperation.h
//  YECApp
//
//  Created by Ironman on 17/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSLazyLoadImage.h"

@class HSLazyImageLoadOperation;

@protocol HSLazyImageDownloadOperationDelegate <NSObject>

- (void)lazyImageDownloadOperation:(HSLazyImageLoadOperation *)operation finishedLoadingForImageObject:(HSLazyLoadImage *)image;

@end



@interface HSLazyImageLoadOperation : NSOperation {
    
    HSLazyLoadImage *_imageObject;
    
    id <HSLazyImageDownloadOperationDelegate> delegate;
}

@property (nonatomic, retain) id <HSLazyImageDownloadOperationDelegate> delegate;

- (id)initWithLazyLoadImage:(HSLazyLoadImage *)image;

@end
