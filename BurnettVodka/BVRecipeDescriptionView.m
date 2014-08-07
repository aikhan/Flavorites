//
//  BVRecipeDescriptionView.m
//  BurnettVodka
//
//  Created by Ahmad Awais on 23/07/2014.
//  Copyright (c) 2014 XenoPsi Media. All rights reserved.
//

#import "BVRecipeDescriptionView.h"

@implementation BVRecipeDescriptionView
@synthesize Procedure,Ingredients,Heading,CrossBtn,LoadmoreBtn,RecipeTmg;

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



@end
