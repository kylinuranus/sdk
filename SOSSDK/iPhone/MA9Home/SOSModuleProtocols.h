//
//  SOSModuleProtocols.h
//  Onstar
//
//  Created by Onstar on 2018/11/15.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#ifndef SOSModuleProtocols_h
#define SOSModuleProtocols_h

#pragma mark - homeTabbar protocol
@protocol SOSHomeTabBarControllerProtocol <NSObject>
/**
 -----------------------
 */
/**
 TODO
 废弃方法,避免编译出错,暂时写在这,后期删除
 @return
 */
@optional
- (UIViewController *)fetchContentViewController;
- (void)hideMenuViewController:(id)sender;
/**
 -----------------------
 */
@end

#pragma mark - vehicleTabbar protocol
@protocol SOSHomeVehicleTabProtocol <NSObject>
/**
 -----------------------
 */
@end

#pragma mark - tripTabbar protocol
@protocol SOSHomeTripTabProtocol <NSObject>
/**
 -----------------------
 */

/**
 -----------------------
 */
@end
#pragma mark - lifeTabbar protocol
@protocol SOSHomeLifeTabProtocol <NSObject>
/**
 -----------------------
 */

/**
 -----------------------
 */
@end

#pragma mark - meTabbar protocol
@protocol SOSHomeMeTabProtocol <NSObject>
/**
 -----------------------
 */

/**
 -----------------------
 */
@optional
//login
- (void)clickLogin;
//setting
- (void)clickSetting;
//notify
- (void)clickNotification;
//purchase package
- (void)clickPurchasePackage;
//purchase data package
- (void)clickPurchaseDataPackage;
//upgrade
- (void)clickUpgrade;
//首页使用
-(void)refreshWithHeaderViewStatus;


/**
 全局扫码
 */
- (void)onOverallScan;

@end



#endif /* SOSModuleProtocols_h */
