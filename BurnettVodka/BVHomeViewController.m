//
//  BVHomeViewController.m
//  BurnettVodka
//
//  Created by admin on 6/28/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVHomeViewController.h"
#import "FeaturedRecipeItem.h"
#import "BVRecipesForFlavorViewController.h"
#import "DataManager.h"
#import "UtilityManager.h"
#import "Constants.h"
#import "Flavor.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

#define kFeaturedRecipeCardMaxHeight3Point5InchScreen 294
#define kFeaturedRecipeCardMaxHeight4InchScreen 300

#define kHeightOfTitleTextInBackgroundImage 100

#define UIColorFromRGB(rgbValue) [UIColor \
                  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                  green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@interface BVHomeViewController ()

- (void)loadUserInterface;
- (void)loadRecipesFromDiskAndShowInScrollView;

@end

@implementation BVHomeViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    
    }
    return self;
}

- (void)loadView {
    
    [super loadView];
    
    self.view.frame = CGRectMake(0,
                                 0,
                                 self.navigationController.view.frame.size.width,
                                 self.navigationController.view.frame.size.height);
    [self.view retain];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadUserInterface];
    [self loadRecipesFromDiskAndShowInScrollView];
    mScrollView.contentOffset = CGPointMake(0,0);
    Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(onTimer) userInfo: nil repeats: YES];
    ScroolFl=FALSE;
}

- (void) viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.screenName = @"Home Screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    return;
    NSLog(@"Home View Coontroller is released");
  //  [mBackgroundImageView release];
    [mScrollView release];
    [Scrolltimer release];
    [super dealloc];
}



#pragma mark - UI Methods

- (void)loadUserInterface
{
    CGFloat iOS7OffsetAdjustmentForStatusBar = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        iOS7OffsetAdjustmentForStatusBar = 0;
    }
    
    
    // Background Image View
    [mBackgroundImageView removeFromSuperview];
    [mBackgroundImageView release];
    mBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                         0 + iOS7OffsetAdjustmentForStatusBar,
                                                                         self.view.frame.size.width,
                                                                         self.view.frame.size.height)];
    
   
    
    NSString *backgroundImageFileName = @"";
    if([UtilityManager isThisDeviceA4InchIphone])
    {
        backgroundImageFileName = @"burnett_home_datestring_4inch.png";
    }
    else
    {
        backgroundImageFileName = @"burnett_home_datestring.png";
    }
    
    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:backgroundImageFileName andAddIfRequired:YES];
    mBackgroundImageView.image = backgroundImage;
    mBackgroundImageView.contentMode = UIViewContentModeTop;
    [self.view addSubview:mBackgroundImageView];
    
    
    
    CGFloat heightOfScrollView = kFeaturedRecipeCardMaxHeight3Point5InchScreen;
    if([UtilityManager isThisDeviceA4InchIphone])
    {
        heightOfScrollView = kFeaturedRecipeCardMaxHeight4InchScreen;
    }
    
    CGFloat heightLeftAfterTitleTextInBackground = self.view.frame.size.height - kHeightOfTitleTextInBackgroundImage - iOS7OffsetAdjustmentForStatusBar;
        
    mScrollView = [[BVCoverFlowScrollView alloc] initWithFrame:CGRectMake(0,
                                                                          iOS7OffsetAdjustmentForStatusBar +  kHeightOfTitleTextInBackgroundImage + roundf((heightLeftAfterTitleTextInBackground - heightOfScrollView) / 2)-20,
                                                                          self.view.frame.size.width,
                                                                          heightOfScrollView)];
    mScrollView.delegate = self;
    mScrollView.coverFlowDelegate = self;
    [mScrollView setCanCancelContentTouches:YES];
    [self.view addSubview:mScrollView];
    
}


