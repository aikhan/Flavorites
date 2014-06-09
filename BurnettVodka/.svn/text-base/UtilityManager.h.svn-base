//
//  UtilityManager.h
//  BurnettVodka
//
//  Created by admin on 7/16/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BVTabBarController.h"

@class BVAppDelegate;

@interface UtilityManager : NSObject {
    
    NSMutableDictionary *imageDic;
    dispatch_queue_t cacheQueue;
    BVAppDelegate *appDelegate;
    NSMutableArray *arrayOfWDACustomEventsToBeLogged;
}

+ (UtilityManager *)sharedUtilityManager;

+ (void)addTitle:(NSString *)titleString toNavigationItem:(UINavigationItem *)navItem;
+ (UIBarButtonItem *)navigationBarBackButtonItemWithTarget:(id)targer andAction:(SEL)action andHeight:(CGFloat)height;
+ (UIBarButtonItem *)navigationBarButtonItemWithTitle:(NSString *)title andTarget:(id)targer andAction:(SEL)action andHeight:(CGFloat)height;

+ (UIFont *)fontGetRegularFontOfSize:(CGFloat)size;
+ (UIFont *)fontGetBoldFontOfSize:(CGFloat)size;
+ (UIFont *)fontGetLightFontOfSize:(CGFloat)size;

- (UIImage *)cacheImageWithCompleteFileName:(NSString *)fileName andAddIfRequired:(BOOL)addIfRequired;
- (void)cacheAddImage:(UIImage *)image againstCompleteFileName:(NSString *)fileName;

+ (BVTabBarController *)tabBarControllerOfTheApplication;

+ (NSString *)stringBystrippngUwantedSpaceAndInvertedCommasInString:(NSString *)inputString;

+ (NSString *)fileSystemDocumentsDirectoryPath;
+ (NSString *)fileSystemPathForRelativeDirectoryPath:(NSString *)relativeDirectoryPath;

+ (BOOL)isThisDeviceA4InchIphone;
+ (NSString*)getMacAddress;
+ (NSString*)getAdvertisingIdentifier;
+ (NSString *)getAdvertisingEnabled;
+ (NSString *)identifierForVendor;
+ (NSComparisonResult)compareAppVersionLeftString:(NSString *)leftVersion withRightString:(NSString *)rightVersion;

@end
