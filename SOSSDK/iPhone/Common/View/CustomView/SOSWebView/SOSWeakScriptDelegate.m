//
//  SOSWeakScriptDelegate.m
//  Onstar
//
//  Created by jieke on 2020/9/18.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSWeakScriptDelegate.h"

/** H5调用APP日历 */
NSString *const method_onstarOpenCalendar = @"onstarOpenCalendar";
/** 返回token */
NSString *const method_onstarGetToken = @"onstarGetToken";
/** 返回token callback */
NSString *const method_callback_onstarGetToken = @"onstarGetToken_wk_callback";
/** 获取用户信息 */
NSString *const method_getAppInfo = @"getAppInfo";
/** 获取用户信息 callBack */
NSString *const method_callback_getAppInfo = @"getAppInfo_wk_callback";
/** 关闭WebView */
NSString *const method_close = @"close";
/** 分享地址 */
NSString *const method_getShareUrl = @"getShareUrl";
/** 完成自动登录进入homepage */
NSString *const method_goHomePage = @"goHomePage";
/** H5调用原生相机 */
NSString *const method_onstarOpenCamera = @"onstarOpenCamera";
/** h5交互查询的信息 */
NSString *const method_query = @"query";
/** h5显示原生分享 */
NSString *const method_showDemoShare = @"showDemoShare";
/** h5 添加截屏分享按钮 */
NSString *const method_screenshotShare = @"screenshotShare";
/** h5隐藏分享按钮 */
NSString *const method_hideShareBtn = @"hideShareBtn";
/** 指定url图片分享 */
NSString *const method_shareImage = @"shareImage";
/** h5跳转到设置 */
NSString *const method_goSettingPage = @"goSettingPage";
/** H5进入购买流量包界面 */
NSString *const method_buyDataPackage = @"buyDataPackage";
/** H5进入购买安吉星套餐包界面 */
NSString *const method_buyOnstarPackage = @"buyOnstarPackage";
/** 跳转remoteView */
NSString *const method_goRemotePage = @"goRemotePage";
/** 回退登录界面并清除用户名密码 */
NSString *const method_goToLoginPage = @"goToLoginPage";
/** 设置nav、标题 */
NSString *const method_setTitle = @"setTitle";
/** 调用native loading */
NSString *const method_showLoading = @"showLoading";
/** 调用native loading hidden */
NSString *const method_toggleAppLoadingForH5 = @"toggleAppLoadingForH5";
/** 调用native dismiss loading */
NSString *const method_closeLoading = @"closeLoading";
/** 调用native设置RightBarButtonItem */
NSString *const method_registRightBtn = @"registRightBtn";
/** 加载失败,点击页面重试 */
NSString *const method_showLoadingFail = @"showLoadingFail";
/** 调用原生图库\拍照并上传图片 */
NSString *const method_chooseOnStarImage = @"chooseOnStarImage";
/** 调用原生图库\拍照并上传多张图片,最多9张图 */
NSString *const method_chooseNativeImage = @"chooseNativeImage";
/** 提供用户位置 */
NSString *const method_getPoiId = @"getPoiId";
/** 提供用户位置 */
NSString *const method_getIOSPoiMsgCallback = @"getIOSPoiMsgCallback";

