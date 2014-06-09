//
//  NewServerFetchOperations.m
//  BurnettVodka
//
//  Created by Asad Khan on 03/06/2014.
//  Copyright (c) 2014 XenoPsi Media. All rights reserved.
//

#import "NewServerFetchOperations.h"
#import "Reachability/Reachability.h"
#import "BVAppDelegate.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "Recipe.h"
#import "Flavor.h"
#import "DataManager.h"

@implementation NewServerFetchOperations
@synthesize myConnectionStatus = _myConnectionStatus;
BVAppDelegate *appDelegate;

#pragma mark -
#pragma mark Singleton Methods

static NewServerFetchOperations *sharedManager = nil;

+ (NewServerFetchOperations*)sharedManager{
    if (sharedManager != nil)
    {
        return sharedManager;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      sharedManager = [[NewServerFetchOperations alloc] init];
                      
                  });
#else
    @synchronized([SNAdsManager class])
    {
        if (sharedManager == nil)
        {
            sharedManager = [[NewServerFetchOperations alloc] init];
            
        }
    }
#endif
    return sharedManager;
}



- (id)copyWithZone:(NSZone *)zone{
	return self;
}

- (id) init{
	self = [super init];
        if(self !=nil){
            //init code
            appDelegate = (BVAppDelegate *)[[UIApplication sharedApplication] delegate];
            _myRecipesArray = [[NSMutableArray alloc] init];
            _myConnectionStatus = [self isReachableVia];
            if(_myConnectionStatus == kNotReachable){
                //[self fetchLatestFlavors];
                }else{
                    NSLog(@"!!!Offline!!!");
            }
        }
	return self;
}//end init

