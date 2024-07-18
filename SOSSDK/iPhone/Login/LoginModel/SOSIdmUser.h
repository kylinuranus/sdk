//
//  SOSIdmUser.h
//  Onstar
//
//  Created by Onstar on 2018/3/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSIdmUser : NSObject
@property(nonatomic,copy)NSString * idpUserId;
@property(nonatomic,copy)NSString * remoteUserID;
@property(nonatomic,copy)NSString * partyId;
@property(nonatomic,copy)NSString * userName;
//@property(nonatomic,copy)NSString * nickName;
@property(nonatomic,copy)NSString * firstName;
@property(nonatomic,copy)NSString * middleName;
@property(nonatomic,copy)NSString * lastName;
@property(nonatomic,copy)NSString * businessName;
@property(nonatomic,copy)NSString * gender;
@property(nonatomic,copy)NSString * birthDate;
@property(nonatomic,copy)NSString * jobTitle;
@property(nonatomic,copy)NSString * emailAddress;
//@property(nonatomic,copy)NSString * phoneNumber;
@property(nonatomic,copy)NSString * mobilePhoneNumber;
@property(nonatomic,copy)NSString * cellPhoneNumber;
@property(nonatomic,copy)NSString * workPhoneNumber;
@property(nonatomic,copy)NSString * faxNumber;
@property(nonatomic,copy)NSString * country;
@property(nonatomic,copy)NSString * stateProvince;
@property(nonatomic,copy)NSString * city;
@property(nonatomic,copy)NSString * address1;
@property(nonatomic,copy)NSString * address2;
@property(nonatomic,copy)NSString * address3;
@property(nonatomic,copy)NSString * postalCode;
@property(nonatomic,copy)NSString * msn;
@property(nonatomic,copy)NSString * qq;
@property(nonatomic,copy)NSString * applications;
@property(nonatomic,copy)NSString * status;

@property(nonatomic,copy)NSString * tcps;
@property(nonatomic,copy)NSString * tcpsAccepttime;
@property(nonatomic,copy)NSString * registerSource;

@property(nonatomic,copy)NSString * languagePreference;
@property(nonatomic,copy)NSString * fixedQuestion1ld;
@property(nonatomic,copy)NSString * fixedQuestion2ld;
@property(nonatomic,copy)NSString * fixedQuestion1Answer;
@property(nonatomic,copy)NSString * fixedQuestion2Answer;
@property(nonatomic,copy)NSString * remoteCommandOptld;

@property(nonatomic,copy)NSString * govid;
@property(nonatomic,copy)NSString * guid;
@property(nonatomic,copy)NSString * onstar_guid;
//@property(nonatomic,copy)NSString * accountNumber;    //NSDeprecate:使用currentsuite下面account.accountId
@property(nonatomic,copy)NSString * vin;
@property(nonatomic,assign)BOOL verification_status;//用户不是手机注册是否已经验证过
@property(nonatomic,copy)NSString * gmsync_status;
@property(nonatomic,copy)NSString * fromonstar;
@property(nonatomic,copy)NSString * i3_status;

@end
