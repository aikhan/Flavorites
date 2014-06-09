//
//  SystemSoundPlayer.m
//  iTCCalculator
//
//  Created by Harmandeep Singh on 24/11/10.
//  Copyright 2010 Route Me. All rights reserved.
//

#import "SystemSoundPlayer.h"
#import "DataManager.h"


static SystemSoundPlayer *sharedSystemSoundPlayer = nil;


@implementation SystemSoundPlayer



+ (SystemSoundPlayer*)sharedSystemSoundPlayer
{
    @synchronized(self) {
        if (sharedSystemSoundPlayer == nil) {
			[[self alloc] init];
        }
    }
    return sharedSystemSoundPlayer;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedSystemSoundPlayer == nil) {
            return [super allocWithZone:zone];
        }
    }
    return sharedSystemSoundPlayer;
}

- (id)init
{
    Class myClass = [self class];
    @synchronized(myClass) {
        if (sharedSystemSoundPlayer == nil) {
            if (self = [super init]) {
                sharedSystemSoundPlayer = self;
                // custom initialization here
				
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(memoryWarning:)
                                                             name:UIApplicationDidReceiveMemoryWarningNotification
                                                           object:nil];

            }
        }
    }
    return sharedSystemSoundPlayer;
}

- (id)copyWithZone:(NSZone *)zone { return self; }

- (id)retain { return self; }

- (unsigned)retainCount { return UINT_MAX; }


- (id)autorelease { return self; }




- (void)dealloc
{
	AudioServicesDisposeSystemSoundID(mCoverFlowMove);
	[super dealloc];
}




- (void)playCoverFlowMove
{
	if(mCoverFlowMove == 0)
    {
        NSURL *urlCoverFlowMove = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CoverFlow_Move" ofType:@"aifc"]];
        AudioServicesCreateSystemSoundID ((CFURLRef)urlCoverFlowMove, &mCoverFlowMove);
    }
    
    AudioServicesPlaySystemSound(mCoverFlowMove);
}







- (void)memoryWarning:(NSNotification *)notification
{
    AudioServicesDisposeSystemSoundID(mCoverFlowMove);
    mCoverFlowMove = 0;
}


@end