/** 刷新足迹 */
NSString *const method_refreshFootprint = @"refreshFootprint";
/**  */
NSString *const method_goFunPage = @"goFunPage";
/** H5DAAP埋点调用客户端方法 */
NSString *const method_sendClientForH5 = @"sendClientForH5";
/** H5DAAP埋点调用客户端方法 */
NSString *const method_sendClientBannerForH5 = @"sendClientBannerForH5";
/** H5DAAP埋点调用客户端方法 */
NSString *const method_sendClientDurationForH5 = @"sendClientDurationForH5";
/** H5调起分享 */
NSString *const method_shareLinkForH5 = @"shareLinkForH5";
/** H5调起分享 */
NSString *const method_shareUrlForH5 = @"shareUrlForH5";
/** H5 隐藏/显示 Navigation Bar */
NSString *const method_showheaderForH5 = @"showheaderForH5";
/** H5显示/隐藏底部白条 */
NSString *const method_coverBottomSafeArea = @"coverBottomSafeArea";
/** H5 更改车牌号回调 */
NSString *const method_changePlateNumber = @"changePlateNumber";
/** 预约经销商调用 */
NSString *const method_carMsgForH5 = @"carMsgForH5";
/** 预约经销商调用 */
NSString *const method_callback_carMsgForH5 = @"carMsgForH5_wk_callback";
/** 积分公益,获取用户信息 */
NSString *const method_getUserInfoForH5 = @"getUserInfoForH5";
/** 积分公益,获取用户信息 回调 */
NSString *const method_callback_getUserInfoForH5 = @"getUserInfoForH5_wk_callback";
/** 广告 Banner,小游戏,获取用户ID */
NSString *const method_getUserIdForH5 = @"getUserIdForH5";
/** 广告 Banner,小游戏,获取用户ID */
NSString *const method_callback_getUserIdForH5 = @"getUserIdForH5_wk_callback";
/** 广告 Banner,小游戏,获取用户ID */
NSString *const method_userinfoGo = @"userinfoGo";
/**积分公益,用户未登录跳转到登录界面，用户为访客跳转到升级车主界面。用户为车主且登录返回true,否则返回false */
NSString *const method_callback_userinfoGo = @"userinfoGo_wk_callback";
/** H5 直接触发截屏分享 */
NSString *const method_screencutForh5 = @"screencutForh5";
/**  */
NSString *const method_webviewBack = @"webviewBack";
/** screenCutShare  */
NSString *const method_screenCutShare = @"screenCutShare";
/** H5 设置分享埋点  */
NSString *const method_goshareSetPoint = @"goshareSetPoint";
/** H5 直接触发分享传入 URL 指定图片  */
NSString *const method_screencutOtherPage = @"screencutOtherPage";
/** callAlertForH5  */
NSString *const method_callAlertForH5 = @"callAlertForH5";
/** 获取车况信息  */
NSString *const method_getVehicleCondition = @"getVehicleCondition";
/** 获取车况信息  */
NSString *const method_callback_getVehicleCondition = @"getVehicleCondition_wk_callback";
/** finishShowReport  */
NSString *const method_finishShowReport = @"finishShowReport";
/** finishShowReport  */
NSString *const method_H5_IS_READY = @"H5_IS_READY";
/** 显示Toast  */
NSString *const method_showToastForH5 = @"showToastForH5";
/** 隐藏Toast  */
NSString *const method_dissmissToast = @"dissmissToast";
/** showDialog  */
NSString *const method_showDialog = @"showDialog";
/** showDialog  */
NSString *const method_callback_showDialog = @"showDialog_wk_callback";
/** showForumShare  */
NSString *const method_showForumShare = @"showForumShare";
/** showForumShare  */
NSString *const method_callback_showForumShare = @"showForumShare_wk_callback";
/** showForumShare  */
NSString *const method_goNewPage = @"goNewPage";
/** goBannerPage  */
NSString *const method_goBannerPage = @"goBannerPage";
/** checkUserForH5  */
NSString *const method_checkUserForH5 = @"checkUserForH5";
/** checkUserForH5 callback  */
NSString *const method_callback_checkUserForH5 = @"checkUserForH5_wk_callback";
/** H5 跳转 里程险  */
NSString *const method_goUbiPage = @"goUbiPage";
/** 近期行程调起 分享弹窗  */
NSString *const method_showShareToast = @"showShareToast";
/** 近期行程调起 设置家和公司地址  */
NSString *const method_toSettingCompanyAddressPage = @"toSettingCompanyAddressPage";
/** 保存图片至相册  */
NSString *const method_savePictureForH5 = @"savePictureForH5";
/* ****************   自驾游二期添加   **************** */
/** 保存图片至相册  */
NSString *const method_createfriendGroupForH5 = @"createfriendGroupForH5";
/** 保存图片至相册 回调 */
NSString *const method_callback_createfriendGroupForH5 = @"createfriendGroupForH5_wk_callback";
/** 进入群聊  */
NSString *const method_enterfriendGroupForH5 = @"enterfriendGroupForH5";
/** 邀请加入群聊  */
NSString *const method_shiftInfriendGroupMemberForH5 = @"shiftInfriendGroupMemberForH5";
/** 邀请加入群聊  回调 */
NSString *const method_callback_shiftInfriendGroupMemberForH5 = @"shiftInfriendGroupMemberForH5_wk_callback";
/** 成员移出群聊  */
NSString *const method_removefriendGroupMemberForH5 = @"removefriendGroupMemberForH5";
/** 成员移出群聊  回调*/
NSString *const method_callback_removefriendGroupMemberForH5 = @"removefriendGroupMemberForH5_wk_callback";
/** 成员加入群聊 */
NSString *const method_joinfriendGroupForH5 = @"joinfriendGroupForH5";
/** 成员加入群聊 回调 */
NSString *const method_callback_joinfriendGroupForH5 = @"joinfriendGroupForH5_wk_callback";
/** 联系按钮的作用：非好友提示加好友，好友直接发消息 */
NSString *const method_contactFriendsForH5 = @"contactFriendsForH5";
/** 进入车队 */
NSString *const method_enterPartyTeamForH5 = @"enterPartyTeamForH5";
/** 进入目的地详情页面 */
NSString *const method_toDestinationPageForH5 = @"toDestinationPageForH5";
/** 旋转图片 */
NSString *const method_rotatePictureForH5 = @"rotatePictureForH5";
/** 旋转图片 回调*/
NSString *const method_callback_rotatePictureForH5 = @"rotateCallback";
/** 退出星友圈群聊 */
NSString *const method_quitTeamForH5 = @"quitTeamForH5";
/** 退出星友圈群聊 回调 */
NSString *const method_callback_quitTeamForH5 = @"quitTeamForH5_wk_callback";
//论坛二期个人主页功能
/** 星友圈检测是否为好友 */
NSString *const method_isMyFriendForH5 = @"isMyFriendForH5";
/** 星友圈检测是否为好友 回调 */
NSString *const method_callback_isMyFriendForH5 = @"isMyFriendForH5_wk_callback";
/** 星友圈添加好友 */
NSString *const method_addFriendForH5 = @"addFriendForH5";
/** 星友圈添加好友 回调 */
NSString *const method_callback_addFriendForH5 = @"addFriendForH5_wk_callback";
/** 星友圈打开好友界面 */
NSString *const method_startP2PMessageViewForH5 = @"startP2PMessageViewForH5";
/** 星友圈打开好友界面 回调 */
NSString *const method_callback_startP2PMessageViewForH5 = @"startP2PMessageViewForH5_wk_callback";


@implementation SOSWeakScriptDelegate


-(instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}


@end
