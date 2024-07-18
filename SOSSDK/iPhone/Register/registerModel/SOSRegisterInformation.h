//
//  SOSRegisterInformation.h
//  Onstar
//
//  Created by lizhipan on 2017/8/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString * const jumpBBWCTimes;

//const NSArray *arrEnrollInfoType;
//#pragma mark - start 特定字符串->枚举型
////宏创建一个getter函数
//#define eEnrollInfoTypeGet (arrEnrollInfoType == nil ? arrEnrollInfoType = [[NSArray  alloc] initWithObjects:\
//           @"DRAFT",\
//           @"TOBEAUDIT",\
//           @"SUBMITTED",\
//           @"EXPIRED",\
//           @"SUCCEED",\
//           @"AUDITFAILED",\
//     nil] : arrEnrollInfoType)
//// 枚举 -> String
//#define eEnrollInfoTypeString(type) ([eEnrollInfoTypeGet objectAtIndex:type])
//// String -> 枚举
//#define eEnrollInfoTypeEnum(string) ([eEnrollInfoTypeGet indexOfObject:string])
//#pragma mark - end start 特定字符串->枚举型

typedef NS_ENUM(NSInteger, SOSRegisterType) {
    SOSRegisterVIN = 1,                    /// VIN注册
    SOSRegisterGOVID = 2,                  /// GOVID(身份证之类)注册
};
typedef NS_ENUM(NSInteger, SOSRegisterWayType) {
    SOSRegisterWayAddVehicle = 1,          /// 界面用于添加车辆流程进入的情况
    SOSRegisterWayNormalRegister = 2,      /// 界面用于正常注册流程进入的情况
    SOSRegisterWayUnknown = 3,
};
typedef NS_ENUM(NSInteger,SOSRegisterUserType){
    SOSRegisterUserTypeExist,              ///已经存在的用户
    SOSRegisterUserTypeFresh,              ///新注册用户
};
//enroll信息状态
typedef NS_ENUM(NSInteger, SOSEnrollInfoStatus) {
    SOSEnrollDraft= 0,                    /// 草稿
    SOSEnrollTobeAudit = 1,               ///
    SOSEnrollSubmitted = 2,               ///
    SOSEnrollExpired = 3,                ///
    SOSEnrollSucceed = 4,               ///
    SOSEnrollAuditFailed = 5
};
//扫描结果回调
@interface SOSScanResult : NSObject
@property(strong, nonatomic) UIImage *resultImg; //vin码区域图像
@property(strong, nonatomic) NSString *resultText; //vin码
@property(copy, nonatomic) NSString *fullNameText; //姓名
@property(copy, nonatomic) NSString *genderText; //-
@property(copy, nonatomic) NSString *addressText; //-
@end
typedef void(^scanFinishBlock)(SOSScanResult *scanValue);


@interface SOSUserBaseInformation : NSObject
@property(nonatomic,copy)NSString * vin;
@property(nonatomic,copy)NSString * mobile;
@property(nonatomic,copy)NSString * inputGovid;
@property(nonatomic,copy)NSString * firstName;
@property(nonatomic,copy)NSString * lastName;
@property(nonatomic,copy)NSString * gender;
@property(nonatomic,copy)NSString * accountType;
@property(nonatomic,copy)NSString * companyName;
@property(nonatomic,copy)NSString * province;
@property(nonatomic,copy)NSString * city;
@property(nonatomic,copy)NSString * address;
@property(nonatomic,copy)NSString * postcode;
@property(nonatomic,copy)NSString * password;
@property(nonatomic,copy)NSString * email;
@property(nonatomic,copy)NSString * saleDealer;
@property(nonatomic,copy)NSString * preferDealerCode;
@property(nonatomic,copy)NSString * subscriberId;
@property(nonatomic,copy)NSString * scanIssue;   //标识添加车辆用户角色

@end

#pragma mark - 提交用户输入以及扫描vin、idcard用以检查系统是否有对应subscriber信息
@interface SOSRegisterCheckRequest : SOSUserBaseInformation
@property(nonatomic,copy)NSString * scanGovid;
@property(nonatomic,copy)NSString * scanGovExpireDate;
@property(nonatomic,copy)NSString * imgGovFrontUrl;
@property(nonatomic,copy)NSString * imgGovBackUrl;
@property(nonatomic,copy)NSString * imgVehicleInvoiceUrl;
@property(nonatomic,copy)NSString * status;
@property(nonatomic,copy)NSString * idpID;      //addByWQ 20181229  微服务改造需求，添加一个idpuserid

