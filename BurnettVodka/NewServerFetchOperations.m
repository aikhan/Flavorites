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
static int flavorDownloadImageCount = 0;
static int recipeDownloadImageCount = 0;

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
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flavorImageDownloaded:) name:@"FlavorImageDownloadComplete" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recipeImageDownloaded:) name:@"RecipeImageDownloadComplete" object:nil];
            flavorDownloadImageCount = 0;
            recipeDownloadImageCount = 0;
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
                               // BOOL doesFileExist = NO;
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
                                    
                                    NSString *imageFileNameWithoutExtension = [recipe.imageName lastPathComponent];
                                    
                                    if (![self checkFileExistsLocallyWithFileName:imageFileNameWithoutExtension]) {
                                        [self downloadImageFileFromTheInternetForFileName:recipe.imageName withID:recipe.recipeID isFlavor:NO];
                                    }
                                }
                                
                            }
                            else{
                            Flavor *fl =[[DataManager sharedDataManager] flavorsGetFlavorWithFlavorTitle:[recipeDic valueForKeyPath:@"product"]];
                                if (fl!=nil) {
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
                                    recipe.flavor = [[DataManager sharedDataManager] flavorsGetFlavorWithFlavorTitle:[recipeDic valueForKeyPath:@"product"]];
                                    if (!recipe.flavor) {
                                        // DebugLog(@"Flavor name is %@", [recipeDic valueForKeyPath:@"product"]);
                                    }
                                    NSString *imageFileNameWithoutExtension = [recipe.imageName lastPathComponent];
                                    
                                    if (![self checkFileExistsLocallyWithFileName:imageFileNameWithoutExtension]) {
                                        DebugLog(@"Missing Recipe name %@ and image name %@", recipe.title, recipe.imageName);
                                        [self downloadImageFileFromTheInternetForFileName:recipe.imageName withID:recipe.recipeID isFlavor:NO];
                                    }
                                    [self.myRecipesArray addObject:recipe];
                                }
                            //[recipe release];
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
            else {
                NSDictionary *plistdic = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PropertyList" ofType:@"plist"]];
                NSString *pliststr = [plistdic objectForKey:kGetAllRecipes];
                NSDictionary *responseDic = [pliststr JSONValue];
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
                                // BOOL doesFileExist = NO;
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
                                    
                                    NSString *imageFileNameWithoutExtension = [recipe.imageName lastPathComponent];
                                    
                                    if (![self checkFileExistsLocallyWithFileName:imageFileNameWithoutExtension]) {
                                        [self downloadImageFileFromTheInternetForFileName:recipe.imageName withID:recipe.recipeID isFlavor:NO];
                                    }
                                }
                                
                            }else{
                                Flavor *flv = [[DataManager sharedDataManager] flavorsGetFlavorWithFlavorTitle:[recipeDic valueForKeyPath:@"product"]];
                                if (flv!=nil) {
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
                                    recipe.flavor = [[DataManager sharedDataManager] flavorsGetFlavorWithFlavorTitle:[recipeDic valueForKeyPath:@"product"]];
                                    if (!recipe.flavor) {
                                        // DebugLog(@"Flavor name is %@", [recipeDic valueForKeyPath:@"product"]);
                                    }
                                    NSString *imageFileNameWithoutExtension = [recipe.imageName lastPathComponent];
                                    
                                    if (![self checkFileExistsLocallyWithFileName:imageFileNameWithoutExtension]) {
                                        DebugLog(@"Missing Recipe name %@ and image name %@", recipe.title, recipe.imageName);
                                        [self downloadImageFileFromTheInternetForFileName:recipe.imageName withID:recipe.recipeID isFlavor:NO];
                                    }
                                    [self.myRecipesArray addObject:recipe];
                                    //[recipe release];
                                }
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
                            if (flavor) {
                                flavor.title = [flavorDic valueForKeyPath:@"name"];
                                flavor.imageName = [flavorDic valueForKeyPath:@"image"];
                                NSString *imageFileNameWithoutExtension = [flavor.imageName lastPathComponent];
                                
                                if (![self checkFileExistsLocallyWithFileName:imageFileNameWithoutExtension]) {
                                    [self downloadImageFileFromTheInternetForFileName:flavor.imageName withID:flavor.flavorID isFlavor:YES];
                                }
                            }
                            
                        }else{
                            flavor = (Flavor *)[NSEntityDescription insertNewObjectForEntityForName:@"Flavor" inManagedObjectContext:[DataManager managedObjectContextOnMainThread]];
                            flavor.title = [flavorDic valueForKeyPath:@"name"];
                            //DebugLog(@"Flavor name is %@", flavor.title);
                            flavor.imageName = [flavorDic valueForKeyPath:@"image"];
                            flavor.flavorID = [NSNumber numberWithInteger:[[flavorDic valueForKeyPath:@"id"] integerValue]];
                            NSString *imageFileNameWithoutExtension = [flavor.imageName lastPathComponent];
                          //  NSString *finalname =
                            
                            if (![self checkFileExistsLocallyWithFileName:imageFileNameWithoutExtension]) {
                                DebugLog(@"Missing flavor name %@ and image name %@", flavor.title, flavor.imageName);
                                [self downloadImageFileFromTheInternetForFileName:flavor.imageName withID:flavor.flavorID isFlavor:YES];
                            }
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
        else {
            NSDictionary *plistdic = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PropertyList" ofType:@"plist"]];
            NSString *pliststr = [plistdic objectForKey:kGetAllFlavors];
            NSDictionary *responseDic = [pliststr JSONValue];
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
                            if (flavor) {
                                flavor.title = [flavorDic valueForKeyPath:@"name"];
                                flavor.imageName = [flavorDic valueForKeyPath:@"image"];
                                NSString *imageFileNameWithoutExtension = [flavor.imageName lastPathComponent];
                                
                                if (![self checkFileExistsLocallyWithFileName:imageFileNameWithoutExtension]) {
                                    [self downloadImageFileFromTheInternetForFileName:flavor.imageName withID:flavor.flavorID isFlavor:YES];
                                }
                            }
                            
                        }else{
                            flavor = (Flavor *)[NSEntityDescription insertNewObjectForEntityForName:@"Flavor" inManagedObjectContext:[DataManager managedObjectContextOnMainThread]];
                            flavor.title = [flavorDic valueForKeyPath:@"name"];
                            //DebugLog(@"Flavor name is %@", flavor.title);
                            flavor.imageName = [flavorDic valueForKeyPath:@"image"];
                            flavor.flavorID = [NSNumber numberWithInteger:[[flavorDic valueForKeyPath:@"id"] integerValue]];
                            NSString *imageFileNameWithoutExtension = [flavor.imageName lastPathComponent];
                            //  NSString *finalname =
                            
                            if (![self checkFileExistsLocallyWithFileName:imageFileNameWithoutExtension]) {
                                DebugLog(@"Missing flavor name %@ and image name %@", flavor.title, flavor.imageName);
                                [self downloadImageFileFromTheInternetForFileName:flavor.imageName withID:flavor.flavorID isFlavor:YES];
                            }
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
        NSLog(@"%@",error);
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

- (BOOL)checkFileExistsLocallyWithFileName:(NSString*)fileName{
   // DebugLog(@"%s", __PRETTY_FUNCTION__);
    //DebugLog(@"File to check %@", fileName);
    BOOL doesFileExist = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileInResourcesFolder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    doesFileExist = [fileManager fileExistsAtPath:fileInResourcesFolder];//Check for file name in bundle
    if (doesFileExist) {
        return YES;
    }
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* imageFilePNG = [documentsPath stringByAppendingPathComponent:fileName];
    doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:imageFilePNG];//Check in documents directory for png file
    if (doesFileExist) {
        return YES;
    }
    
    NSString* imageFileJPG = [documentsPath stringByAppendingPathComponent:fileName];
    doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:imageFileJPG];//Check in documents directory for jpg file
    
    return doesFileExist;
}

