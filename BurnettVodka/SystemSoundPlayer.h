//
//  SystemSoundPlayer.h
//  iTCCalculator
//
//  Created by Harmandeep Singh on 24/11/10.
//  Copyright 2010 Route Me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SystemSoundPlayer : NSObject {

    SystemSoundID mCoverFlowMove;
}

+ (SystemSoundPlayer*)sharedSystemSoundPlayer;

- (void)playCoverFlowMove;

@end
