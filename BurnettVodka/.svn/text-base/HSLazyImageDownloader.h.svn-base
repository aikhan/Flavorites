//
//  HSLazyImageDownloader.h
//  YECApp
//
//  Created by Ironman on 17/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSLazyLoadImage.h"
#import "HSLazyImageLoadOperation.h"


@class HSLazyImageDownloader;

@protocol HSLazyImageDownloaderDelegate <NSObject>

- (void)imageDownloader:(HSLazyImageDownloader *)downloader finishedLoadingForImage:(HSLazyLoadImage *)image;

@end


@interface HSLazyImageDownloader : NSObject <HSLazyImageDownloadOperationDelegate> {
    
    NSOperationQueue *_operationQueue;
    
    id <HSLazyImageDownloaderDelegate> delegate;
}

@property (nonatomic, assign) id <HSLazyImageDownloaderDelegate> delegate;

- (void)addLazyLoadImage:(HSLazyLoadImage *)lazyLoadImageObject;

- (void)cancelAllLoads;

@end
