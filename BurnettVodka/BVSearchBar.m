//
//  BVSearchBar.m
//  BurnettVodka
//
//  Created by admin on 7/23/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVSearchBar.h"
#import "UtilityManager.h"

#define kPaddingLeft 8

#define kGapBetweenSearchIconAndTextField 5
#define kGapBetweenTextFieldAndCancelButton 5


@interface BVSearchBar ()

@end


@implementation BVSearchBar

@synthesize searchDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeTabSearchBarBackground" ofType:@"png"]];
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                backgroundImage.size.width,
                                backgroundImage.size.height);
        
        
        
        mBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                             0,
                                                                             self.frame.size.width,
                                                                             self.frame.size.height)];
        mBackgroundImageView.image = backgroundImage;
        [backgroundImage release];
        
        [self addSubview:mBackgroundImageView];
        
        
        
        
        
        UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeTabSearchBarIcon" ofType:@"png"]];
        mIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeft,
                                                                       roundf((self.frame.size.height - iconImage.size.height) / 2),
                                                                       iconImage.size.width,
                                                                       iconImage.size.height)];
        mIconImageView.image = iconImage;
        [iconImage release];
        
        [self addSubview:mIconImageView];
        
        
        
        
        UIImage *cancelButtonImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecipeTabSearchBarCross" ofType:@"png"]];
        CGFloat extraPaddingForCancelButton = roundf((self.frame.size.height - cancelButtonImage.size.height) / 2);
        mCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - (cancelButtonImage.size.width + extraPaddingForCancelButton + extraPaddingForCancelButton),
                                                                   0,
                                                                   cancelButtonImage.size.width + extraPaddingForCancelButton + extraPaddingForCancelButton,
                                                                   self.frame.size.height)];
        [mCancelButton setImage:cancelButtonImage forState:UIControlStateNormal];
        [cancelButtonImage release];
        [mCancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        mCancelButton.hidden = YES;
        [self addSubview:mCancelButton];
        
        
        
        NSString *placeholderText = @"Search";
        UIFont *textFieldFont = [UtilityManager fontGetRegularFontOfSize:18];
        CGSize sampleSize = [placeholderText sizeWithFont:textFieldFont];
        mTextField = [[UITextField alloc] initWithFrame:CGRectMake(mIconImageView.frame.origin.x + mIconImageView.frame.size.width + kGapBetweenSearchIconAndTextField,
                                                                   roundf((self.frame.size.height - sampleSize.height) / 2),
                                                                   mCancelButton.frame.origin.x - (mIconImageView.frame.origin.x + mIconImageView.frame.size.width + kGapBetweenSearchIconAndTextField),
                                                                   sampleSize.height)];
        mTextField.font = textFieldFont;
        mTextField.placeholder = placeholderText;
        mTextField.delegate = self;
        mTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        [self addSubview:mTextField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:mTextField];
        
    }
    return self;
}

- (void)dealloc {
    
    [mTextField release];
    [mBackgroundImageView release];
    [mCancelButton release];
    [super dealloc];
}


- (void)cancel:(id)sender
{
    if([searchDelegate respondsToSelector:@selector(searchBarUserTappedCancel:)])
    {
        [searchDelegate searchBarUserTappedCancel:self];
    }
    
    mTextField.text = @"";
    
    [mTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    mCancelButton.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    mCancelButton.hidden = YES;
}


- (void)textChanged:(NSNotification *)notification
{
    if([searchDelegate respondsToSelector:@selector(searchBar:searchTextChangedTo:)])
    {
        [searchDelegate searchBar:self searchTextChangedTo:mTextField.text];
    }
}

- (void)resignSearchBar
{
    if([searchDelegate respondsToSelector:@selector(searchBarUserTappedCancel:)])
    {
        [searchDelegate searchBarUserTappedCancel:self];
    }
    
    mTextField.text = @"";
    
    [mTextField resignFirstResponder];
}

@end
