//
//  SOSCarSecretary.h
//  Onstar
//
//  Created by TaoLiang on 2018/1/26.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

/*这个类会去用runtime获取所有属性来判断是否显示我的中的提示横幅，8.2的时候不要加字段*/

@interface SOSCarSecretary : NSObject
///当前保险公司
@property (copy, nonatomic) NSString *insuranceComp;
///交强险到期日
@property (copy, nonatomic) NSString *compulsoryInsuranceExpireDate;
///商业保险到期日
@property (copy, nonatomic) NSString *businessInsuranceExpireDate;
///驾照到期日
@property (copy, nonatomic) NSString *licenseExpireDate;
///行驶证到期日
@property (copy, nonatomic) NSString *drivingLicenseDate;
///每月还贷日
@property (copy, nonatomic) NSString *loanRepaymentDay;
///最后还款日
@property (copy, nonatomic) NSString *lastRepayMentDay;
///判断是否超过30天
@property (assign, nonatomic) BOOL isVehicleSecretaryPopMsg;

@end
