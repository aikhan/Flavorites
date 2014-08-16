//
//  BVDropDownMenuView.m
//  BurnettVodka
//
//  Created by admin on 7/31/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVDropDownMenuView.h"
#import "UtilityManager.h"
#import "DataManager.h"
#import "Constants.h"


#define kArrowImageViewOverlapOverBody 2

#define kCenterUsableContentViewHeight 239
#define kCenterUsableContentViewWidth 305
#define kCenterUsableContentCoordinateX 5
#define kCenterUsableContentCoordinateY 22

#define kTableViewRowHeight 37
#define kTableViewCustomSeperatorLeftRightPadding 10

#define kBottomButtonPaddingBottom 5
#define kBottomButtonWidth 90
#define kBottomButtonHeight 23

#define kGapBetweenTableViewAndBottomButtons 8
#define kGapBetweenBottomButtons 6




@implementation BVDropDownItem

@synthesize itemTitle = _itemTitle;
@synthesize isItemSelected = _isItemSelected;

- (void)dealloc {
    
    [_itemTitle release];
    [super dealloc];
}

@end





@implementation BVDropDownMenuView

@synthesize viewDelegate;

- (id)initWithOptions:(NSArray *)arrayOfOptions
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        
        
        mTableData = [arrayOfOptions retain];
        
        
        UIImage *arrowImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DropDownMenuArrow" ofType:@"png"]];
        mArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        arrowImage.size.width,
                                                                        roundf(arrowImage.size.height))];
        mArrowImageView.image = arrowImage;
        [arrowImage release];
        [self addSubview:mArrowImageView];
        
        
        
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DropDownMenuBodyBackground" ofType:@"png"]];
        mBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                             mArrowImageView.frame.origin.y + mArrowImageView.frame.size.height - kArrowImageViewOverlapOverBody,
                                                                             backgroundImage.size.width,
                                                                             backgroundImage.size.height)];
        mBackgroundImageView.image = backgroundImage;
        [backgroundImage release];
        [self addSubview:mBackgroundImageView];
        
        
        // Bring ArrowImageView on top of the background imageview
        [self bringSubviewToFront:mArrowImageView];
        
        
        
        
        
        // ContentView
        mContentView = [[UIView alloc] initWithFrame:CGRectMake(kCenterUsableContentCoordinateX,
                                                                kCenterUsableContentCoordinateY,
                                                                kCenterUsableContentViewWidth,
                                                                kCenterUsableContentViewHeight)];
        mContentView.backgroundColor = [UIColor clearColor];
        [self addSubview:mContentView];
        
        
        
        
        
        
        // Reset Button
        mResetButton = [[UIButton alloc] initWithFrame:CGRectMake(roundf((mContentView.frame.size.width - (kBottomButtonWidth + kGapBetweenBottomButtons + kBottomButtonWidth + kGapBetweenBottomButtons + kBottomButtonWidth)) / 2),
                                                                   mContentView.frame.size.height - kBottomButtonPaddingBottom - kBottomButtonHeight,
                                                                   kBottomButtonWidth,
                                                                   kBottomButtonHeight)];
        [mResetButton setTitle:@"RESET" forState:UIControlStateNormal];
        mResetButton.titleLabel.font = [UtilityManager fontGetRegularFontOfSize:14];
        [mResetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [mResetButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [mResetButton addTarget:self action:@selector(resetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        mResetButton.backgroundColor = [UIColor colorWithRed:(236.0/256.0) green:(0.0/256.0) blue:(139.0/256.0) alpha:1.0];
        [mContentView addSubview:mResetButton];
        
        
        // Cancel Button
        mCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(mResetButton.frame.origin.x + mResetButton.frame.size.width + kGapBetweenBottomButtons,
                                                                   mResetButton.frame.origin.y,
                                                                   kBottomButtonWidth,
                                                                   kBottomButtonHeight)];
        [mCancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        mCancelButton.titleLabel.font = [UtilityManager fontGetRegularFontOfSize:14];
        [mCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [mCancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [mCancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        mCancelButton.backgroundColor = [UIColor colorWithRed:(236.0/256.0) green:(0.0/256.0) blue:(139.0/256.0) alpha:1.0];
        [mContentView addSubview:mCancelButton];
        
        
        // Continue Button
        mContinueButton = [[UIButton alloc] initWithFrame:CGRectMake(mCancelButton.frame.origin.x + mCancelButton.frame.size.width + kGapBetweenBottomButtons,
                                                                     mCancelButton.frame.origin.y,
                                                                     kBottomButtonWidth,
                                                                     kBottomButtonHeight)];
        [mContinueButton setTitle:@"CONTINUE" forState:UIControlStateNormal];
        mContinueButton.titleLabel.font = [UtilityManager fontGetRegularFontOfSize:14];
        [mContinueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [mContinueButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [mContinueButton addTarget:self action:@selector(continueButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        mContinueButton.backgroundColor = [UIColor colorWithRed:(236.0/256.0) green:(0.0/256.0) blue:(139.0/256.0) alpha:1.0];
        [mContentView addSubview:mContinueButton];

        
        if([mTableData count] > 0)
        {
            mTableView = [[UITableView alloc] initWithFrame:CGRectMake(20,
                                                                       0,
                                                                       mContentView.frame.size.width-40,
                                                                       mCancelButton.frame.origin.y - kGapBetweenTableViewAndBottomButtons)];
            mTableView.backgroundColor = [UIColor clearColor];
            mTableView.delegate = self;
            mTableView.dataSource = self;
            mTableView.rowHeight = kTableViewRowHeight;
            mTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                mTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
            }
            mTableView.separatorColor = [UIColor colorWithRed:(94.0/256.0) green:(98.0/256.0) blue:(128.0/256.0) alpha:1];
                                         //colorWithRed:(204.0/256.0) green:(204.0/256.0) blue:(204.0/256.0) alpha:1.0];
            [mContentView addSubview:mTableView];
        }
        else
        {
            NSString *message = @"There are no mixers available to filter with.";
            UIFont *messageFont = [UtilityManager fontGetRegularFontOfSize:14];
            CGSize messageSize = [message sizeWithFont:messageFont];
            mMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCenterUsableContentCoordinateX + 10,
                                                                      kCenterUsableContentCoordinateY + roundf(((mCancelButton.frame.origin.y - kGapBetweenTableViewAndBottomButtons) - messageSize.height) / 2),
                                                                      kCenterUsableContentViewWidth - 10 - 10,
                                                                      messageSize.height)];
            mMessageLabel.backgroundColor = [UIColor clearColor];
            mMessageLabel.textColor = [UIColor whiteColor];
            mMessageLabel.font = messageFont;
            mMessageLabel.text = message;
            mMessageLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:mMessageLabel];
        }
        
        
        

        
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                mBackgroundImageView.frame.size.width,
                                mBackgroundImageView.frame.origin.y + mBackgroundImageView.frame.size.height);
        
    }
    return self;
}

- (void)dealloc {

    [mContentView release];
    [mContinueButton release];
    [mResetButton release];
    [mCancelButton release];
    [mMessageLabel release];
    [mTableData release];
    [mBackgroundImageView release];
    [mArrowImageView release];
    [mTableView release];
    [super dealloc];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [mTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UtilityManager fontGetRegularFontOfSize:18];
    }

    // Configure the cell...
    BVDropDownItem *item = [mTableData objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item.itemTitle;
    if(item.isItemSelected)
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(236.0/256.0) green:(0.0/256.0) blue:(139.0/256.0) alpha:1.0];

//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(40.0/256.0) green:(45.0/256.0) blue:(85.0/256.0) alpha:1.0];
        
        //        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}




#pragma mark - Table view Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    BVDropDownItem *item = [mTableData objectAtIndex:indexPath.row];
    if(item.isItemSelected)
    {
        item.isItemSelected = NO;
        cell.contentView.backgroundColor = [UIColor colorWithRed:(40.0/256.0) green:(45.0/256.0) blue:(85.0/256.0) alpha:1.0];
        
    }
    else
    {
        item.isItemSelected = YES;
        cell.contentView.backgroundColor = [UIColor colorWithRed:(236.0/256.0) green:(0.0/256.0) blue:(139.0/256.0) alpha:1.0];
    }
}


#pragma mark - Public Methods

- (void)showInView:(UIView *)view withArrowPointingAt:(CGPoint)arrowPoint
{
    self.frame = CGRectMake(roundf((view.frame.size.width - self.frame.size.width) / 2),
                            arrowPoint.y,
                            self.frame.size.width,
                            self.frame.size.height);
    
    mArrowImageView.frame = CGRectMake(arrowPoint.x - self.frame.origin.x - roundf(mArrowImageView.frame.size.width / 2),
                                       mArrowImageView.frame.origin.y,
                                       mArrowImageView.frame.size.width,
                                       mArrowImageView.frame.size.height);
    [view addSubview:self];
}

- (NSArray *)arrayOfSelectedItems
{
    NSMutableArray *arrayOfSelectedOptions = [NSMutableArray array];
    
    for(BVDropDownItem *item in mTableData)
    {
        if(item.isItemSelected)
            [arrayOfSelectedOptions addObject:item];
    }
    
    return arrayOfSelectedOptions;
}



#pragma mark - Action Methods

- (void)resetButtonClicked:(id)sender
{
    if([viewDelegate respondsToSelector:@selector(userPressedResetButtonOnDropDownMenuView:withSelectedOptions:)])
    {
        [viewDelegate userPressedResetButtonOnDropDownMenuView:self withSelectedOptions:[self arrayOfSelectedItems]];
    }
    
    for(BVDropDownItem *item in mTableData)
    {
        item.isItemSelected = NO;
    }
    
    [mTableView reloadData];
}

- (void)cancelButtonClicked:(id)sender
{
    if([viewDelegate respondsToSelector:@selector(userPressedCancelButtonOnDropDownMenuView:)])
    {
        [viewDelegate userPressedCancelButtonOnDropDownMenuView:self];
    }
}

- (void)getDateButtonClicked:(id)sender
{
    if([viewDelegate respondsToSelector:@selector(dropDownMenuView:userPressedContinueButtonWithSelectedOptions:)])
    {
        [viewDelegate dropDownMenuView:self userPressedContinueButtonWithSelectedOptions:[self arrayOfSelectedItems]];
    }
}

- (void)continueButtonClicked:(id)sender
{
    if([viewDelegate respondsToSelector:@selector(dropDownMenuView:userPressedContinueButtonWithSelectedOptions:)])
    {
        [viewDelegate dropDownMenuView:self userPressedContinueButtonWithSelectedOptions:[self arrayOfSelectedItems]];
    }
}



@end
