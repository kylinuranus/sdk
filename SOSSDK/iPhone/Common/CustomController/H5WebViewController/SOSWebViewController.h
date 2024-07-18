//
//  SOSWebViewController.h
//  Onstar
//
//  Created by Apple on 16/7/6.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSWebView.h"
typedef void (^completedBlock)(void);
typedef NS_ENUM(NSUInteger, ShareType) {
    ShareTypeURlImage,     //分享url图片，先将图片下载
    ShareTypeScreenShoot,  //分享截屏图片
    ShareTypeDemoShare,    //分享demo数据
    ShareTypeNone,
};

@class WeiXinMessageInfo;

@interface SOSWebViewController : UIViewController<SOSWebViewDelegate>
/**
 *  origin url
 */
@property (nonatomic,strong)  NSURL* url;
@property (nonatomic,assign)  ShareType currentShareType;
@property (nonatomic,strong)  NNDispatcherReq * dispatcherRequest;
@property (nonatomic,strong)  NSString * brocastID;
@property (nonatomic,copy)    NSString * HTMLString;
@property (nonatomic, copy)   NSString *titleStr;
@property (nonatomic, assign) NSInteger isH5Title;
@property (assign ,nonatomic)BOOL isYearReport;      //是否从年度用车报告
@property (assign ,nonatomic)BOOL isForNewDAAP;      //奇葩,不拌嘴了

/**
 *  embed webView
 */
@property (nonatomic, strong) SOSWebView* webView;

@property (nonatomic, assign)NSInteger scalesPage;

@property (assign, nonatomic) BOOL shouldDismiss;

@property (assign, nonatomic) BOOL singlePageFlg;//单页面
@property (assign, nonatomic) BOOL shouldShowCloseButton;

@property (assign, nonatomic) BOOL hideShareFlg;//是否隐藏分享
@property (assign, nonatomic) BOOL closeSafeArea;//

@property (assign, nonatomic) BOOL alwaysShareFlg;//一直显示分享
@property (assign, nonatomic) BOOL tempShowDemoShareFlg;
@property (assign, nonatomic) BOOL showDemoShareFlg;
@property (assign, nonatomic) BOOL vehicleEvaluateFlg;//爱车评估
@property (assign, nonatomic) BOOL driveScoreFlg;    //驾驶评分
@property (assign, nonatomic) BOOL mirrorSimRecharge;  //后视镜流量购买


@property (nonatomic, copy)NSString *shareUrl;//分享链接
@property (nonatomic, copy)NSString *shareImageUrl;//分享指定url图片的链接
@property (nonatomic, copy)NSString *tempShareUrl;//是否显示分享按钮标示
@property (nonatomic, copy)NSString *shareImg;//分享图标
@property (nonatomic, copy)NSString *forwardUrl;//前往链接

@property (nonatomic, assign) BOOL shouldBackToRoot;

@property (nonatomic, assign) BOOL isBBWC;//是否是bbwc教育页面 登录后bbwc消失要弹出touchid

@property (copy, nonatomic) NSString *shareClickRecordFunctionID;//点击分享报告ID
@property (copy, nonatomic) NSString *shareCancelRecordFunctionID;//分享取消报告ID
@property (copy, nonatomic) NSString *shareWechatRecordFunctionID;//分享微信报告ID
@property (copy, nonatomic) NSString *shareMomentsRecordFunctionID;//分享朋友圈报告ID
@property (assign, nonatomic) BOOL isDemo;
/// H5调用Native方法后关闭页面执行Block
@property (copy,nonatomic)completedBlock closeCompleteBlock;
/// Nav导航栏关闭按钮被点击后执行Block
@property (copy,nonatomic)completedBlock backClickCompleteBlock;

@property (assign ,nonatomic)BOOL isDealer;      //是否从预约经销商
@property (copy, nonatomic) NSString *dealerName;//经销商名称
@property (copy, nonatomic) NSString *dealerCode;//经销商id
@property (copy, nonatomic) NSString *funId;//功能id，点击返回时根据此id埋点

@property (nonatomic, copy) NSArray <NSString *> * shareFunIDArray;


/**
 *  get instance with url
 *
 *  @param url url
 *
 *  @return instance
 */
- (id)initWithUrl:(NSString*)url;

- (id)initWithUrl:(NSString *)url params:(NSString *)dic httpMethod:(NSString *)method contentType:(NSString *) contentType;
- (id)initWithURLRequest:(NNURLRequest *)urlRequest;
- (id)initWithDispatcher:(NNDispatcherReq *)dispatcherRequest;
- (id)initWithBrocastID:(NSString *)brocastid;
- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url withBannerType:(NSInteger)typeId isH5Title:(NSInteger)h5Title;
- (void)loadThirdParty;
- (void)loadThirdPartyDemo;
#pragma mark -- H5调用交互方法
- (void)openDateWindow;
- (void)closeItemClicked;
- (void)closeComplete;
- (void)customBackItemClicked;
- (void)shareAttribute:(NSArray *)args;
- (void)onstarOpenCamera;
- (void)queryAttribute:(NSArray *)args;
- (void)showDemoShare;
/// 显示分享Item
- (void)showScreentShotShare;
/// 隐藏分享Item
- (void)hideScreentShotShare;
/// 直接调起分享
- (void)toShareFullScreen;
/// 直接调起分享,分享 ImgURL 对应图片
- (void)shareImgWithImgURL:(NSString *)url;
/// 将导航栏右侧图标换为 分享
- (void)showURLImageShare:(NSString *)shareImageUrl;
- (void)goSettingPage;

