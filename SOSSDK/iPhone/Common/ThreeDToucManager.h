//
//  ThreeDToucManager.h
//  Onstar
//
//  Created by Apple on 16/12/13.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreeDToucManager : NSObject

+ (void)config3DTouch;

+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler;

@end
