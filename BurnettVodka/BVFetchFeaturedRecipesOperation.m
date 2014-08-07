//
//  BVFetchFeaturedRecipesOperation.m
//  BurnettVodka
//
//  Created by admin on 8/9/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVFetchFeaturedRecipesOperation.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "JSON.h"
#import "DataManager.h"
#import "UtilityManager.h"

@interface BVFetchFeaturedRecipesOperation ()

- (BOOL)checkAndCompleteARecipeSetFromTemporaryFolder;

@end


@implementation BVFetchFeaturedRecipesOperation

@synthesize operationDelegate;

- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // First we shall fetch the JSON that represents the latest recipes to be shown on home screen.
    
    NSString *urlString = [NSString stringWithFormat:@"%@/featured_recipe.php", kAPIServerPathNew];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.timeOutSeconds = 30;
    request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *responseString = [request responseString];
        
        // Temp:
//        responseString = [responseString stringByReplacingOccurrencesOfString:@"https:\\/\\/facebook.heavenhill.com\\/burnetts\\/images\\/Burnetts_DrinkImages\\/PinkLemonade_GingerFusion.jpg" withString:@"http://harmandeepsingh.info/burnetts/images/strawberry_banana_swirl.png"];
//        
//        responseString = [responseString stringByReplacingOccurrencesOfString:@"https:\\/\\/facebook.heavenhill.com\\/burnetts\\/images\\/Burnetts_DrinkImages\\/HotCinn_VanillaSpice.jpg" withString:@"http://harmandeepsingh.info/burnetts/images/club_cola.png"];
//        
//        responseString = [responseString stringByReplacingOccurrencesOfString:@"https:\\/\\/facebook.heavenhill.com\\/burnetts\\/images\\/Burnetts_DrinkImages\\/sugar-cookie-lemon-bar.jpg" withString:@"http://harmandeepsingh.info/burnetts/images/lemon_bar.png"];
        
        
        NSDictionary *responseDic = [responseString JSONValue];
        NSString *successString = [responseDic valueForKey:@"success"];
        if([[successString lowercaseString] isEqualToString:@"ok"])
        {
            id recipesArray = [responseDic valueForKey:@"featured_recipes"];
            if(recipesArray)
            {
                if([recipesArray isKindOfClass:[NSArray class]])
                {
                    //TEMP: We are temporary simulating as if no new feature recipe is coming from server.
                   if([recipesArray count] > 0)
//                    if(NO)
                    {
                        NSArray *sortedArrayFromLocalSystem = [[[DataManager sharedDataManager] featuredRecipesLatest] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"db_id" ascending:YES]]];
                        
                        NSArray *sortedArrayFromServer = [recipesArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"db_id" ascending:YES]]];
                        
                        
                        if(![[sortedArrayFromLocalSystem JSONRepresentation] isEqualToString:[sortedArrayFromServer JSONRepresentation]])
                        {
                            NSString *temporaryFolderInFeaturedRecipesFolder = [UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]];
                            
                            NSString *filePathForJSONStringToBeStoredInTempFolder = [temporaryFolderInFeaturedRecipesFolder stringByAppendingPathComponent:kFileNameForFeaturedRecipesJSON];
                            

                            NSError *jsonFileWriteError = nil;
                            BOOL jsonFileWriteSuccess = [responseString writeToFile:filePathForJSONStringToBeStoredInTempFolder atomically:YES encoding:4 error:&jsonFileWriteError];
                            if(!jsonFileWriteSuccess)
                            {
                                //TODO: file write failure log statement
                            }
                        }
                    }
                    else
                    {
                        //TODO: remove previous temporary recipe set 
                    }
                }
                else
                {
                    //TODO: remove previous temporary recipe set 
                }
            }
            else
            {
                // TODO: write error log
            }
        }
        else
        {
//            NSString *errorMessage = [responseDic valueForKey:@"error"];
            // TODO: write error log
        }
    }
    else
    {
        // TODO: write error log
    }
    [request release];
    
    
    
    // Lets check if there is any JSONString in the temporary folder and if there is, we should try and complete the recipe set.
    BOOL anyRecipeSetCompleted = [self checkAndCompleteARecipeSetFromTemporaryFolder];
    if([operationDelegate respondsToSelector:@selector(fetchFeaturedRecipesOperation:didFinishFetchOperationWithANewRecipeReady:)])
    {
        [operationDelegate fetchFeaturedRecipesOperation:self didFinishFetchOperationWithANewRecipeReady:anyRecipeSetCompleted];
    }
    
    
    [pool release];
}