/// H5 设置分享埋点
- (void)configSharePointWithFunIDArray:(NSArray *)funIDArray;

/// H5 设置 Loading 加载时间埋点
- (void)configLoadingFuncIDWithStartTime:(NSTimeInterval)startTime AndSuccessFuncID:(NSString *)successFuncID FailureFuncID:(NSString *)failFuncID;

/**
 H5设置Viewcontroller Title

 @param title_ 设置的title
 */
- (void)changeCurrentTitle:(NSString *)title_;

/**
 H5调用客户端loading界面
 */
- (void)callShowLoading;

/**
 H5隐藏客户端loading
 */
- (void)callHideLoading;

/**
 H5更改rightbarbuttonitem
 */
- (void)refreshRightBarButtonItem:(NSString *)title forwardUrl:(NSString *)forward;
- (void)showLoginViewController;

//MA8.1新增H5交互

/**
 新增选图交互

 @param types 选图类型，如果album和camara都有则弹出UIActionSheet，只有一个的话直接跳转

 */
- (void)MA_8_1_onstarPickPhoto:(NSDictionary *)para;

- (void)MA_9_3_onstarPickPhotos:(NSInteger)maxPhontoNum ;
/**
 前往客户端原生界面

 @param para 根据该字段判断进入哪个页面
 */
- (void)MA_8_1_goFunPage:(NSString *)para;



/**
 8.2daap埋点,支持M-web调用

 @param funcId fuctionId
 */
- (void)MA_8_2_DAAP_sendActionInfo:(NSString *)funcId;

/**
 8.2daap埋点,支持M-web调用

 @param funcId functionId
 @param bannerId bannerId
 */
- (void)MA_8_2_DAAP_sendSysBanner:(NSString *)funcId bannerId:(NSString *)bannerId;

- (void)hideNavBar:(BOOL)hide;

- (void)coverBottomSafeArea:(BOOL)show;

/////8.4.1


/**
 车况分享
 客户端把车况封装回json传给html

 @return json string
 */
- (NSString *)sendVehicleConditionToHTML;
- (void)exitMyDonateRefresh ;
/// 积分公益,用户未登录跳转到登录界面，用户为访客跳转到升级车主界面。用户为车主且登录返回true,否则返回false
- (BOOL)isUserReadyForDonation;

//个人年度报告分享
-(void)toScreenCutShare:(UIImage*)image items:(NSArray*)items;

#pragma mark - 9.0

/**
 显示客户端Toast提示

 @param flag 0：失败（❌），1：成功（✅），2：提示（❗️），3：加载中（转圈圈）
 @param text 主文本
 @param subText 次级文本
 */
- (void)showToast:(NSUInteger)flag text:(NSString *)text subText:(NSString *)subText;


/**
 隐藏Toast
 */
- (void)dismissToast;


/**
 显示客户端SOSFlexibleViewController

 @param flag 0:ActionSheet 1:AlertView
 @param title title
 @param message message
 @param cancelBtn 取消按钮
 @param otherBtns 其他按钮
 @param callback 回调
 */
- (void)showAlertWithType:(NSUInteger)flag title:(NSString *)title message:(NSString *)message cancelBtn:(NSString *)cancelBtn otherBtns:(NSString *)otherBtns callback:(void (^)(NSUInteger))callback;


/**
 调起客户端星论坛的分享功能

 @param funcs 按钮序号s
 @param callback 回调
 */
- (void)showForumShare:(NSString *)funcs sharedData:(NSString *)sharedData callback:(void (^)(NSUInteger buttonIndex))callback;


/**
 生活首页点击跳转至新的星论坛H5页面

 @param urlString url
 */
- (void)pushNewWebViewControllerWithUrl:(NSString *)urlString;


/**
 生活首页,点击banner跳转

 @param para 参数
 */
- (void)goBannerPage:(NSString *)para;


- (BOOL)showLoginVCAndShouldCheckVisitor:(BOOL)shouldCheckVisitor;

/// 近期行程分享方法 (saveToPhoto: 是否需要显示保存到系统相册)
- (void)shareRecentTrailWithMsg:(WeiXinMessageInfo *)messageInfo needShowSaveToPhoto:(BOOL)saveToPhoto;

/// 保存图片至相册
- (void)saveImageWithImageURL:(NSString *)imgURL;

- (void)addTopCoverView;

- (void)MA_9_3_onstarGetUserLocationCallback:(void(^)(SOSPOI * currentP))callback;
- (NSString *)MA_9_3_onstarGetUserLocationCallbackTest:(void(^)(SOSPOI * currentP))callback;


- (void)MA_9_3_onstarRefreshFootPrint;
@end
