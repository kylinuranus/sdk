//
//  InputGovidViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/9/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRegisterInformation.h"
typedef void(^govidFillBlock)(NSString *govid,SOSEnrollGaaInformation * subscriberInfo,NSString *error);

@interface InputGovidViewController : SOSBaseViewController
@property(nonatomic,copy)govidFillBlock fillBlock;
@property(nonatomic,copy)NSString * changeGovid;
@property (weak, nonatomic) IBOutlet UILabel *captchaErrorLabel;
@property(nonatomic,assign)BOOL isUseForAddVehicle; //是否用于添加车辆验证身份证界面
@end
