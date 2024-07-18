
//
//  SOSAlertViewDelegate.h
//  SOSCustomAlertView
//
//  Created by Genie Sun on 2017/7/13.
//  Copyright © 2017年 Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOSCustomAlertView;


/// 弹出框的展示内容形式
typedef NS_ENUM(NSUInteger ,AlertPageMode){
    SOSAlertViewModelContent,               //普通文本
    SOSAlertViewModelCallPhone,             //致电
    SOSAlertViewModelCallPhoneOnlyPhone,    //致电,仅显示电话号码
    SOSAlertViewModelCallPhone_Icon,       	//致电
    SOSAlertViewModelRemovedStatement,      //免职声明
    SOSAlertViewModelVehicleSurvey,         //车况自动监测
    SOSAlertViewModelSendDown,              //路线下发
    SOSAlertViewModelRegister,          	//车辆注册请求
    SOSAlertViewModelRegisterFail,     		//车辆注册失败
    SOSAlertViewModelTitleAndIcon,          //title & image icon
    SOSAlertViewModelNotification,          //消息推送弹出框
    SOSAlertViewModelCallPhoneMusic,         //云音乐模块下的样式
    SOSAlertViewModelMirrorBindSuccess,      //智能后视镜绑定成功的样式
    SOSAlertViewModelMirrorUnbindSuccess,         //智能后视镜绑定失败的样式
    SOSAlertViewModelMirrorUpdate,           //智能后视镜用户信息更新完成的样式
    SOSAlertViewModelUpgrade,               //提示升级远程功能
    SOSAlertViewModelNavSendDown            //提示升级远程功能
};

typedef NS_ENUM(NSUInteger, AlertButtonMode){
    SOSAlertButtonModelVertical,        	//按钮纵向
    SOSAlertButtonModelHorizontal      		//按钮横向
};

typedef NS_ENUM(NSUInteger, AlertViewBackGroundMode){
    SOSAlertBackGroundModelStreak,           //带条纹的背景
    SOSAlertBackGroundModelWhite         	//纯白色的背景
};


@protocol SOSAlertViewDelegate <NSObject>

@optional

/**
 tell us whitch button is clicked
 
 @param alertView 哪一个alertview
 @param buttonIndex 哪一个button点击
 */
- (void)sosAlertView:(SOSCustomAlertView *)alertView didClickButtonAtIndex:(NSInteger )buttonIndex;

@end

