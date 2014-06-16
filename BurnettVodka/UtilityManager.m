//
//  UtilityManager.m
//  BurnettVodka
//
//  Created by admin on 7/16/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "UtilityManager.h"
#import "BVAppDelegate.h"
#import "Constants.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <errno.h>
#include <net/if_dl.h>
#include <sys/sysctl.h>
#include <net/if.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
//#import <AdSupport/AdSupport.h>
#endif





static UtilityManager *sharedUtilityManager = nil;


@interface UtilityManager ()



@end



@implementation UtilityManager

+ (UtilityManager *)sharedUtilityManager
{
    @synchronized(self) {
        if (sharedUtilityManager == nil) {
            [[self alloc] init];
        }
    }
    return sharedUtilityManager;
}


+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedUtilityManager == nil) {
            return [super allocWithZone:zone];
        }
    }
    return sharedUtilityManager;
}


- (id)init
{
    Class myClass = [self class];
    @synchronized(myClass) {
        if (sharedUtilityManager == nil) {
            if (self = [super init]) {
                sharedUtilityManager = self;
                // custom initialization here
                
                imageDic = [[NSMutableDictionary alloc] init];
                cacheQueue = dispatch_queue_create("cachequeue", DISPATCH_QUEUE_CONCURRENT);
                arrayOfWDACustomEventsToBeLogged = [[NSMutableArray alloc] init];
            }
        }
    }
    return sharedUtilityManager;
}


- (id)copyWithZone:(NSZone *)zone { return self; }


- (id)retain { return self; }


- (unsigned)retainCount { return UINT_MAX; }


- (oneway void) release {}


- (id)autorelease { return self; }


+ (void)addTitle:(NSString *)titleString toNavigationItem:(UINavigationItem *)navItem
{
    UIFont *font = [self fontGetRegularFontOfSize:27];
    CGSize titleSize = [titleString sizeWithFont:font];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    titleSize.width,
                                                                    titleSize.height)];
    titleLabel.text = titleString;
    titleLabel.font = font;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    navItem.titleView = titleLabel;
    [titleLabel release];
}

+ (UIBarButtonItem *)navigationBarBackButtonItemWithTarget:(id)targer andAction:(SEL)action andHeight:(CGFloat)height
{
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  0,
                                                                  height)];
    
    
    UIButton *invisibleButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           buttonView.frame.size.width,
                                                                           buttonView.frame.size.height)];
    [invisibleButton addTarget:targer action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:invisibleButton];
    [invisibleButton release];
    
    
    
    
    
    UIImage *arrowImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackBarButtonArrow" ofType:@"png"]];
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                roundf((height - arrowImage.size.height) / 2),
                                                                                arrowImage.size.width,
                                                                                arrowImage.size.height)];
    arrowImageView.image = arrowImage;
    [arrowImage release];
    
    [buttonView addSubview:arrowImageView];
    [arrowImageView release];
    
    
    
    
    
    
    NSString *titleString = @"Back";
    UIFont *titleFont = [self fontGetRegularFontOfSize:17];
    CGSize titleSize = [titleString sizeWithFont:titleFont];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(arrowImageView.frame.origin.x + arrowImageView.frame.size.width + 4,
                                                                    roundf((height - titleSize.height) / 2),
                                                                    titleSize.width,
                                                                    titleSize.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed:0.0 green:(73.0/256.0) blue:(144.0/256.0) alpha:1];
    titleLabel.font = titleFont;
    titleLabel.text = titleString;
    [buttonView addSubview:titleLabel];
    [titleLabel release];
    
    
    
    
    buttonView.frame = CGRectMake(0,
                                  0,
                                  titleLabel.frame.origin.x + titleLabel.frame.size.width,
                                  buttonView.frame.size.height);
    
    invisibleButton.frame = CGRectMake(0,
                                       0,
                                       buttonView.frame.size.width,
                                       buttonView.frame.size.height);
    
    

    
    
    UIBarButtonItem *backButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:buttonView] autorelease];
    [buttonView release];
    
    return backButtonItem;
}