- (ConnectionStatus)isReachableVia{
    Reachability *r = [Reachability reachabilityWithHostName:@"http://www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == ReachableViaWiFi)
        return kWifiAvailable;
    else if (internetStatus == ReachableViaWWAN)
        return kWANAvailable;
    else
        return kNotReachable;
}

-(void)fetchLatestRecipeData{
    __block BOOL isUpdate = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    NSBlockOperation *fetchRecipesOperation = [NSBlockOperation blockOperationWithBlock:^{
    ASIHTTPRequest *request;
        if (appDelegate.appStartupCount <= 1) {
                request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:kGetAllRecipes]];
                isUpdate = NO;
        }
        else{
            NSDate *date = [self fetchLastRecipeUpdateDate];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-mm-dd"];
            NSString *stringFromDate = [formatter stringFromDate:date];
            [formatter release];
            NSString *urlString = [NSString stringWithFormat:@"%@%@", kGetRecipesUpdates, stringFromDate];
            DebugLog(@"URL Date String %@", urlString);
            request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
            isUpdate = YES;
        }
            request.timeOutSeconds = 30;
            request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
            [request startSynchronous];
            NSError *error = [request error];
            if (!error){
                NSString *responseString = [request responseString];
                NSDictionary *responseDic = [responseString JSONValue];
                NSString *successString = [responseDic valueForKey:@"success"];
                if([[successString lowercaseString] isEqualToString:@"yes"]){
                    NSArray *recipesArray = [responseDic valueForKey:@"aRecipes"];
                    if([recipesArray isKindOfClass:[NSArray class]])
                    {
                        DebugLog(@"Size of array is %d", recipesArray.count);
                        for(NSDictionary *recipeDic in recipesArray){
                            Recipe *recipe = nil;
                            if (isUpdate) {
                                recipe = [[DataManager sharedDataManager] recipesGetRecipeWithRecipeID:[[recipeDic valueForKeyPath:@"id"] integerValue]];
                                BOOL doesFileExist = NO;
                                if (recipe) {
                                    recipe.title = [recipeDic valueForKeyPath:@"name"];
                                    if ([recipeDic valueForKeyPath:@"finalAverageRating"] != [NSNull null] ) {
                                        recipe.ratingValue = [NSNumber numberWithFloat:(float)[[recipeDic valueForKeyPath:@"finalAverageRating"] floatValue]];
                                    }
                                    recipe.ratingCount = [NSNumber numberWithFloat:(float)[[recipeDic valueForKeyPath:@"finalTotalNumOfSubmission"] floatValue]];
                                    //recipe.recipeID = [NSNumber numberWithInteger:[[recipeDic valueForKeyPath:@"recipe_id"] integerValue]];
                                    recipe.imageName = [recipeDic valueForKeyPath:@"image"];
                                    recipe.ingredients = [recipeDic valueForKeyPath:@"ingredients"];
                                    recipe.directions = [recipeDic valueForKeyPath:@"directions"];
                                    recipe.flavor.title = [recipeDic valueForKeyPath:@"product"];
                                    
                                    NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.png", recipe.imageName ] ofType:nil];
                                    doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName];//Check for file name in bundle
                                    
                                    
                                    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                                    NSString* imageFilePNG = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", recipe.imageName ]];
                                    doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:imageFilePNG];//Check in documents directory for png file
                                    
                                    NSString* imageFileJPG = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", recipe.imageName ]];
                                    doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:imageFileJPG];//Check in documents directory for jpg file
                                    
                                    if (!doesFileExist) {
                                        [self downloadImageFileFromTheInternetForFileName:recipe.imageName isFlavor:NO];
                                    }
                                }
                                
                            }else{

                            Recipe *recipe = (Recipe *)[NSEntityDescription insertNewObjectForEntityForName:@"Recipe" inManagedObjectContext:[DataManager managedObjectContextOnMainThread]];
                            recipe.title = [recipeDic valueForKeyPath:@"drink_name"];
                            if ([recipeDic valueForKeyPath:@"finalAverageRating"] != [NSNull null] ) {
                                recipe.ratingValue = [NSNumber numberWithFloat:(float)[[recipeDic valueForKeyPath:@"finalAverageRating"] floatValue]];
                            }
                            recipe.ratingCount = [NSNumber numberWithFloat:(float)[[recipeDic valueForKeyPath:@"finalTotalNumOfSubmission"] floatValue]];
                            recipe.recipeID = [NSNumber numberWithInteger:[[recipeDic valueForKeyPath:@"recipe_id"] integerValue]];
                            recipe.imageName = [recipeDic valueForKeyPath:@"image"];
                            recipe.ingredients = [recipeDic valueForKeyPath:@"ingredients"];
                            recipe.directions = [recipeDic valueForKeyPath:@"directions"];
                            recipe.flavor.title = [recipeDic valueForKeyPath:@"product"];
                            [self.myRecipesArray addObject:recipe];
                            [recipe release];
                        }
                    }
                }
                    DebugLog(@"Size of final array is %d", [self.myRecipesArray count]);
                    [DataManager saveDatabaseOnMainThread];
                }else{
                    //Handle Error
                    //Show UI components on main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Server has returned an error. For further assistance contact support." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    });
                }

            }
            
            [request release];
        //}
    }];
    [operationQueue addOperation:fetchRecipesOperation];
    if (self.myConnectionStatus == kWANAvailable)
        [operationQueue setMaxConcurrentOperationCount:2];
    else if (self.myConnectionStatus == kWifiAvailable)
        [operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];

    [pool release];
}

