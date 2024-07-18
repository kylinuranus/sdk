//
//  SOSOCRViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/10/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRegisterInformation.h"

typedef NS_ENUM(NSInteger, ScanType) {
    ScanALLType = 0,                    /// VIN+ (身份证)
    ScanIDCard = 1,                  /// (身份证)
    ScanVIN = 2,                  ///VIN
};
@interface SOSOCRViewController : UIViewController
@property(nonatomic,assign)BOOL          scanIDCardFront; //当扫描身份证时，是否是扫码正面
@property(nonatomic,assign)ScanType      currentType;
@property(nonatomic,copy)scanFinishBlock scanBlock;
@property(nonatomic,copy)NSString * backFunctionID;
@end
