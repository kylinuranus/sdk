//
//  AppDelegate_iPhone+SOSOpenUrl.h
//  Onstar
//
//  Created by lizhipan on 2017/9/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "WXApi.h"


@interface AppDelegate_iPhone (SOSOpenUrl)<WXApiDelegate>

- (void)openWebViewNonLogin:(NSString *)url;
- (void)jumpToRemoteView;
- (void)openOVD;
@end
