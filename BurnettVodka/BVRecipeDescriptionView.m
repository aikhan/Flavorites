//
//  BVRecipeDescriptionView.m
//  BurnettVodka
//
//  Created by Assad on 23/07/2014.
//  Copyright (c) 2014 XenoPsi Media. All rights reserved.
//

#import "BVRecipeDescriptionView.h"

@implementation BVRecipeDescriptionView
@synthesize Procedure,Ingredients,Heading,LoadmoreBtn,RecipeTmg,Crossbtn;
int yValue;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BVRecipeDescriptionView" owner:self options:nil];
		[[nib objectAtIndex:0] setFrame:frame];
        self = [nib objectAtIndex:0];
        self.alpha = 1.0;

    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    DebugLog(@"yo %s", __PRETTY_FUNCTION__);
    self.Ingredients.delegate = self;
    self.Procedure.delegate = self;
    yValue = 0;
    [self performSelector:@selector(resize) withObject:nil afterDelay:0.01];
    
}

- (void)resize{
    [self changeTextViewHeight:self.Ingredients];
    [self changeTextViewHeight:self.Procedure];
    [self adjustLayoutForAllViews];
}

- (void)changeTextViewHeight:(UITextView *)textView{
    DebugLog(@"yo %s", __PRETTY_FUNCTION__);
    [textView sizeToFit];
    textView.scrollEnabled = NO;
}

- (void)adjustLayoutForAllViews{
    float sizeThatFits = [self.Ingredients sizeThatFits:Ingredients.bounds.size].height;
    yValue = self.Ingredients.frame.origin.y + (int)sizeThatFits;
    DebugLog(@"yValue is %d", yValue);
    NSLog(@"%@", NSStringFromCGRect(self.Ingredients.frame));
    
    
    CGRect recipeFrame = self.Procedure.frame;
    NSLog(@"%@", NSStringFromCGRect(self.Procedure.frame));
    recipeFrame.origin.y = yValue;
    self.Procedure.frame = recipeFrame;
    
    recipeFrame = self.RecipeTmg.frame;
    recipeFrame.origin.y = yValue + 5;
    self.RecipeTmg.frame = recipeFrame;
    if (self.Procedure.frame.size.height > self.RecipeTmg.frame.size.height) {
        yValue = self.Procedure.frame.origin.y + self.Procedure.frame.size.height + 10;
    }else{
        yValue = self.RecipeTmg.frame.origin.y + self.RecipeTmg.frame.size.height + 10;
    }
    
    
    recipeFrame = self.LoadmoreBtn.frame;
    recipeFrame.origin.y = yValue;
    self.LoadmoreBtn.frame = recipeFrame;
}

@end
