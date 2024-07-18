//
//  SOSWeakScriptDelegate.h
//  Onstar
//
//  Created by jieke on 2020/9/18.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN



/** H5调用APP日历 */
extern NSString *const method_onstarOpenCalendar ;
/** 返回token */
extern NSString *const method_onstarGetToken;
/** 返回token callback */
extern NSString *const method_callback_onstarGetToken;
/** 获取用户信息 */
extern NSString *const method_getAppInfo;
/** 获取用户信息 callBack */
extern NSString *const method_callback_getAppInfo;
/** 关闭WebView */
extern NSString *const method_close;
/** 分享地址 */
extern NSString *const method_getShareUrl;
/** 完成自动登录进入homepage */
extern NSString *const method_goHomePage;
/** H5调用原生相机 */
extern NSString *const method_onstarOpenCamera;
/** h5交互查询的信息 */
extern NSString *const method_query;
/** h5显示原生分享 */
extern NSString *const method_showDemoShare;
/** h5 添加截屏分享按钮 */
extern NSString *const method_screenshotShare;
/** h5隐藏分享按钮 */
extern NSString *const method_hideShareBtn;
/** 指定url图片分享 */
extern NSString *const method_shareImage;
/** h5跳转到设置 */
extern NSString *const method_goSettingPage;
/** H5进入购买流量包界面 */
extern NSString *const method_buyDataPackage;
/** H5进入购买安吉星套餐包界面 */
extern NSString *const method_buyOnstarPackage;
/** 跳转remoteView */
extern NSString *const method_goRemotePage;
/** 回退登录界面并清除用户名密码 */
extern NSString *const method_goToLoginPage;
/** 设置nav、标题 */
extern NSString *const method_setTitle;
/** 调用native loading */
extern NSString *const method_showLoading;
/** 调用native loading hidden */
extern NSString *const method_toggleAppLoadingForH5;
/** 调用native dismiss loading */
extern NSString *const method_closeLoading;
/** 调用native设置RightBarButtonItem */
extern NSString *const method_registRightBtn;
/** 加载失败,点击页面重试 */
extern NSString *const method_showLoadingFail;
/** 调用原生图库\拍照并上传图片 */
extern NSString *const method_chooseOnStarImage;
/** 调用原生图库\拍照并上传多张图片,最多9张图 */
extern NSString *const method_chooseNativeImage;
/** 提供用户位置 */
extern NSString *const method_getPoiId;
/** 提供用户位置 */
extern NSString *const method_getIOSPoiMsgCallback;