- (BOOL)checkAndCompleteARecipeSetFromTemporaryFolder
{
    BOOL success = YES;
    
    NSString *jsonFilePath = [[UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]] stringByAppendingPathComponent:kFileNameForFeaturedRecipesJSON];
    NSString *jsonString = [NSString stringWithContentsOfFile:jsonFilePath encoding:4 error:nil];
    id recipesArray = [[jsonString JSONValue] valueForKey:@"featured_recipes"];
    if(recipesArray && [recipesArray isKindOfClass:[NSArray class]])
    {
        NSMutableArray *arrayOfFilePathsToDownload = [[NSMutableArray alloc] init];
        for(NSDictionary *recipeDic in recipesArray)
        {
            NSString *imagePath = [recipeDic valueForKey:@"imagePath"];
            NSString *retinaVersionImagePath = [[[[[NSURL URLWithString:imagePath] URLByDeletingPathExtension] absoluteString] stringByAppendingString:@"@2x"] stringByAppendingFormat:@".%@", [imagePath pathExtension]];
            
            if(imagePath && retinaVersionImagePath)
            {
                [arrayOfFilePathsToDownload addObject:imagePath];
                [arrayOfFilePathsToDownload addObject:retinaVersionImagePath];
            }
            else
            {
                success = NO;
                break;
            }
        }
        
        
        
        
        if(success)
        {
            for(NSString *filePath in arrayOfFilePathsToDownload)
            {
                NSString *filePathToSaveTheImageTo = [[UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]] stringByAppendingPathComponent:[filePath lastPathComponent]];
                
                if(![[NSFileManager defaultManager] fileExistsAtPath:filePathToSaveTheImageTo])
                {
                    ASIHTTPRequest *fileDownloadRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:filePath]];
                    [fileDownloadRequest startSynchronous];
                    
                    NSError *error = [fileDownloadRequest error];
                    if (!error)
                    {
                        NSData *assetData = [fileDownloadRequest responseData];
                        
                        if(assetData)
                        {
                            NSError *fileWriteError = nil;
                            BOOL fileWritesucces = [assetData writeToFile:filePathToSaveTheImageTo options:NSDataWritingFileProtectionNone error:&fileWriteError];
                            if(!fileWritesucces)
                            {
                                // TODO: write error log
                                success = NO;
                            }
                        }
                        else
                        {
                            // TODO: write error log
                            success = NO;
                        }
                    }
                    else
                    {
                        // TODO: write error log
                        success = NO;
                    }
                }
            }
        }
        
        
        [arrayOfFilePathsToDownload release];
    }
    else
    {
        success = NO;
    }
    
    
    
    
    
    
    
    
    if(success)
    {
        // Before moving the items from Temporary Folder, we need to remove items from Featured Recipes Root Folder
        BOOL completeDeleteProcessSuccess = YES;
        
        NSArray *filePathsInFeaturedRecipesFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] error:nil];
        for(NSString *itemName in filePathsInFeaturedRecipesFolder)
        {
            if(![[itemName lowercaseString] isEqualToString:@"temp"])
            {
                NSString *filePathToDelete = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:itemName];
                BOOL deleteSuccess = [[NSFileManager defaultManager] removeItemAtPath:filePathToDelete error:nil];
                if(!deleteSuccess)
                {
                    completeDeleteProcessSuccess = NO;
                    break;
                }
            }
        }
        
        
        if(completeDeleteProcessSuccess)
        {
            BOOL completeShiftProcessSuccess = YES;
            
            // This means we have to transfer files from Temporary Folder To Featured Recipes Root Folder
            NSArray *filePathsInTemporaryFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]] error:nil];
            for(NSString *itemName in filePathsInTemporaryFolder)
            {
                NSString *filePathToMoveFrom = [[UtilityManager fileSystemPathForRelativeDirectoryPath:[NSString stringWithFormat:@"%@/temp", kDirectoryNameForFeaturedRecipesData]] stringByAppendingPathComponent:itemName];
                NSString *filePathToMoveTo = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:itemName];
                BOOL shiftSuccess = [[NSFileManager defaultManager] moveItemAtPath:filePathToMoveFrom toPath:filePathToMoveTo error:nil];
                if(!shiftSuccess)
                {
                    completeShiftProcessSuccess = NO;
                    break;
                }
            }
            
            if(!completeShiftProcessSuccess)
            {
                success = NO;
            }
        }
        else
        {
            success = NO;
        }
    }
    
    
    return success;
}

@end
