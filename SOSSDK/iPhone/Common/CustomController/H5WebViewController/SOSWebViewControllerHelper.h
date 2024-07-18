//
//  SOSWebViewControllerHelper.h
//  Onstar
//
//  Created by TaoLiang on 2017/12/13.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

///MA8.1以后的业务逻辑抽出来写在这里,避免和以前的冲突
@interface SOSWebViewControllerHelper : NSObject<UINavigationControllerDelegate ,UIImagePickerControllerDelegate>
- (instancetype)initWithCustomeH5WebViewController:(SOSWebViewController *)vc;

-(void)pickPhotos:(NSInteger)maxNum;
/**
 选择照片\拍照

 @param para H5端参数
 */
- (void)pickPhoto:(NSDictionary *)para;

/**
 前往客户端原生界面
 
 @param para 根据该字段判断进入哪个页面
 */
- (void)goFunPage:(NSString *)para;


/**
 隐藏\显示导航条

 @param hide 是否隐藏
 */
- (void)hideNavBar:(BOOL)hide;


/**
 车况分享

 @return 车况分享JSON字符串
 */
- (NSString *)sendVehicleConditionToHTML;


#pragma mark - 9.0

/**
 显示客户端Toast提示
 
 @param flag 0：失败（❌），1：成功（✅），2：提示（❗️），3：加载中（转圈圈）
 @param text 主文本
 @param subText 次级文本
 */
- (void)showToast:(NSUInteger)flag text:(NSString *)text subText:(NSString *)subText;

-(void)helperExitMyDonateRefresh;
/**
 隐藏Toast
 */
- (void)dismissToast;

- (void)showAlertWithType:(NSUInteger)flag title:(NSString *)title message:(NSString *)message cancelBtn:(NSString *)cancelBtn otherBtns:(NSString *)otherBtns callback:(void (^)(NSUInteger))callback;

- (void)showForumShare:(NSString *)funcs sharedData:(NSString *)sharedData callback:(void (^)(NSUInteger buttonIndex))callback;

- (void)pushNewWebViewControllerWithUrl:(NSString *)urlString;

- (void)goBannerPage:(NSString *)para;

- (BOOL)showLoginVCAndShouldCheckVisitor:(BOOL)shouldCheckVisitor;
- (void)getUserLocationCallback:(void(^)(SOSPOI * currentP))callback;
- (void)onstarRefreshFootPrint ;
@end
