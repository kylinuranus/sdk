//
//  SOSUserPreference.h
//  Onstar
//
//  Created by Onstar on 2018/3/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SOSVehiclePreference : NSObject
@property(nonatomic,assign) BOOL fmvOpt; //findMyVehicle功能是否打开
@property(nonatomic,assign) BOOL remoteControlOpt; //remoteControl功能是否打开
@end

@interface SOSUserPreference : NSObject
@property(nonatomic,strong) id preferenceLanguage;
@property(nonatomic,copy)   NSString * avatarUrl;
@property(nonatomic,assign) BOOL autoRefreshData;
@property(nonatomic,copy)   NSString * defaultVin;
@property(nonatomic,strong) SOSVehiclePreference * vehiclePreference; //remoteControl功能是否打开
@property(nonatomic,assign) BOOL ecContactDisplay; //紧急联系人信息是否显示
@end

