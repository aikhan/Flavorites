//
//  BVTabBar.h
//  BurnettVodka
//
//  Created by admin on 7/13/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BVTabBar;

@protocol BVTabBarDelegate <NSObject>

- (void)settingsTabBar:(BVTabBar *)tabBar changeInSelectedFromIndex:(NSInteger)previousIndex toNewIndex:(NSInteger)selectedIndex;

@end

@interface BVTabBar : UIView {
    
    UIImageView *_backgroundImageView;
    
    NSMutableArray *_buttons;
    NSInteger _selectedIndex;
    
    UIColor *_selectionColor;
    
    id <BVTabBarDelegate> viewDelegate;
}

@property (nonatomic, assign) id <BVTabBarDelegate> viewDelegate;

- (id)initWithTabBarItems:(NSArray *)tabBarItems;
- (void)setSelectedIndex:(NSInteger)newSelectedIndex;
- (NSInteger)selectedIndex;

@end
