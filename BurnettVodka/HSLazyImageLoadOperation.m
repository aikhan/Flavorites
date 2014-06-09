//
//  HSLazyImageDownloadOperation.m
//  YECApp
//
//  Created by Ironman on 17/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HSLazyImageLoadOperation.h"


@implementation HSLazyImageLoadOperation

@synthesize delegate;


- (id)initWithLazyLoadImage:(HSLazyLoadImage *)image
{
    self = [super init];
    if(self)
    {
        _imageObject = [image retain]; 
    }
    return self;
}


- (void)dealloc {
    
    [delegate release];
    [_imageObject release];
    [super dealloc];
}




- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (![self isCancelled])
	{
        NSString *imageExtention = [_imageObject.fileName pathExtension];
        NSString *imageFileNameWithoutExtension = [[_imageObject.fileName lastPathComponent] stringByDeletingPathExtension];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageFileNameWithoutExtension ofType:imageExtention]];
        _imageObject.image = image;
        [image release];
	}
    
    if([delegate respondsToSelector:@selector(lazyImageDownloadOperation:finishedLoadingForImageObject:)])
    {
        [delegate lazyImageDownloadOperation:self finishedLoadingForImageObject:_imageObject];
    }
    
	[pool release];
}




@end
