//
//  SOSLoginUserDefaultVehicleVO.h
//  Onstar
//
//  Created by Onstar on 2018/3/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSIdmUser.h"
#import "SOSSubscriber.h"
#import "SOSOnstarSuiteVO.h"
#import "SOSUserSettings.h"
/**
 登录suite用户主信息
 */
@interface SOSLoginUserDefaultVehicleVO : NSObject
@property(nonatomic,copy)NSString *  idpUserId;
//Onstar IDM 系统用户信息
@property(nonatomic,strong)SOSIdmUser *  idmUser;
//Gaa 系统用户信息
@property(nonatomic,strong)SOSSubscriber * subscriber;
//车基本信息以及用户角色信息
@property(nonatomic,strong)SOSOnstarSuiteVO * currentSuite;
@property(nonatomic,strong)SOSUserPreference *  preference;

@property(nonatomic,strong)SOSUserSettings*  userSettings;
@end
