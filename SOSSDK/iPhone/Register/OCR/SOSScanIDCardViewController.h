//
//  SOSScanIDCardViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/10/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRegisterInformation.h"
@interface SOSScanIDCardViewController : UIViewController
@property(nonatomic,copy)scanFinishBlock scanIDCardBlock;
@property (nonatomic, assign) BOOL avaudioScanIDCardFront; //用于扫描身份证正面
@property (nonatomic, assign) BOOL isForMirror; //后视镜身份证扫描

- (void)AVCaptureRunning;
- (void)AVCaptureStopRunning;
- (void)configUIWithNoTitle;
@end
