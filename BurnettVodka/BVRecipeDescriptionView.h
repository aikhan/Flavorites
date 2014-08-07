//
//  BVRecipeDescriptionView.h
//  BurnettVodka
//
//  Created by Ahmad Awais on 23/07/2014.
//  Copyright (c) 2014 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BVRecipeDescriptionView : UIView {
 
    
}

@property (retain,nonatomic) IBOutlet UILabel* Heading;
@property (retain,nonatomic) IBOutlet UIImageView* RecipeTmg;
@property (retain,nonatomic) IBOutlet UIButton* CrossBtn;
@property (retain,nonatomic) IBOutlet UIButton* LoadmoreBtn;
@property (retain,nonatomic) IBOutlet UITextView* Ingredients;
@property (retain,nonatomic) IBOutlet UITextView* Procedure;

@end
