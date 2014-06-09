//
//  BVTabBar.m
//  BurnettVodka
//
//  Created by admin on 7/13/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import "BVTabBar.h"

@interface BVTabBar ()

- (UIColor *)selectionColor;

@end




@implementation BVTabBar

@synthesize viewDelegate;

- (id)initWithTabBarItems:(NSArray *)tabBarItems
{
    UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TabBarBackgroundImage" ofType:@"png"]];
    
    self = [super initWithFrame:CGRectMake(0,
                                           0,
                                           backgroundImage.size.width,
                                           backgroundImage.size.height)];
    if(self)
    {
        
        //Background Image View
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                             0,
                                                                             self.frame.size.width,
                                                                             self.frame.size.height)];
        _backgroundImageView.image = backgroundImage;
        [self addSubview:_backgroundImageView];

        
        
        
        
        
        
        // Configure the buttons
        _buttons = [[NSMutableArray alloc] init];
        
        
        CGFloat xCoordinatePointer = 0;
        CGFloat widthOfTheButton = roundf(self.frame.size.width / [tabBarItems count]);
        
        for(int i=0; i<[tabBarItems count]; i++)
        {
            UITabBarItem *item = [tabBarItems objectAtIndex:i];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(xCoordinatePointer,
                                                                          0,
                                                                          widthOfTheButton,
                                                                          self.frame.size.height)];
            button.adjustsImageWhenHighlighted = NO;
            button.tag = i;
            [button addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchDown];
            [button setImage:item.image forState:UIControlStateNormal];
            [self addSubview:button];
            [_buttons addObject:button];
            [button release];
            
            
            xCoordinatePointer = button.frame.origin.x + button.frame.size.width;
        }
        

        // Set The First Button Selected
        
        _selectedIndex = 0;
        
        if([_buttons count] > 0)
        {
            UIButton *buttonToBeSelected = [_buttons objectAtIndex:0];
            buttonToBeSelected.backgroundColor = [self selectionColor];
        }
    }
    [backgroundImage release];
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)dealloc {
    
    [_selectionColor release];
    [_buttons release];
    [_backgroundImageView release];
    [super dealloc];
}





#pragma mark - Action Methods

- (void)tabButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self setSelectedIndex:button.tag];
}





#pragma mark - Public Methods


- (void)setSelectedIndex:(NSInteger)newSelectedIndex
{
    
    if(newSelectedIndex == _selectedIndex)
        return;
    
    
    
    
    // Bring the previous selected button to Non Selected State
    if([_buttons count] >= (_selectedIndex + 1))
    {
        UIButton *previousSelectedButton = [_buttons objectAtIndex:_selectedIndex];
        previousSelectedButton.backgroundColor = [UIColor clearColor];
    }
    
    
    
    // Set the selectedIndex value to the new one
    CGFloat previousIndex = _selectedIndex;
    _selectedIndex = newSelectedIndex;
    
    
    
    
    
    // Update the UI for newly selected button
    UIButton *newSelectedButton = [_buttons objectAtIndex:_selectedIndex];
    newSelectedButton.backgroundColor = [self selectionColor];
    
    
    //Inform the Delegate
    if([viewDelegate respondsToSelector:@selector(settingsTabBar:changeInSelectedFromIndex:toNewIndex:)])
    {
        [viewDelegate settingsTabBar:self changeInSelectedFromIndex:previousIndex toNewIndex:_selectedIndex];
    }
    
}


- (NSInteger)selectedIndex
{
    return _selectedIndex;
}




#pragma mark - Private Methods

- (UIColor *)selectionColor
{
    if(_selectionColor == nil)
    {
        _selectionColor = [[UIColor alloc] initWithRed:0 green:(73.0/256.0) blue:(143.0/256.0) alpha:1.0];
    }
    
    return _selectionColor;
}



@end