- (void)loadRecipesFromDiskAndShowInScrollView
{
    NSMutableArray *mutableArrayOfFeaturedItems = [NSMutableArray array];
    
    
    NSArray *featuredRecipesLatest = [[DataManager sharedDataManager] featuredRecipesLatest];
    for(NSDictionary *recipeDic in featuredRecipesLatest)
    {
        FeaturedRecipeItem *item = [[FeaturedRecipeItem alloc] init];
        
        NSString *imagePath = [recipeDic valueForKey:@"drink_image"];
        NSString *imageExtention = [imagePath pathExtension];
        NSString *imageFileNameWithoutExtension = [[imagePath lastPathComponent] stringByDeletingPathExtension];
        UIImage *flavorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageFileNameWithoutExtension ofType:imageExtention]];
        imageFileNameWithoutExtension = [NSString stringWithFormat:@"%@.%@",imageFileNameWithoutExtension,imageExtention];
        if (!flavorImage) {
            imageFileNameWithoutExtension = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:[imagePath lastPathComponent]];
        }
        NSString *isnew = [NSString stringWithFormat:@"%@",[recipeDic valueForKey:@"isnew"]];
        if ([isnew isEqualToString:@"1"]) {
            item.isNewimg=TRUE;
        }
        else {
            item.isNewimg=FALSE;
        }
        item.imageFilePath = imageFileNameWithoutExtension;
        item.recipeID = [[recipeDic valueForKey:@"id"] integerValue];

        [mutableArrayOfFeaturedItems addObject:item];
        [item release];
    }
    
    if([mutableArrayOfFeaturedItems count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Error Loading Featured Items" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    [mScrollView resetScrollViewWithRecipesArray:[NSArray arrayWithArray:mutableArrayOfFeaturedItems]];
    
}

-(void) onTimer {
    if (mScrollView.contentOffset.x<mScrollView.contentSize.width-[[UIScreen mainScreen] bounds].size.width) {
        mScrollView.contentOffset = CGPointMake(mScrollView.contentOffset.x+0.5,0);
    }
    else {
        [Scrolltimer invalidate];
        Scrolltimer=Nil;
        Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(onTimer2) userInfo: nil repeats: YES];
    }
}

-(void)onTimer2 {
    if (mScrollView.contentOffset.x>0) {
        mScrollView.contentOffset = CGPointMake(mScrollView.contentOffset.x-0.5,0);
    }
    else {
        [Scrolltimer invalidate];
        Scrolltimer = Nil;
        Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(onTimer) userInfo: nil repeats: YES];
    }
}


#pragma mark - UIScrollView Delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // [mScrollView scrollViewScrolled];
}



#pragma mark - BVCoverFlowScrollView Delegate methods

