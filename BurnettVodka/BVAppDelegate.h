//
//  BVAppDelegate.h
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVAgeGateViewController.h"
#import "GAI.h"

@class BVTabBarController;

@interface BVAppDelegate : UIResponder <UIApplicationDelegate, BVAgeGateViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BVTabBarController *tabBarController;
@property (strong, nonatomic) BVAgeGateViewController *ageGateController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, strong) id<GAITracker> tracker;
@property (nonatomic, assign) NSInteger appStartupCount;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)fetchRecipiesFromServer;

@end