+ (UIBarButtonItem *)navigationBarButtonItemWithTitle:(NSString *)title andTarget:(id)targer andAction:(SEL)action andHeight:(CGFloat)height
{
    CGFloat horizontalPadding = 5;
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  0,
                                                                  height)];
    
    
    UIButton *invisibleButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           buttonView.frame.size.width,
                                                                           buttonView.frame.size.height)];
    [invisibleButton addTarget:targer action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:invisibleButton];
    [invisibleButton release];
    
    
    
    NSString *titleString = title;
    UIFont *titleFont = [self fontGetRegularFontOfSize:17];
    CGSize titleSize = [titleString sizeWithFont:titleFont];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    roundf((height - titleSize.height) / 2),
                                                                    titleSize.width + horizontalPadding + horizontalPadding,
                                                                    titleSize.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed:0.0 green:(73.0/256.0) blue:(144.0/256.0) alpha:1];
    titleLabel.font = titleFont;
    titleLabel.text = titleString;
    [buttonView addSubview:titleLabel];
    [titleLabel release];
    
    
    
    
    buttonView.frame = CGRectMake(0,
                                  0,
                                  titleLabel.frame.origin.x + titleLabel.frame.size.width,
                                  buttonView.frame.size.height);
    
    invisibleButton.frame = CGRectMake(0,
                                       0,
                                       buttonView.frame.size.width,
                                       buttonView.frame.size.height);
    
    
    
    
    
    UIBarButtonItem *backButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:buttonView] autorelease];
    [buttonView release];
    
    return backButtonItem;
}


+ (UIFont *)fontGetRegularFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"GillSans" size:size];
}

+ (UIFont *)fontGetBoldFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"GillSans-Bold" size:size];
}

+ (UIFont *)fontGetLightFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"GillSans-Light" size:size];
}


- (UIImage *)cacheImageWithCompleteFileName:(NSString *)fileName andAddIfRequired:(BOOL)addIfRequired
{
    UIImage *imageToBeReturned = nil;
    
    if(addIfRequired)
    {

        imageToBeReturned = [self cacheObjectForKey:fileName];
        if(imageToBeReturned == nil)
        {
            NSString *imageExtention = [fileName pathExtension];
            NSString *imageFileNameWithoutExtension = [[fileName lastPathComponent] stringByDeletingPathExtension];
            imageToBeReturned = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageFileNameWithoutExtension ofType:imageExtention]];
//            if (!imageToBeReturned) {
//                imageToBeReturned = [self loadImageFromDocumentsDirectoryWithImageName:fileName];
//            }
            if(fileName && imageToBeReturned)
            {
                [self setCacheObject:imageToBeReturned forKey:fileName];
            }
        
            [imageToBeReturned release];
        }
    }
    else
    {
        imageToBeReturned = [self cacheObjectForKey:fileName];
    }
    
    return imageToBeReturned;
}
- (UIImage*)loadImageFromDocumentsDirectoryWithImageName:(NSString*)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithString: imageName] ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}
- (void)cacheAddImage:(UIImage *)image againstCompleteFileName:(NSString *)fileName
{    
    if(fileName && image)
        [imageDic setValue:image forKey:fileName];
}

- (id)cacheObjectForKey: (id)key
{
    __block obj;
    dispatch_sync(cacheQueue, ^{
        obj = [[imageDic objectForKey:key] retain];
    });
    return [obj autorelease];
}

- (void)setCacheObject: (id)obj forKey: (id)key
{
    dispatch_barrier_async(cacheQueue, ^{
        [imageDic setObject: obj forKey: key];
    });
}


+ (BVTabBarController *)tabBarControllerOfTheApplication
{
    return [(BVAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController];
}




+ (NSString *)stringBystrippngUwantedSpaceAndInvertedCommasInString:(NSString *)inputString
{
    NSString *resultantString = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //Check if the first and the last character of the string are "
    // If true, then remove them
    
    NSString *firstCharacter = [resultantString substringToIndex:1];
    NSString *lastCharacter = [resultantString substringFromIndex:([resultantString length] - 1)];
    
    if([firstCharacter isEqualToString:@"\""] && [lastCharacter isEqualToString:@"\""])
    {
        resultantString = [resultantString substringWithRange:NSMakeRange(1, ([resultantString length] - 2))];
    }
    
    resultantString = [resultantString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return resultantString;
}


+ (NSString *)fileSystemDocumentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString *)fileSystemPathForRelativeDirectoryPath:(NSString *)relativeDirectoryPath
{
    NSString *documentsDirectoryPath = [self fileSystemDocumentsDirectoryPath];
    NSString *featuredRecipesFolderPath = [documentsDirectoryPath stringByAppendingPathComponent:relativeDirectoryPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:featuredRecipesFolderPath])
    {
        NSError *createDirectoryError = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:featuredRecipesFolderPath withIntermediateDirectories:YES attributes:nil error:&createDirectoryError];
        if(!success)
        {
            //TODO: insert log statements
            featuredRecipesFolderPath = nil;
        }
    }
    
    return featuredRecipesFolderPath;
}


