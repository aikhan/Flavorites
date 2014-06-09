//
//  BVAgeGateViewController.m
//  BurnettVodka
//
//  Created by admin on 8/15/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVAgeGateViewController.h"
#import "UtilityManager.h"
#import "Constants.h"
#import "BVHTMLContentViewController.h"


#define kDatePickerCoordinateY 160
#define kDatePickerCoordinateY_4Inch 210

#define kGapBetweenDatePickerAndLegalMessage 5
#define kGapBetweenLegalMessageAndBirthdayMessage 2
#define kGapBetweenBirthdayMessageAndLogo 0
#define kGapBetweenDatePickerAndContinueButton 5
#define kGapBetweenContinueButtonAndBottomButtons 5



@interface BVAgeGateViewController ()

- (void)loadUserInterface;

@end

@implementation BVAgeGateViewController

@synthesize controllerDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadUserInterface];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.screenName = @"Gate View";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    
    [mDatePickerView release];
    [mBackgroundImageView release];
    [super dealloc];
}





#pragma mark - UI Methods

- (void)loadUserInterface
{
    CGFloat iOS7OffsetAdjustmentForStatusBar = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        iOS7OffsetAdjustmentForStatusBar = 20;
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
        backgroundImageFileName = @"AgeGateBackground_4inch.png";
    }
    else
    {
        backgroundImageFileName = @"AgeGateBackground.png";
    }
    
    UIImage *backgroundImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:backgroundImageFileName andAddIfRequired:YES];
    mBackgroundImageView.image = backgroundImage;
    mBackgroundImageView.contentMode = UIViewContentModeTop;
    [self.view addSubview:mBackgroundImageView];
    
    
    
    
    
    // Create Burnett Flavorite Occasion Logo
    UIImage *logoImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"BurnettFlavoriteOccasionLogo.png" andAddIfRequired:YES];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(roundf((self.view.frame.size.width - logoImage.size.width) / 2),
                                                                               0,
                                                                               logoImage.size.width,
                                                                               logoImage.size.height)];
    logoImageView.image = logoImage;
    [self.view addSubview:logoImageView];
    [logoImageView release];
    
    
    
    
    // Label for Enter Your Birthday
    NSString *instructionText1 = @"Enter Your Birthday";
    UIFont *instructionText1Font = [UtilityManager fontGetRegularFontOfSize:24];
    CGSize instructionTextSize1 = [instructionText1 sizeWithFont:instructionText1Font];
    UILabel *instructionLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           self.view.frame.size.width,
                                                                           instructionTextSize1.height)];
    instructionLabel1.font = instructionText1Font;
    instructionLabel1.backgroundColor = [UIColor clearColor];
    instructionLabel1.textColor = [UIColor blackColor];
    instructionLabel1.text = instructionText1;
    instructionLabel1.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:instructionLabel1];
    [instructionLabel1 release];
    
    
    
    
    
    // Label for Legal Age Message
    NSString *instructionText2 = @"You must be of legal drinking age to use this app";
    UIFont *instructionText2Font = [UtilityManager fontGetRegularFontOfSize:13];
    CGSize instructionTextSize2 = [instructionText2 sizeWithFont:instructionText2Font];
    UILabel *instructionLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           self.view.frame.size.width,
                                                                           instructionTextSize2.height)];
    instructionLabel2.font = instructionText2Font;
    instructionLabel2.backgroundColor = [UIColor clearColor];
    instructionLabel2.textColor = [UIColor colorWithRed:(105.0/256.0) green:(127.0/256.0) blue:(147.0/256.0) alpha:1.0];
    instructionLabel2.text = instructionText2;
    instructionLabel2.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:instructionLabel2];
    [instructionLabel2 release];
    
    
    
    
    // Continue Button
    UIImage *continueButtonImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"AgeGateContinueButton.png" andAddIfRequired:YES];
    
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(roundf((self.view.frame.size.width - continueButtonImage.size.width) / 2),
                                                                          0,
                                                                          continueButtonImage.size.width,
                                                                          continueButtonImage.size.height)];
    [continueButton setImage:continueButtonImage forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    [continueButton release];
    
    
    
    // UIPicker View
    [mDatePickerView removeFromSuperview];
    [mDatePickerView release];
    mDatePickerView = [[UIDatePicker alloc] init];
    mDatePickerView.date = [NSDate date];
    mDatePickerView.datePickerMode = UIDatePickerModeDate;
    
    
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    
    NSDateComponents *componentsForStartingDate = [[NSDateComponents alloc] init];
    [componentsForStartingDate setDay:1];
    [componentsForStartingDate setMonth:1];
    [componentsForStartingDate setYear:1992];
    NSDate *startingDate = [gregorian dateFromComponents:componentsForStartingDate];
    mDatePickerView.date = startingDate;
    [componentsForStartingDate release];
    
    
    
    
    NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentYear = [currentDateComponents year];
    
    NSDateComponents *componentsForMaxDate = [[NSDateComponents alloc] init];
    [componentsForMaxDate setDay:31];
    [componentsForMaxDate setMonth:12];
    [componentsForMaxDate setYear:currentYear];
    NSDate *maxDate = [gregorian dateFromComponents:componentsForMaxDate];
    mDatePickerView.maximumDate = maxDate;
    [componentsForMaxDate release];
    

    [self.view addSubview:mDatePickerView];
    
    
    
    
    
    
    // Bottom Privacy Button
    CGFloat privacyButtonPadding = 3;
    NSString *privacyString = @"Privacy Policy";
    UIFont *privacyFont = [UtilityManager fontGetRegularFontOfSize:13];
    CGSize privacySize = [privacyString sizeWithFont:privacyFont];
    UIButton *privacyButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         privacySize.width + privacyButtonPadding + privacyButtonPadding,
                                                                         privacySize.height + privacyButtonPadding + privacyButtonPadding)];
    [privacyButton setTitle:privacyString forState:UIControlStateNormal];
    privacyButton.titleLabel.font = privacyFont;
    [privacyButton setTitleColor:[UIColor colorWithRed:(105.0/256.0) green:(127.0/256.0) blue:(147.0/256.0) alpha:1.0] forState:UIControlStateNormal];
    [privacyButton addTarget:self action:@selector(privacyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:privacyButton];
    [privacyButton release];
    
    
    
    // Bottom Button Seperator Label
    NSString *seperatorText = @"   |   ";
    UIFont *seperatorFont = [UtilityManager fontGetRegularFontOfSize:13];
    CGSize seperatorSize = [seperatorText sizeWithFont:seperatorFont];
    UILabel *seperatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        seperatorSize.width,
                                                                        seperatorSize.height)];
    seperatorLabel.font = seperatorFont;
    seperatorLabel.backgroundColor = [UIColor clearColor];
    seperatorLabel.textColor = [UIColor colorWithRed:(105.0/256.0) green:(127.0/256.0) blue:(147.0/256.0) alpha:1.0];
    seperatorLabel.text = seperatorText;
    [self.view addSubview:seperatorLabel];
    [seperatorLabel release];
    
    
    
    
    // Bottom Responsible Button
    CGFloat responsibleButtonPadding = 3;
    NSString *responsibleString = @"Think Wisely. Drink Wisely.";
    UIFont *responsibleFont = [UtilityManager fontGetRegularFontOfSize:13];
    CGSize responsibleSize = [responsibleString sizeWithFont:responsibleFont];
    UIButton *responsibleButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                             0,
                                                                             responsibleSize.width + responsibleButtonPadding + responsibleButtonPadding,
                                                                             responsibleSize.height + responsibleButtonPadding + responsibleButtonPadding)];
    [responsibleButton setTitle:responsibleString forState:UIControlStateNormal];
    responsibleButton.titleLabel.font = responsibleFont;
    [responsibleButton setTitleColor:[UIColor colorWithRed:(105.0/256.0) green:(127.0/256.0) blue:(147.0/256.0) alpha:1.0] forState:UIControlStateNormal];
    [responsibleButton addTarget:self action:@selector(responsibleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:responsibleButton];
    [responsibleButton release];
    
    
    
    
    

    
    
    // Rearrange Frames
    
    CGFloat yCoordinateForDatePicker = kDatePickerCoordinateY;
    if([UtilityManager isThisDeviceA4InchIphone])
    {
        yCoordinateForDatePicker = kDatePickerCoordinateY_4Inch;
    }
    
    
    // Adjustment for supporting iOS 7 status bar problem
    yCoordinateForDatePicker = yCoordinateForDatePicker + iOS7OffsetAdjustmentForStatusBar;
    
    mDatePickerView.frame = CGRectMake(roundf((self.view.frame.size.width - mDatePickerView.frame.size.width) / 2),
                                       yCoordinateForDatePicker,
                                       mDatePickerView.frame.size.width,
                                       mDatePickerView.frame.size.height);
    
    continueButton.frame = CGRectMake(continueButton.frame.origin.x,
                                      mDatePickerView.frame.origin.y + mDatePickerView.frame.size.height + kGapBetweenDatePickerAndContinueButton,
                                      continueButton.frame.size.width,
                                      continueButton.frame.size.height);
    
    
    privacyButton.frame = CGRectMake(roundf((self.view.frame.size.width - (privacyButton.frame.size.width + seperatorLabel.frame.size.width + responsibleButton.frame.size.width)) / 2),
                                     continueButton.frame.origin.y + continueButton.frame.size.height + kGapBetweenContinueButtonAndBottomButtons,
                                     privacyButton.frame.size.width,
                                     privacyButton.frame.size.height);
    
    
    seperatorLabel.frame = CGRectMake(privacyButton.frame.origin.x + privacyButton.frame.size.width,
                                      privacyButton.frame.origin.y,
                                      seperatorLabel.frame.size.width,
                                      seperatorLabel.frame.size.height);
    
    
    responsibleButton.frame = CGRectMake(seperatorLabel.frame.origin.x + seperatorLabel.frame.size.width,
                                         privacyButton.frame.origin.y,
                                         responsibleButton.frame.size.width,
                                         responsibleButton.frame.size.height);
    
    
    instructionLabel2.frame = CGRectMake(instructionLabel2.frame.origin.x,
                                         mDatePickerView.frame.origin.y - kGapBetweenDatePickerAndLegalMessage - instructionLabel2.frame.size.height,
                                         instructionLabel2.frame.size.width,
                                         instructionLabel2.frame.size.height);
    
    instructionLabel1.frame = CGRectMake(instructionLabel1.frame.origin.x,
                                         instructionLabel2.frame.origin.y - kGapBetweenLegalMessageAndBirthdayMessage - instructionLabel1.frame.size.height,
                                         instructionLabel1.frame.size.width,
                                         instructionLabel1.frame.size.height);
    
    logoImageView.frame = CGRectMake(logoImageView.frame.origin.x,
                                         instructionLabel1.frame.origin.y - kGapBetweenBirthdayMessageAndLogo - logoImageView.frame.size.height,
                                         logoImageView.frame.size.width,
                                         logoImageView.frame.size.height);
    
}




#pragma mark - Action Methods

- (void)continueButtonClicked:(id)sender
{
    NSInteger legalAge = 21;
    
    
    
    NSDate* birthday = mDatePickerView.date;
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    
    if(age >= legalAge)
    {
        
        if([controllerDelegate respondsToSelector:@selector(userDeterminedAsLegalOnBVAgeGateViewController:)])
        {
            [controllerDelegate userDeterminedAsLegalOnBVAgeGateViewController:self];
        }
    }
    else
    {
        NSURL *url = [NSURL URLWithString:@"http://www.centurycouncil.org/"];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)privacyButtonTapped:(id)sender
{
    NSString *htmlContent = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PrivacyPolicy" ofType:@"html"] encoding:4 error:nil];
    BVHTMLContentViewController *viewController = [[BVHTMLContentViewController alloc] initWithHTMLString:htmlContent];
    [htmlContent release];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [viewController release];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
    [navController release];
}

- (void)responsibleButtonTapped:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://www.heavenhill.com/responsibility-statement"];
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
