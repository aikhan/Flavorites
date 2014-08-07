//
//  NewServerFetchOperations.h
//  BurnettVodka
//
//  Created by Asad Khan on 03/06/2014.
//  Copyright (c) 2014 XenoPsi Media. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ConnectionStatus) {
    
    kNotAvailable,
    kWANAvailable,
    kWifiAvailable
    
};
@interface NewServerFetchOperations : NSObject

@property (nonatomic, assign) ConnectionStatus myConnectionStatus;
@property (nonatomic, strong) NSMutableArray *myRecipesArray;

+ (NewServerFetchOperations*)sharedManager;
- (void)fetchLatestRecipeData;
- (void)fetchLatestFlavors;
- (BOOL)checkFileExistsLocallyWithFileName:(NSString*)fileName;
@end