/** 刷新足迹 */
extern NSString *const method_refreshFootprint;
/**  */
extern NSString *const method_goFunPage;
/** H5DAAP埋点调用客户端方法 */
extern NSString *const method_sendClientForH5;
/** H5DAAP埋点调用客户端方法 */
extern NSString *const method_sendClientBannerForH5;
/** H5DAAP埋点调用客户端方法 */
extern NSString *const method_sendClientDurationForH5;
/** H5调起分享 */
extern NSString *const method_shareLinkForH5;
/** H5调起分享 */
extern NSString *const method_shareUrlForH5;
/** H5 隐藏/显示 Navigation Bar */
extern NSString *const method_showheaderForH5;
/** H5显示/隐藏底部白条 */
extern NSString *const method_coverBottomSafeArea;
/** H5 更改车牌号回调 */
extern NSString *const method_changePlateNumber;
/** 预约经销商调用 */
extern NSString *const method_carMsgForH5;
/** 预约经销商调用 */
extern NSString *const method_callback_carMsgForH5;
/** 积分公益,获取用户信息 */
extern NSString *const method_getUserInfoForH5;
/** 积分公益,获取用户信息 回调 */
extern NSString *const method_callback_getUserInfoForH5;
/** 广告 Banner,小游戏,获取用户ID */
extern NSString *const method_getUserIdForH5;
/** 广告 Banner,小游戏,获取用户ID */
extern NSString *const method_callback_getUserIdForH5;
/** 广告 Banner,小游戏,获取用户ID */
extern NSString *const method_userinfoGo;
/**积分公益,用户未登录跳转到登录界面，用户为访客跳转到升级车主界面。用户为车主且登录返回true,否则返回false */
extern NSString *const method_callback_userinfoGo;
/** H5 直接触发截屏分享 */
extern NSString *const method_screencutForh5;
/**  */
extern NSString *const method_webviewBack;
/** screenCutShare  */
extern NSString *const method_screenCutShare;
/** H5 设置分享埋点  */
extern NSString *const method_goshareSetPoint;
/** H5 直接触发分享传入 URL 指定图片  */
extern NSString *const method_screencutOtherPage;
/** callAlertForH5  */
extern NSString *const method_callAlertForH5;
/** 获取车况信息  */
extern NSString *const method_getVehicleCondition;
/** 获取车况信息  */
extern NSString *const method_callback_getVehicleCondition;
/** finishShowReport  */
extern NSString *const method_finishShowReport;
/** finishShowReport  */
extern NSString *const method_H5_IS_READY;
/** 显示Toast  */
extern NSString *const method_showToastForH5;
/** 隐藏Toast  */
extern NSString *const method_dissmissToast;
/** showDialog  */
extern NSString *const method_showDialog ;
/** showDialog  */
extern NSString *const method_callback_showDialog;
/** showForumShare  */
extern NSString *const method_showForumShare;
/** showForumShare  */
extern NSString *const method_callback_showForumShare;
/** showForumShare  */
extern NSString *const method_goNewPage;
/** goBannerPage  */
extern NSString *const method_goBannerPage;
/** checkUserForH5  */
extern NSString *const method_checkUserForH5;
/** checkUserForH5 callback  */
extern NSString *const method_callback_checkUserForH5;
/** H5 跳转 里程险  */
extern NSString *const method_goUbiPage;
/** 近期行程调起 分享弹窗  */
extern NSString *const method_showShareToast;
/** 近期行程调起 设置家和公司地址  */
extern NSString *const method_toSettingCompanyAddressPage;
/** 保存图片至相册  */
extern NSString *const method_savePictureForH5;
/* ****************   自驾游二期添加   **************** */
/** 保存图片至相册  */
extern NSString *const method_createfriendGroupForH5;
/** 保存图片至相册 回调 */
extern NSString *const method_callback_createfriendGroupForH5 ;
/** 进入群聊  */
extern NSString *const method_enterfriendGroupForH5;
/** 邀请加入群聊  */
extern NSString *const method_shiftInfriendGroupMemberForH5;
/** 邀请加入群聊  回调 */
extern NSString *const method_callback_shiftInfriendGroupMemberForH5;
/** 成员移出群聊  */
extern NSString *const method_removefriendGroupMemberForH5 ;
/** 成员移出群聊  回调*/
extern NSString *const method_callback_removefriendGroupMemberForH5;
/** 成员加入群聊 */
extern NSString *const method_joinfriendGroupForH5;
/** 成员加入群聊 回调 */
extern NSString *const method_callback_joinfriendGroupForH5;
/** 联系按钮的作用：非好友提示加好友，好友直接发消息 */
extern NSString *const method_contactFriendsForH5;
/** 进入车队 */
extern NSString *const method_enterPartyTeamForH5 ;
/** 进入目的地详情页面 */
extern NSString *const method_toDestinationPageForH5;
/** 旋转图片 */
extern NSString *const method_rotatePictureForH5;
/** 旋转图片 回调*/
extern NSString *const method_callback_rotatePictureForH5;
/** 退出星友圈群聊 */
extern NSString *const method_quitTeamForH5;
/** 退出星友圈群聊 回调 */
extern NSString *const method_callback_quitTeamForH5;
//论坛二期个人主页功能
/** 星友圈检测是否为好友 */
extern NSString *const method_isMyFriendForH5;
/** 星友圈检测是否为好友 回调 */
extern NSString *const method_callback_isMyFriendForH5 ;
/** 星友圈添加好友 */
extern NSString *const method_addFriendForH5;
/** 星友圈添加好友 回调 */
extern NSString *const method_callback_addFriendForH5;
/** 星友圈打开好友界面 */
extern NSString *const method_startP2PMessageViewForH5;
/** 星友圈打开好友界面 回调 */
extern NSString *const method_callback_startP2PMessageViewForH5;




    
    


@interface SOSWeakScriptDelegate : NSObject<WKScriptMessageHandler>


@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;


@end

NS_ASSUME_NONNULL_END
