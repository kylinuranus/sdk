//
//  SOSAudioBox.m
//  Onstar
//
//  Created by Coir on 2018/5/8.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAudioBox.h"
#include <AudioToolbox/AudioToolbox.h>

@implementation SOSAudioBox

+ (void)playAlertSoundWithAudioFileName:(NSString *)fileName	{
    if (!fileName.length)	return;
    SystemSoundID soundFileObject;
    NSURL *soundFileURL = [[NSBundle SOSBundle] URLForResource:fileName withExtension:@"wav"];
    CFURLRef soundFileURLRef = (CFURLRef) CFBridgingRetain(soundFileURL);
    AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObject);
    
    BOOL isRemoteAudio = [[NSUserDefaults standardUserDefaults] boolForKey:NEED_REMOTE_AUDIO];
    BOOL isRemoteViberate = [[NSUserDefaults standardUserDefaults] boolForKey:NEED_REMOTE_Viberate];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isRemoteAudio && isRemoteViberate)    {
            AudioServicesPlayAlertSound(soundFileObject);
        }    else if(isRemoteAudio&&!isRemoteViberate)    {
            AudioServicesPlaySystemSound (soundFileObject);
        }    else if(!isRemoteAudio&&isRemoteViberate)    {
            AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        }
    });
}

@end
