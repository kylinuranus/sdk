//
//  SOSPhotoLibrary.h
//  Onstar
//
//  Created by TaoLiang on 2018/8/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

//操作相册单例，使用PHPhotoLibrary，以后新的功能需要，自行添加。

NS_ASSUME_NONNULL_BEGIN

@interface SOSPhotoLibrary : NSObject


/**
 保存图片至设备，默认“安吉星”相簿

 @param image 图片
 */
+ (void)saveImage:(UIImage *)image;


/**
 保存图片至设备

 @param image 图片
 @param collectionName 相簿名称，如不存在则创建
 */
+ (void)saveImage:(UIImage *)image assetCollectionName:(NSString * _Nullable )collectionName;


/**
 保存图片至设备

 @param image 图片
 @param collectionName 相簿名称，如不存在则创建
 @param callback 回调
 */
+ (void)saveImage:(UIImage *)image assetCollectionName:(NSString * _Nullable )collectionName callback:(void (^ _Nullable )(BOOL success))callback;

/// 获取相册权限
/// @param callback 权限返回
+(void)getAuthorizationStatusCallback:(void (^ _Nullable )(BOOL success))photoCallback;
+(void)getAVAuthorizationStatusCallback:(void (^)(BOOL aVAuthSuccess))callback;

@end

NS_ASSUME_NONNULL_END
