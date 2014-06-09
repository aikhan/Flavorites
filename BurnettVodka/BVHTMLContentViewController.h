//
//  BVHTMLContentViewController.h
//  BurnettVodka
//
//  Created by admin on 9/24/13.
//  Copyright (c) 2013 XenoPsi Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface BVHTMLContentViewController : GAITrackedViewController {
    
    UIWebView *mWebView;
    NSString *mHTMLString;
}

- (id)initWithHTMLString:(NSString *)htmlString;

@end
