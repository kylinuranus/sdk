//
//  SOSQRManager.h
//  Onstar
//
//  Created by Genie Sun on 16/6/20.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSQRManager : NSObject

+ (instancetype)shareInstance;

/// 检查相机权限
- (BOOL)checkAuthStatus;

/**
 *  生成二维码
 *
 *  @param inputMsg 二维码保存的信息
 *  @param fgImage  前景图片
 *
 *  @return 返回的二维码图片
 */
- (UIImage *)generateQRCodeWithMsg:(NSString *)inputMsg fgImage:(UIImage *)fgImage;


/**
 *  识别二维码图片
 *
 *  @param qrCodeImage 二维码的图片
 *
 *  @return 结果的数组
 */
- (NSArray *)detectorQRCodeWithQRCodeImage:(UIImage *)qrCodeImage;

/**
 *  开始扫描
 *
 *  @param inView 图层添加到哪一个View中
 *  @param scanView 扫描区域的View
 */
- (void)startScanningQRCodeWithInView:(UIView *)inView  scanView:(UIView *)scanView resultCallback:(void(^)(NSArray *results))callback;
- (void)startScanningQRCodeWithInView01:(UIView *)inView scanView:(UIView *)scanView resultCallback:(void(^)(NSArray *results))callback;

/// 停止扫描
- (void)stopScanner;

/**
 恢复扫码
 */
- (void)resumeScan;
/// 打开闪光灯
- (void)openFlash;
/// 关闭闪光灯
- (void)closeFlash;

@end
