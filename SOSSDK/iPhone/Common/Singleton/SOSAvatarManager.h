//
//  SOSAvatarManager.h
//  Onstar
//
//  Created by TaoLiang on 2018/8/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 车辆图片分类

 - SOSVehicleAvatarTypeHomePage: 首页的车辆图片
 - SOSVehicleAvatarTypeOther: 其他页面的车辆图片
 */
typedef NS_ENUM(NSUInteger, SOSVehicleAvatarType) {
    SOSVehicleAvatarTypeHomePage,
    SOSVehicleAvatarTypeOther
};
/**
 头像管理模块（用户头像，MA9.0新增车辆图片管理）
 */
@interface SOSAvatarManager : NSObject


/**
 获取管理对象

 @return 头像管理单例
 */
+ (instancetype)sharedInstance;

#pragma mark - 用户头像
/**
 统一修改默认头像，如果未赋值，则使用内部默认图片
 */
@property (copy, nonatomic) NSString *placeholder;


/**
 获取用户头像接口
 
 @param avatarBlock 显示的头像回调,isPlaceholder代表是否是默认图，可不处理。由于未持有block，不会产生循环引用，安心食用。
 */
- (void)fetchAvatar:(void (^_Nullable)(UIImage * _Nullable avatar,  BOOL isPlacholder))avatarBlock;


/**
 保存头像接口

 @param image 图片
 @param urlString 图片地址,并且还作为缓存图片的Key
 */
- (void)saveImageToCache:(nullable UIImage *)image forURL:(nullable NSString *)urlString;



#pragma mark - 车辆图片


/**
 获取车辆图片

 @param type SOSVehicleAvatarType
 @param avatarBlock 回调，不存在retain cycle，可放心食用
 */
- (void)fetchVehicleAvatar:(SOSVehicleAvatarType)type avatarBlock:(void (^_Nullable)(UIImage * _Nullable avatar,  BOOL isPlacholder))avatarBlock;

@end

