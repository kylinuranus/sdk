//
//  NavigateShareTool.h
//  Onstar
//
//  Created by Coir on 16/3/28.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSFlexibleAlertController.h"
#import "SOSSocialContactShareView.h"
#import <Foundation/Foundation.h>
#import "WeiXinMessageInfo.h"

@class MAMapView;

@interface NavigateShareTool : NSObject

@property (nonatomic, strong) NSString *shareCancelDaapID;
@property (nonatomic, strong) NSString *shareToChatDaapID;
@property (nonatomic, strong) NSString *shareToMomentsDaapID;

+ (NavigateShareTool *)sharedInstance;

- (void)shareWithImg:(UIImage *)img
__attribute((deprecated("废弃, 请使用 showShareAlertControllerWithShareSource")));

- (void)shareWithPOI:(SOSPOI *)sharePoi
__attribute((deprecated("废弃, 请使用 showShareAlertControllerWithShareSource")));


- (void)shareWithNewUIWithPOI:(SOSPOI *)sharePoi
__attribute((deprecated("废弃, 请使用 showShareAlertControllerWithShareSource")));


/// 分享项仅有微信&朋友圈
/// @param messageInfo 
- (void)shareWithWeiXinMessageInfo:(WeiXinMessageInfo *)messageInfo;


/// funIDArray    [wechatFriend, wechatMoment, wechatCancel]
- (void)shareWithImg:(UIImage *)img andFunIDArray:(NSArray <NSString *> *)funIDArray __attribute((deprecated("废弃, 请使用 showShareAlertControllerWithShareSource")));



#pragma mark 微信分享点击
- (void)shareToWeixinSceneWeiXinMessageInfo:(int)scene  messageInfo:(WeiXinMessageInfo *)wxMessageInfo;


///model 示范
/// (
//分享标题,
//分享摘要2020年1月19日10:40:47,
//http://www.onstar.com.cn/mweb/mweb-main/static/OnStar-MPG-h5/images/brand_common_logo.png,
//https://idt6sit.onstar.com.cn/mweb/ma80/shareWx.html,
//@[{
//    event = shareWchat;
//    functionId = "";
//},
//{
//    event = shareWchatMoments;
//    functionId = "";
//},
//{
//    event = shareOnStarMoments;
//    functionId = "";
//},
//{
//    event = shareSavePic;
//    functionId = "";
//},
//{
//    event = cancelshare;
//    functionId = "";
//}]
//)
/// @param shareSource 分享model
/// @param rt 截屏分享时候分享界面,不是截屏分享不要设置.
- (void)showShareAlertControllerWithShareSource:(NSDictionary *)shareSource screencutShareView:(nullable UIScrollView*)rt ;
@end
