//
//  SOSNotificationKeys.h
//  Onstar
//
//  Created by TaoLiang on 2018/1/17.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#ifndef SOSNotificationKeys_h
#define SOSNotificationKeys_h



/*AppDelegate_iPhone*/


//路径起点/终点变化通知
#define SOSRoutePOIInfoChangeNotification        @"KRoutePOIInfoChangeNotification"

/*message*/
#define SOSUNREAD_MESSAGE_ALERT                  @"UNREAD_MESSAGE_ALERT"
#define SOSGetBroadcastError                     @"getBroadCastError"

/*CustomFloatButton*/
#define SOS_SMALL_O_LEFT_OR_RIGHT                @"smallo_left_or_right"

/*LoginManage*/
#define SOS_ACCOUNT_VEHICLE_HAS_CHANGED          @"AccountVehicleHasChanged"
#define SOS_AUTO_LOGIN_FAIL                      @"AutoLoginFail"
#define SOS_PresentTouchID_Notification          @"SOS_PresentTouchID_Notification"

/*MeSystemSettingsViewController*/
//#define SOS_DRIVING_SCORE_TRIGGER                @"SOS_DRIVING_SCORE_TRIGGER"
//小O开关状态改变通知
#define SOS_CHANGE_MRO_SETTING_OPEN_STATE_NOTIFICATION   @"CHANGE_MRO_SETTING_OPEN_STATE_NOTIFICATION"
//Onstar link
#define SOSOnstarLinkButtonStateShouldChangeNotification	@"SOSOnstarLinkButtonStateShouldChangeNotification"

/*AutoNaviAdapter*/
#define SOS_AutoNaviAdapter_GetWeather           @"GetWeather"
#define SOS_AutoNaviAdapter_GetRestrict          @"GetRestrict"

#define SOSNotifacationChangeGeo                 @"KNotifacationChangeGeo"

/*MrOSearchPoiCell*/
#define SOSsendToCarTBTnotice                    @"sendToCarTBTnotice"

/*SOSRemoteControlViewController*/
//车辆操作通知
#define SOS_VEHICLE_OPERATE_NOTIFICATION         @"VEHICLE_OPERATE_NOTIFICATION"
#define SOSCarOperationNotification              @"CarOperationNotification"

/*SOSOnstarPackageVC*/
#define SOS_IAP_BUY_ONSTARPACKAGE                @"IAP_BUY_ONSTARPACKAGE"
//购买套餐包通知
#define SOS_IAP_BUY_4GPACKAGE                    @"IAP_BUY_4GPACKAGE"
//弹出安全问题页面
//#define SOS_PopupQaQuestion                       @"PopupQaQuestion"

#define SOS_Map_ScrollView_DidEndDecelerating		@"SOS_Map_ScrollView_DidEndDecelerating"


#endif /* SOSNotificationKeys_h */
