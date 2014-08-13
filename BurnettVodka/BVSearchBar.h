//
//  BVSearchBar.h
//  BurnettVodka
//
//  Created by admin on 7/23/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BVSearchBar;

@protocol BVSearchBarDelegate <NSObject>

- (void)searchBar:(BVSearchBar *)searchBar searchTextChangedTo:(NSString *)searchText;
- (void)searchBarUserTappedCancel:(BVSearchBar *)searchBar;

@end

@interface BVSearchBar : UIView <UITextFieldDelegate> {

    UIImageView *mBackgroundImageView;
    UIImageView *mIconImageView;
    UIButton *mCancelButton;
    UITextField *mTextField;
    
    id <BVSearchBarDelegate> searchDelegate;
}
@property (nonatomic, retain) UITextField *mTextField;
@property (nonatomic, assign) id <BVSearchBarDelegate> searchDelegate;

- (void)resignSearchBar;

@end