- (void)downloadImageFileFromTheInternetForFileName:(NSString*)fileName withID:(NSNumber*)ID isFlavor:(BOOL)isFLavor{
    //DebugLog(@"download image %@ and object ID : %d", fileName, [ID integerValue]);
    NSString *urlString = nil;
    if (isFLavor) {
        urlString= [NSString stringWithFormat:@"%@%@", kFlavorsBaseURL, fileName ] ;
    }else{
        urlString = [NSString stringWithFormat:@"%@%@", kRecipeBaseURL, fileName ] ;
    }
    //urlString = @"http://burnetts14.xm0001.com/mobile_app/images/flavors/Flavor_100proof.png";
    //DebugLog(@"URL string for image is %@", urlString);
    
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
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:ID forKey:@"objectID"];
                //[userInfo setValue:fileName forKey:@"objectImage"];
                if (isFLavor) {
                    notification = [NSNotification notificationWithName:@"FlavorImageDownloadComplete:" object:nil userInfo:userInfo];
                }else{
                    notification = [NSNotification notificationWithName:@"RecipeImageDownloadComplete" object:nil userInfo:userInfo];
                }
                
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            });
        }
    });
    
}

- (void)flavorImageDownloaded:(NSNotification *)notification{
    flavorDownloadImageCount++;
    DebugLog(@"Download fimage numher %d", flavorDownloadImageCount);
}

- (void)recipeImageDownloaded:(NSNotification *)notification{
    recipeDownloadImageCount++;
    DebugLog(@"Download rimage numher %d", recipeDownloadImageCount);
}

-(void)dealloc{
    [self.myRecipesArray release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