- (void)fetchLatestFlavors{
    __block BOOL isUpdate = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    NSBlockOperation *fetchRecipesOperation = [NSBlockOperation blockOperationWithBlock:^{
        ASIHTTPRequest *request;
        if (appDelegate.appStartupCount <= 1) {
            request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:kGetAllFlavors]];
            isUpdate = NO;
        }
        else{
            NSDate *date = [self fetchLastRecipeUpdateDate];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-mm-dd"];
            NSString *stringFromDate = [formatter stringFromDate:date];
            [formatter release];
            NSString *urlString = [NSString stringWithFormat:@"%@%@", kGetFlavoeUpdates, stringFromDate];
            request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
            isUpdate = YES;
        }
        request.timeOutSeconds = 30;
        request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
        [request startSynchronous];
        NSError *error = [request error];
        if (!error){
            NSString *responseString = [request responseString];
            NSDictionary *responseDic = [responseString JSONValue];
            NSString *successString = [responseDic valueForKey:@"success"];
            if([[successString lowercaseString] isEqualToString:@"yes"]){
                NSArray *flavorsArray = [responseDic valueForKey:@"aFlavors"];
                if([flavorsArray isKindOfClass:[NSArray class]])
                {
                    DebugLog(@"Size of array is %d", flavorsArray.count);
                    for(NSDictionary *flavorDic in flavorsArray){
                        Flavor *flavor = nil;
                        if (isUpdate) {
                           flavor = [[DataManager sharedDataManager] flavorsGetFlavorWithFlavorID:[[flavorDic valueForKeyPath:@"id"] integerValue]];
                            BOOL doesFileExist = NO;
                            if (flavor) {
                                flavor.title = [flavorDic valueForKeyPath:@"name"];
                                flavor.imageName = [flavorDic valueForKeyPath:@"imagename"];
                                
                                NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.png", flavor.imageName ] ofType:nil];
                                doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName];//Check for file name in bundle
                                
                                
                                NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                                NSString* imageFilePNG = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", flavor.imageName ]];
                                doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:imageFilePNG];//Check in documents directory for png file
                                
                                NSString* imageFileJPG = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", flavor.imageName ]];
                                doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:imageFileJPG];//Check in documents directory for jpg file
                                
                                if (!doesFileExist) {
                                    [self downloadImageFileFromTheInternetForFileName:flavor.imageName isFlavor:YES];
                                }
                                
                            }
                            
                        }else{
                            flavor = (Flavor *)[NSEntityDescription insertNewObjectForEntityForName:@"Flavor" inManagedObjectContext:[DataManager managedObjectContextOnMainThread]];
                            flavor.title = [flavorDic valueForKeyPath:@"name"];
                            flavor.flavorID = [NSNumber numberWithInteger:[[flavorDic valueForKeyPath:@"id"] integerValue]];
                        }
                    }
                }
                [DataManager saveDatabaseOnMainThread];
                [self fetchLatestRecipeData];
            }else{
                //Handle Error
                //Show UI components on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Server has returned an error. For further assistance contact support." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
            
        }
        [request release];
        //}
    }];
    [operationQueue addOperation:fetchRecipesOperation];

    
    [pool release];
}

- (NSDate*)fetchLastRecipeUpdateDate{
    return (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:@"lastDate"];
}
-(void)saveLastFetchDate{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastDate"];
}

- (void)downloadImageFileFromTheInternetForFileName:(NSString*)fileName isFlavor:(BOOL)isFLavor{
    NSString *urlString = nil;
    if (isFLavor) {
        urlString= [NSString stringWithFormat:@"%@%@", kFlavorsBaseURL, fileName ] ;
    }else{
        urlString = [NSString stringWithFormat:@"%@%@", kRecipeBaseURL, fileName ] ;
    }
    
    DebugLog(@"URL string for image is %@", urlString);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^(void) {
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
                             
                             UIImage* image = [[UIImage alloc] initWithData:imageData];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                     NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString* path = [documentsDirectory stringByAppendingPathComponent:
                                  [NSString stringWithString: fileName] ];
                NSData* data = UIImagePNGRepresentation(image);
                [data writeToFile:path atomically:YES];
                
                NSNotification* notification = nil;
                if (isFLavor) {
                    notification = [NSNotification notificationWithName:@"FlavorImageDownloadComplete" object:nil];
                }else{
                    notification = [NSNotification notificationWithName:@"RecipeImageDownloadComplete" object:nil];
                }
                
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            });
        }
    });
    
}

-(void)dealloc{
    [self.myRecipesArray release];
    [super dealloc];
}
@end