+ (BOOL)isThisDeviceA4InchIphone
{
    BOOL is4InchIphone = NO;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568)
    {
        is4InchIphone = YES;
    }
    
    return is4InchIphone;
}



+ (NSString*)getMacAddress
{
    {
        int mgmtInfoBase[6];
        char *msgBuffer = NULL;
        NSString *errorFlag = NULL;
        size_t length;
        
        // Setup the management Information Base (mib)
        mgmtInfoBase[0] = CTL_NET; // Request network subsystem
        mgmtInfoBase[1] = AF_ROUTE; // Routing table info
        mgmtInfoBase[2] = 0;
        mgmtInfoBase[3] = AF_LINK; // Request link layer information
        mgmtInfoBase[4] = NET_RT_IFLIST; // Request all configured interfaces
        
        // With all configured interfaces requested, get handle index
        if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
            errorFlag = @"if_nametoindex failure";
        // Get the size of the data available (store in len)
        else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        // Alloc memory based on above call
        else if ((msgBuffer = malloc(length)) == NULL)
            errorFlag = @"buffer allocation failure";
        // Get system information, store in buffer
        else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
        {
            free(msgBuffer);
            errorFlag = @"sysctl msgBuffer failure";
        }
        else
        {
            // Map msgbuffer to interface message structure
            struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
            
            // Map to link-level socket structure
            struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
            
            // Copy link layer address data in socket structure to an array
            unsigned char macAddress[6];
            memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
            
            // Read from char array into a string object, into traditional Mac address format
            NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                          macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
            // Release the buffer memory
            free(msgBuffer);
            
            return macAddressString;
        }
        
        // Error...
        NSLog(@"Error: %@", errorFlag);
        
        return errorFlag;
    }
    
}
/*
+ (NSString *)getAdvertisingIdentifier
{
    NSString *advertiserID = @"";
    if ([ASIdentifierManager class]) {
        ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
        advertiserID = [[manager advertisingIdentifier] UUIDString];
    }
    return advertiserID;
}

+ (NSString *)getAdvertisingEnabled
{
    BOOL isAdvertisingEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    if (isAdvertisingEnabled == YES)
    {
        return @"YES";
    }
    else
    {
        return @"NO";
    }
}


+ (NSString *)identifierForVendor
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return @"";
}
*/
+ (NSComparisonResult)compareAppVersionLeftString:(NSString *)leftVersion withRightString:(NSString *)rightVersion
{
    int i;
    
    // Break version into fields (separated by '.')
    NSMutableArray *leftFields = [[NSMutableArray alloc] initWithArray:[leftVersion componentsSeparatedByString:@"."]];
    NSMutableArray *rightFields = [[NSMutableArray alloc] initWithArray:[rightVersion componentsSeparatedByString:@"."]];
    
    // Implict ".0" in case version doesn't have the same number of '.'
    if ([leftFields count] < [rightFields count]) {
        while ([leftFields count] != [rightFields count]) {
            [leftFields addObject:@"0"];
        }
    } else if ([leftFields count] > [rightFields count]) {
        while ([leftFields count] != [rightFields count]) {
            [rightFields addObject:@"0"];
        }
    }
    
    // Do a numeric comparison on each field
    for(i = 0; i < [leftFields count]; i++) {
        NSComparisonResult result = [[leftFields objectAtIndex:i] compare:[rightFields objectAtIndex:i] options:NSNumericSearch];
        if (result != NSOrderedSame) {
            [leftFields release];
            [rightFields release];
            return result;
        }
    }
    
    [leftFields release];
    [rightFields release];
    return NSOrderedSame;
}







@end
