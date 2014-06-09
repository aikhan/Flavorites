//
//  BVFetchRatingsOperation.m
//  BurnettVodka
//
//  Created by admin on 7/30/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVFetchRatingsOperation.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"

@implementation BVFetchRatingsOperation

@synthesize operationDelegate;

- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/rating.php?type=getAllRecipeRatings", kAPIServerPath];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.timeOutSeconds = 30;
    request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *responseString = [request responseString];
        NSDictionary *responseDic = [responseString JSONValue];
        NSString *successString = [responseDic valueForKey:@"success"];
        if([[successString lowercaseString] isEqualToString:@"yes"])
        {
            NSArray *recipesArray = [responseDic valueForKey:@"aRecipes"];
            if([recipesArray isKindOfClass:[NSArray class]])
            {
                if([operationDelegate respondsToSelector:@selector(fetchRatingsOperation:didFinishedDownloadingRatingsForRecipes:)])
                {
                    [operationDelegate fetchRatingsOperation:self didFinishedDownloadingRatingsForRecipes:recipesArray];
                }
            }
            else
            {
                
            }
        }
        else
        {
//            NSString *errorMessage = [responseDic valueForKey:@"error"];
            // TODO: write error log
        }
    }
    [request release];
    
    [pool release];
}

@end
