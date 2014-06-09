//
//  BVHTMLContentViewController.m
//  BurnettVodka
//
//  Created by admin on 9/24/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVHTMLContentViewController.h"
#import "UtilityManager.h"
#import "Constants.h"

@interface BVHTMLContentViewController ()

@end

@implementation BVHTMLContentViewController

- (id)initWithHTMLString:(NSString *)htmlString
{
    self = [super init];
    if(self)
    {
        mHTMLString = [htmlString copy];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 // iOS 7.0 supported
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
#endif
    }
    return self;
}


- (void)loadView {
    
    [super loadView];
    
    CGFloat iOS7OffsetAdjustmentForStatusBar = 0;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        iOS7OffsetAdjustmentForStatusBar = 20;
    }
    
    self.view.frame = CGRectMake(0,
                                 0,
                                 self.navigationController.view.frame.size.width,
                                 self.navigationController.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - iOS7OffsetAdjustmentForStatusBar);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [UtilityManager addTitle:@"Privacy Policy" toNavigationItem:self.navigationItem];
    
    
    UIBarButtonItem *shareButton = [UtilityManager navigationBarButtonItemWithTitle:@"Close" andTarget:self andAction:@selector(close:) andHeight:self.navigationController.navigationBar.frame.size.height];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    mWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                           0,
                                                           self.view.frame.size.width,
                                                           self.view.frame.size.height)];
    [self.view addSubview:mWebView];
    
    [mWebView loadHTMLString:mHTMLString baseURL:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.screenName = @"Privacy View";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [mHTMLString release];
    [mWebView release];
    [super dealloc];
}


- (void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
