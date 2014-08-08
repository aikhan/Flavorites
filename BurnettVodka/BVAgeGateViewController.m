

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
    [rememberButton release];
    [datelbl release];
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
    
    
    UIImage *DateofBirth = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"enterdob.png" andAddIfRequired:YES];
    UIImageView *DateofBirthView = [[UIImageView alloc] initWithFrame:CGRectMake(roundf((self.view.frame.size.width - DateofBirth.size.width) / 2),
                                                                                 0,
                                                                                 DateofBirth.size.width,
                                                                                 DateofBirth.size.height)];
    DateofBirthView.image = DateofBirth;
    [self.view addSubview:DateofBirthView];
    [DateofBirthView release];
    
    UIImage *GetDateButtonImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"getDate.png" andAddIfRequired:YES];
    
    UIButton *GetDateButton = [[UIButton alloc] initWithFrame:CGRectMake(roundf((self.view.frame.size.width - GetDateButtonImage.size.width) / 2),
                                                                         0,
                                                                         GetDateButtonImage.size.width,
                                                                         GetDateButtonImage.size.height)];
    [GetDateButton setImage:GetDateButtonImage forState:UIControlStateNormal];
    [GetDateButton addTarget:self action:@selector(getDateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:GetDateButton];
    [GetDateButton release];
    
    NSString *instructionText2 = @"When were you born?";
    UIFont *instructionText2Font = [UtilityManager fontGetRegularFontOfSize:24];
    CGSize instructionTextSize2 = [instructionText2 sizeWithFont:instructionText2Font];
    
    datelbl = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                        0,
                                                        self.view.frame.size.width,
                                                        instructionTextSize2.height)];
    datelbl.font = instructionText2Font;
    datelbl.backgroundColor = [UIColor clearColor];
    datelbl.textColor = [UIColor colorWithRed:(256.0) green:(256.0) blue:(256.0) alpha:1.0];
    datelbl.text = instructionText2;
    datelbl.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:datelbl];
    [datelbl release];
    
    
    UIImage *remeberButtonImage = [[UtilityManager sharedUtilityManager] cacheImageWithCompleteFileName:@"remember.png" andAddIfRequired:YES];
    
    rememberButton = [[UIButton alloc] initWithFrame:CGRectMake(roundf((self.view.frame.size.width - remeberButtonImage.size.width) / 2),
                                                                0,
                                                                remeberButtonImage.size.width,
                                                                remeberButtonImage.size.height)];
    [rememberButton setImage:remeberButtonImage forState:UIControlStateNormal];
    [rememberButton addTarget:self action:@selector(rememberButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rememberButton];
    
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
    
    // Rearrange Frames
    
    CGFloat yCoordinateForDatePicker = kDatePickerCoordinateY;
    if([UtilityManager isThisDeviceA4InchIphone])
    {
        yCoordinateForDatePicker = kDatePickerCoordinateY_4Inch;
    }
    
    
    // Adjustment for supporting iOS 7 status bar problem
    yCoordinateForDatePicker = yCoordinateForDatePicker + iOS7OffsetAdjustmentForStatusBar;
    
    continueButton.frame = CGRectMake(continueButton.frame.origin.x,
                                      self.view.frame.size.height*0.75,
                                      continueButton.frame.size.width,
                                      continueButton.frame.size.height);
    
    GetDateButton.frame = CGRectMake(GetDateButton.frame.origin.x,
                                     self.view.frame.size.height*0.5,
                                     GetDateButton.frame.size.width,
                                     GetDateButton.frame.size.height);
    
    datelbl.frame = CGRectMake(self.view.frame.origin.x-30,
                                     self.view.frame.size.height*0.52,
                                     datelbl.frame.size.width,
                                     datelbl.frame.size.height);

    
    DateofBirthView.frame = CGRectMake(DateofBirthView.frame.origin.x,
                                       self.view.frame.size.height*0.35,
                                       DateofBirthView.frame.size.width,
                                       DateofBirthView.frame.size.height);
    
    rememberButton.frame = CGRectMake(rememberButton.frame.origin.x,
                                      self.view.frame.size.height*0.63,
                                      rememberButton.frame.size.width,
                                      rememberButton.frame.size.height);
    
    
    logoImageView.frame =CGRectMake(logoImageView.frame.origin.x,
                                    self.view.frame.size.height*0.15,
                                    logoImageView.frame.size.width,
                                    logoImageView.frame.size.height);
}

#pragma mark - Action Methods

- (void)getDateButtonClicked:(id)sender
{
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
    
    UIAlertView *setBirthDate = [[UIAlertView alloc] initWithTitle:@"Date of Birth:"
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Set", nil];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [setBirthDate setValue:mDatePickerView forKey:@"accessoryView"];
    }
    
    [setBirthDate addSubview:mDatePickerView];
    [setBirthDate show];
    mDatePickerView.frame = CGRectMake(setBirthDate.frame.origin.x+5,
                                       setBirthDate.frame.origin.y,
                                       mDatePickerView.frame.size.width,
                                       mDatePickerView.frame.size.height);
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        NSString *datestr = [NSString stringWithFormat:@"%@",mDatePickerView.date];
        NSArray *datearr = [datestr componentsSeparatedByString:@" "];
        datelbl.text = [NSString stringWithFormat:@"%@",[datearr firstObject]];
    }
}

- (void)rememberButtonClicked:(id)sender
{
    
}

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
