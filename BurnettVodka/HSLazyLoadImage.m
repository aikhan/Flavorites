//
//  LazyLoadImage.m
//  YECApp
//
//  Created by Ironman on 17/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HSLazyLoadImage.h"


@implementation HSLazyLoadImage

@synthesize image;
@synthesize fileName;


- (id)initWithFileName:(NSString *)imageFileName
{
    self = [super init];
    if(self)
    {
        fileName = [imageFileName copy];
    }
    return self;
}


- (void)dealloc {
    
    [fileName release];
    [image release];
    [super dealloc];
}


@end