@end
#pragma mark - 上传照片后返回照片url作为验证接口参数
@interface SOSRegisterCheckReceiptResponse: SOSUserBaseInformation
@property(nonatomic,copy)NSString * govid;
@property(nonatomic,copy)NSString * govFrontUrl;
@property(nonatomic,copy)NSString * govBackUrl;
@property(nonatomic,copy)NSString * vehicleInvoiceUrl;
@end
#pragma mark - 提交用户vin、idcard照片
@interface SOSRegisterUploadReceiptPic : SOSUserBaseInformation
@property(nonatomic,copy)NSString * govFront;
@property(nonatomic,copy)NSString * govBack;
@property(nonatomic,copy)NSString * vehicleInvoice;
@property(nonatomic,copy)NSString * extension;
@property(nonatomic,copy)NSString * govid; //TODO deperate
@end

@interface SOSEnrollInformation : SOSRegisterCheckRequest
@property(nonatomic,assign)BOOL  isMobileUnique;
@property(nonatomic,assign)BOOL  isEmailUnique;
@end
//提交完身份证照片后查找到gaa中govid对应的用户信息
@interface SOSEnrollGaaInformation : SOSRegisterCheckRequest
@property(nonatomic,copy)NSString *  accountID;
@property(nonatomic,copy)NSString *  saleDealerName;
@property(nonatomic,copy)NSString *  preferDealerName;
@property (nonatomic, assign) BOOL   bbwcDone;
@property (nonatomic, assign) BOOL   isBbwcDone;
@property(nonatomic,copy)NSString *  pin;
@property(nonatomic,copy)NSString *  insuranceCompany;
@property(nonatomic,copy)NSString *  brand;
@end

@interface SOSRegisterCheckRequestWrapper : NSObject
@property(nonatomic,strong)SOSRegisterCheckRequest *enrollInfo;
@end

@interface SOSRegisterScanIDCardInfoWrapper : NSObject
@property(nonatomic,copy)NSString *firstNameValue;
@property(nonatomic,copy)NSString *genderValue;
@property(nonatomic,copy)NSString *addressValue;
@end

@interface SOSRegisterCheckResponseWrapper : NSObject
@property(nonatomic,copy)NSString * code;
@property(nonatomic,strong)SOSEnrollGaaInformation *enrollInfo;
@end

@interface SOSRegisterCheckPINRequest : NSObject
@property(nonatomic,copy)NSString * accountID;
@property(nonatomic,copy)NSString * pin;
@property(nonatomic,assign)BOOL ignoreFailCount;
@end

@interface SOSBBWCSubmitWrapper : SOSEnrollGaaInformation
@property (nonatomic,copy) NSString * username;
@property (nonatomic,copy) NSString * idpUserId;
@property (nonatomic,strong) NSMutableArray *questions;
@end

@interface SOSRegisterSubmitWrapper : NSObject
@property(nonatomic,strong)SOSUserBaseInformation *enrollInfo;
@property(nonatomic,strong)SOSBBWCSubmitWrapper   *bbwcDTO;
@end

#pragma mark - end
@interface SOSRegisterInformation : NSObject
@property(nonatomic,assign)SOSRegisterType     registerType;
@property(nonatomic,assign)SOSRegisterWayType  registerWay;
@property(nonatomic,assign)SOSRegisterUserType registerUserType;
@property(nonatomic,copy)NSString * mobilePhoneNumer;
@property(nonatomic,copy)NSString * vin;
@property(nonatomic,copy)NSString * inputGovid;
@property(nonatomic,copy)NSString * email;
@property(nonatomic,copy)NSString * province;
@property(nonatomic,copy)NSString * gender;
@property(nonatomic,copy)NSString * accountType;
@property(nonatomic,strong)NNSubscriber * subscriber;
@property(nonatomic,strong)SOSEnrollInformation *enrollInfo;
//生成注册单例
+ (instancetype)sharedRegisterInfoSingleton;
//销毁注册单例
- (void)destroyRegisterInfoSingleton;
@end
