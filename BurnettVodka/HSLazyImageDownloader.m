//
//  HSLazyImageDownloader.m
//  YECApp
//
//  Created by Ironman on 17/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HSLazyImageDownloader.h"


@implementation HSLazyImageDownloader

@synthesize delegate;

- (id)init
{
    self = [super init];
    if(self)
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:5];
    }
    return self;
}

- (void)dealloc {
    
    [_operationQueue release];
    [super dealloc];
}



- (void)addLazyLoadImage:(HSLazyLoadImage *)lazyLoadImageObject
{
    HSLazyImageLoadOperation *operaiton = [[HSLazyImageLoadOperation alloc] initWithLazyLoadImage:lazyLoadImageObject];
    operaiton.delegate = self;
    [_operationQueue addOperation:operaiton];
    [operaiton release];
}

- (void)cancelAllLoads
{
    [_operationQueue cancelAllOperations];
}



- (void)lazyImageDownloadOperation:(HSLazyImageLoadOperation *)operation finishedLoadingForImageObject:(HSLazyLoadImage *)image
{
    if([delegate respondsToSelector:@selector(imageDownloader:finishedLoadingForImage:)])
    {
        [delegate imageDownloader:self finishedLoadingForImage:image];
    }
}

@end