- (void)coverFlowScrollView:(BVCoverFlowScrollView *)scrollView userTappedWithRecipeID:(NSInteger)recipeID
{
    int count=0;
    int finalCount=0;;

    NSMutableArray *mutableArrayOfFeaturedItems = [NSMutableArray array];
    NSArray *featuredRecipesLatest = [[DataManager sharedDataManager] featuredRecipesLatest];
    
    for(NSDictionary *recipeDic in featuredRecipesLatest)
    {
        count++;
        NSString *fileName = [recipeDic valueForKey:@"id"];
        if ([fileName integerValue]==recipeID) {
            if ([fileName integerValue]==checkOldDesc) {
                if (ScroolFl==TRUE) {
                    [self crosstg];
                    
                    return;
                }
            }
            else {
                finalCount=count;
                FeaturedRecipeItem *item = [[FeaturedRecipeItem alloc] init];
                NSString *imagePath = [recipeDic valueForKey:@"drink_image"];
                NSString *imageExtention1 = [imagePath pathExtension];
                NSString *imageFileNameWithoutExtension1 = [[imagePath lastPathComponent] stringByDeletingPathExtension];
                UIImage *flavorImage1 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageFileNameWithoutExtension1 ofType:imageExtention1]];
                imageFileNameWithoutExtension1 = [NSString stringWithFormat:@"%@.%@",imageFileNameWithoutExtension1,imageExtention1];
                if (!flavorImage1) {
                    
                    imageFileNameWithoutExtension1 = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:[imagePath lastPathComponent]];
                }
                NSString *isnew = [NSString stringWithFormat:@"%@",[recipeDic valueForKey:@"isnew"]];
                if ([isnew isEqualToString:@"1"]) {
                    item.isNewimg=TRUE;
                }
                else {
                    item.isNewimg=FALSE;
                }
                item.imageFilePath = imageFileNameWithoutExtension1;
                item.recipeID = [[recipeDic valueForKey:@"id"] integerValue];
                checkOldDesc = item.recipeID;
                [mutableArrayOfFeaturedItems addObject:item];
                [item release];
                RecipeDescription = [[BVRecipeDescriptionView alloc] initWithFrame:CGRectMake(-10,0/*
                                                                                                  [UIScreen mainScreen].bounds.size.width/2-750, [UIScreen mainScreen].bounds.size.height/2-170*/, 130, 340)];
                [RecipeDescription.Heading setText:[NSString stringWithFormat:@"%@",[recipeDic valueForKey:@"drink_name"]]];
                NSString *str123 = [NSString stringWithFormat:@"%@",[recipeDic valueForKey:@"drink_name"]];
                NSLog(@"%d",str123.length);
                [RecipeDescription.Heading setFont:[UtilityManager fontGetRegularFontOfSize:18]];
                if (str123.length>18 && str123.length<30) {
                    [RecipeDescription.Heading setFont:[UtilityManager fontGetRegularFontOfSize:15]];
                }
                else if (str123.length>29) {
                    [RecipeDescription.Heading setFont:[UtilityManager fontGetRegularFontOfSize:12]];
                }
                NSString *str = [NSString stringWithFormat:@"\u2022 %@",[recipeDic valueForKey:@"ingredients"]];
                str = [str stringByReplacingOccurrencesOfString:@"\n" withString:[NSString stringWithFormat:@"\n\u2022 "]];
                str = [str stringByReplacingOccurrencesOfString:@"Burnett's " withString:[NSString stringWithFormat:@""]];
                
                //Attributed String
                UIFont *myFont = [UtilityManager fontGetBoldFontOfSize:13];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.headIndent = 7;
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:str attributes:@{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:myFont }];
                [RecipeDescription.Ingredients setAttributedText:attributedString];
                RecipeDescription.Ingredients.textColor = [UIColor whiteColor];
                
                //Bottle Title Background Color
                NSString *stringColor = [NSString stringWithFormat:@"%@",[recipeDic valueForKey:@"color"]];
                UIColor *color = SKColorFromHexString(stringColor);
                RecipeDescription.titleBackImageView.backgroundColor = color;
                //RecipeDescription.Heading.textColor = color;
                
                //[RecipeDescription.Ingredients setFont:[UtilityManager fontGetBoldFontOfSize:13]];
                [RecipeDescription textViewDidChange:RecipeDescription.Ingredients];
                [RecipeDescription.Procedure setText:[NSString stringWithFormat:@"%@",[recipeDic valueForKey:@"directions"]]];
                [RecipeDescription.Procedure setFont:[UtilityManager fontGetBoldFontOfSize:13]];
                NSString *imagePath1 = [recipeDic valueForKey:@"recipeimage"];
                NSString *imageExtention = [imagePath1 pathExtension];
                NSString *imageFileNameWithoutExtension = [[imagePath1 lastPathComponent] stringByDeletingPathExtension];
                imageFileNameWithoutExtension = [imageFileNameWithoutExtension lowercaseString];
                UIImage *flavorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageFileNameWithoutExtension ofType:imageExtention]];
                if (!flavorImage) {
                    
                    flavorImage = [self loadImageFromDocumentsDirectoryWithImageName:imageFileNameWithoutExtension];
                    
                }
                [RecipeDescription.RecipeTmg setImage:flavorImage];
                [RecipeDescription.LoadmoreBtn addTarget:self
                                                  action:@selector(ViewMore:)
                                        forControlEvents:UIControlEventTouchUpInside];
                [RecipeDescription.Crossbtn addTarget:self
                                               action:@selector(CrossTarget:)
                                     forControlEvents:UIControlEventTouchUpInside];
                [RecipeDescription.LoadmoreBtn setTag:recipeID];
                [mutableArrayOfFeaturedItems addObject:RecipeDescription];
            }
        }
        else {
            FeaturedRecipeItem *item = [[FeaturedRecipeItem alloc] init];
            NSString *imagePath = [recipeDic valueForKey:@"drink_image"];
            NSString *imageExtention = [imagePath pathExtension];
            NSString *imageFileNameWithoutExtension = [[imagePath lastPathComponent] stringByDeletingPathExtension];
            UIImage *flavorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageFileNameWithoutExtension ofType:imageExtention]];
            imageFileNameWithoutExtension = [NSString stringWithFormat:@"%@.%@",imageFileNameWithoutExtension,imageExtention];
            if (!flavorImage) {
                
                imageFileNameWithoutExtension = [[UtilityManager fileSystemPathForRelativeDirectoryPath:kDirectoryNameForFeaturedRecipesData] stringByAppendingPathComponent:[imagePath lastPathComponent]];
            }
            NSString *isnew = [NSString stringWithFormat:@"%@",[recipeDic valueForKey:@"isnew"]];
            if ([isnew isEqualToString:@"1"]) {
                item.isNewimg=TRUE;
            }
            else {
                item.isNewimg=FALSE;
            }
            item.imageFilePath = imageFileNameWithoutExtension;
            item.recipeID = [[recipeDic valueForKey:@"id"] integerValue];
            [mutableArrayOfFeaturedItems addObject:item];
            [item release];
        }
    }
    [mScrollView resetScrollViewWithRecipesArray:[NSArray arrayWithArray:mutableArrayOfFeaturedItems]];
    [mScrollView setContentOffset:CGPointMake((110*(finalCount-1))+(10*(finalCount-1)) - 7 ,[UIScreen mainScreen].bounds.origin.y)];
    if (ScroolFl==FALSE) {
        [Scrolltimer invalidate];
        ScroolFl=TRUE;
    }
}

