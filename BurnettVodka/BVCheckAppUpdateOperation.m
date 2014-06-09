//
//  BVCheckAppUpdateOperation.m
//  BurnettVodka
//
//  Created by admin on 9/24/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVCheckAppUpdateOperation.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "UtilityManager.h"


@implementation BVCheckAppUpdateOperation

@synthesize operationDelegate;

- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/check_update.php", kAPIServerPath];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.timeOutSeconds = 30;
    request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *responseString = [request responseString];
        NSDictionary *responseDic = [responseString JSONValue];
        
    
        NSString *latestVersionAvailable = [responseDic valueForKey:@"version"];
        NSString *appstoreURLString = [responseDic valueForKey:@"appstore_url"];

        if(latestVersionAvailable && appstoreURLString)
        {
            NSString *currentVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            
            NSComparisonResult result = [UtilityManager compareAppVersionLeftString:currentVersionString withRightString:latestVersionAvailable];
            
            if(result == NSOrderedAscending)
            {
                if([operationDelegate respondsToSelector:@selector(checkAppUpdateOperation:didFinishCheckingAppUpdateWithAppUpdateAvailable:andAppstoreURLString:)])
                {
                    [operationDelegate checkAppUpdateOperation:self didFinishCheckingAppUpdateWithAppUpdateAvailable:YES andAppstoreURLString:appstoreURLString];
                }
            }
        }
        else
        {
            // TODO: write error log
        }
    }
    [request release];
    
    [pool release];
}


@end
