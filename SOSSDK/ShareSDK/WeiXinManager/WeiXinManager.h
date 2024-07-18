//
//  WeiXinManager.h
//  HappyNewYear
//
//  Created by Onstar on 3/7/13.
//  Copyright (c) 2013 Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"


@class WeiXinMessageInfo;
@interface WeiXinManager : NSObject     {
    int scenceFrind;
    int scenceFrinds;
}
@property (readonly, nonatomic)int scenceFrind;
@property (readonly, nonatomic)int scenceFrinds;
@property (readwrite, nonatomic)BOOL fromWeixin;
+ (WeiXinManager *)shareInstance;
- (BOOL)isWXAppInstalled;
- (void)sendWeiXinImage:(UIImage *)image Message:(NSString *)message Scence:(int)scence;
- (void)requestWeiXinImage:(UIImage *)image Message:(NSString *)message Scence:(int)scence;
- (void)respWeiXinImage:(UIImage *)image Message:(NSString *)messageStr;
- (void)sendAppContentTitle:(NSString *)title Message:(NSString *)messageStr ThumbImage:(UIImage *)thumb Scence:(int)scence;
- (void)registerApp;
- (void)shareWebPageContent:(WeiXinMessageInfo *)messageInfo;
@end