//String to Hex Code Methods
void SKScanHexColor(NSString * hexString, float * red, float * green, float * blue, float * alpha) {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    if (red) { *red = ((baseValue >> 24) & 0xFF)/255.0f; }
    if (green) { *green = ((baseValue >> 16) & 0xFF)/255.0f; }
    if (blue) { *blue = ((baseValue >> 8) & 0xFF)/255.0f; }
    if (alpha) { *alpha = ((baseValue >> 0) & 0xFF)/255.0f; }
}

UIColor * SKColorFromHexString(NSString * hexString) {
    float red, green, blue, alpha;
    SKScanHexColor(hexString, &red, &green, &blue, &alpha);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)crosstg {
    ScroolFl=FALSE;
    checkOldDesc = 0;
    [RecipeDescription removeFromSuperview];
    [self loadRecipesFromDiskAndShowInScrollView];
    Scrolltimer = Nil;
    Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(onTimer) userInfo: nil repeats: YES];
}

-(void)CrossTarget:(id)sender {
    ScroolFl=FALSE;
    checkOldDesc = 0;
    [RecipeDescription removeFromSuperview];
    [self loadRecipesFromDiskAndShowInScrollView];
    Scrolltimer = Nil;
    Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(onTimer) userInfo: nil repeats: YES];
}

- (void)ViewMore:(id)Sender {
    NSUInteger recipeID = [Sender tag];
    Flavor *flavor = nil;
    if(recipeID != 0)
    {
        Recipe *recipeObject = [[DataManager sharedDataManager] recipesGetRecipeWithRecipeID:recipeID];
        //flavor = recipeObject.flavor;
        flavor = [[DataManager sharedDataManager] flavorsGetFlavorWithFlavorID:recipeID];
    }
    else
    {
        flavor = [[DataManager sharedDataManager] flavorsGetFlavorWithFlavorTitle:@"Pumpkin Spice"];
    }
    NSString *event = @"home";
    NSString *value = [[NSString stringWithFormat:@"%@", flavor.title] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Flurry logEvent:event withParameters:[NSDictionary dictionaryWithObject:value forKey:event]];
    id<GAITracker> tracker= [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"home"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];    // Event value
    
    
    BVRecipesForFlavorViewController *viewController = [[BVRecipesForFlavorViewController alloc] initWithFlavor:flavor];
    [self.navigationController pushViewController:viewController animated:NO];
    [viewController release];
    ScroolFl=FALSE;
    checkOldDesc = 0;
    [RecipeDescription removeFromSuperview];
    [self loadRecipesFromDiskAndShowInScrollView];
    Scrolltimer = Nil;
    Scrolltimer = [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(onTimer) userInfo: nil repeats: YES];
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

#pragma mark - Public methods

- (void)reload
{
    [self loadRecipesFromDiskAndShowInScrollView];
}

@end
