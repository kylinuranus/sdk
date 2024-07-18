//
//  SOSDaapFuncID90.h
//  Onstar
//
//  Created by TaoLiang on 2019/3/1.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#ifndef SOSDaapFuncID90_h
#define SOSDaapFuncID90_h

//HP主页
#define SPLASH_AD                                                             @"HP0008"//APP闪屏广告_点击看详细
#define HOMEPAGE_NEWS_REMIND                                                  @"HP0009"//主页_消息提醒（车况提醒）
#define SPLASH_AD_SKIP                                                        @"HP0010"//APP闪屏广告_跳过(点击跳过）
#define SPLASH_AD_SKIP_AUTO                                               	  @"HP0012"//APP闪屏广告_跳过(倒计时结束跳过）
//#define SPLASH_AD_PIC_LOADTIME                                                @"HP0015"//APP闪屏广告_图片加载成功时间（单位毫秒）
#define NAV_VEHICLE                                                           @"HP0016"//导航_车辆
#define NAV_TRIP                                                              @"HP0017"//导航_旅途
#define NAV_ON                                                                @"HP0018"//导航_On键
#define NAV_LIFE                                                              @"HP0019"//导航_生活
#define NAV_ME                                                                @"HP0020"//导航_我的
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL8                                @"MO0024"//点击小O成功跳转至小O页面
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL9                                @"MO0025"//跳转至小O页面成功
#define LOGIN_TIME                                                            @"HP0021"//手机用户点击登录到首页加载完成的时长(单位毫秒）。包含自动登录用户打开app到首页加载完成的时长(单位毫秒）。
#define LOGIN_TIME1                                                            @"HP0098"//自动登录埋点。
#define LOGIN_TIME2                                                            @"HP0099"//手动登录埋点。

#define Login_token                                                            @"HP0031"
#define Login_suite                                                            @"HP0032"
#define Login_availablefuncs                                                   @"HP0033"
#define Login_commands                                                         @"HP0034"



#define INTRODUCTION_PAGE1_SKIP                                               @"HP0022"//操作指引_第一页_跳过
#define INTRODUCTION_PAGE2_SKIP                                               @"HP0023"//操作指引_第二页_跳过
#define INTRODUCTION_PAGE3_SKIP                                               @"HP0024"//操作指引_第三页_跳过
#define INTRODUCTION_PAGE4_SKIP                                               @"HP0025"//操作指引_第四页_跳过
#define INTRODUCTION_PAGE5_SKIP                                               @"HP0026"//操作指引_第五页_跳过
#define INTRODUCTION_PAGE5_GO                                                 @"HP0027"//操作指引_第五页_开启安吉星
#define INTRODUCTION_STAYTIME                                                 @"HP0028"//操作指引停留时长（用户进入到离开（含点击跳过离开以及完成离开））手机端上报：1.进入操作指引首页的时刻2.离开操作指引页面的时刻（单位毫秒）

//旅途

#define TRIP_FUELCONSUMPTIONCARDTIME                                  		  @"ST0018"//旅途_油耗排名卡片（记录成功开始加载时间、加载结束时间）
#define TRIP_ENERGYCONSUMPTIONCARDTIME                               		  @"ST0020"//旅途_能耗排名卡片（记录成功开始加载时间、加载结束时间）
#define TRIP_SMARTDRIVERCARDTIME                                      		  @"ST0022"//旅途_驾驶评分卡片（记录成功开始加载时间、加载结束时间）
#define TRIP_FOOTPRINTSCARDTIME                                     		  @"ST0024"//旅途_我的足迹卡片（记录成功开始加载时间、加载结束时间）
#define TRIP_GOWHERE                                                          @"ST0001"//旅途_去哪
#define TRIP_MYLOCATION                                                       @"ST0002"//旅途_我的位置
#define TRIP_MYLOCATION_SHARE                                                 @"TR0030"//旅途_我的位置_分享
#define TRIP_MYLOCATION_SHARECANCEL                                           @"TR0031"//旅途_车辆位置_分享_取消
#define TRIP_MYLOCATION_SHARE_MOMENTS                                         @"TR0032"//旅途_我的位置_分享_微信朋友圈
#define TRIP_MYLOCATION_SHARE_WECHAT                                          @"TR0033"//旅途_我的位置_分享_微信好友
#define TRIP_MYLOCATION_FAVORITETAB                                           @"TR0028"//旅途_我的位置_收藏地点
#define TRIP_MYLOCATION_SEARCHAROUND                                          @"TR0029"//旅途_我的位置_周边搜索
#define TRIP_MYLOCATION_RETEST                                                @"TR0093"//旅途_我的位置_重新获取我的位置
#define TRIP_VEHICLELOCATION                                                  @"ST0004"//旅途_车辆定位
#define TRIP_VEHICLELOCATION_RETEST                                           @"TR0094"//旅途_车辆定位_重新获取车辆位置
#define TRIP_VEHICLELOCATION_FINDMYCAR                                        @"TR0075"//旅途_车辆定位_导航找车
#define TRIP_VEHICLELOCATION_SHARE                                            @"TR0095"//旅途_车辆定位_分享
#define TRIP_VEHICLELOCATION_SHARECANCEL                                      @"TR0096"//旅途_车辆定位_分享_取消
#define TRIP_VEHICLELOCATION_SHARE_MOMENTS                                    @"TR0097"//旅途_车辆定位_分享_微信朋友圈
#define TRIP_VEHICLELOCATION_SHARE_WECHAT                                     @"TR0098"//旅途_车辆定位_分享_微信好友
#define TRIP_VEHICLELOCATION_MORE                                             @"TR0099"//旅途_车辆定位_更多
#define TRIP_VEHICLELOCATION_GEOFENCE                                         @"TR0100"//旅途_车辆定位_电子围栏
#define TRIP_VEHICLELOCATION_CHENGEVEHICLE                                    @"TR0101"//旅途_车辆定位_切换车辆
#define TRIP_VEHICLELOCATION_CANCEL                                           @"TR0102"//旅途_车辆定位_取消
#define TRIP_FUELCONSUMPTION                                                  @"ST0011"//旅途_油耗排名卡片
#define TRIP_ENERGYCONSUMPTION                                                @"ST0012"//旅途_能耗排名卡片
#define TRIP_SMARTDRIVER                                                      @"ST0013"//旅途_驾驶评分卡片
#define TRIP_FOOTPRINTS                                                       @"ST0014"//旅途_我的足迹卡片
#define TRIP_LBS                                                              @"ST0015"//旅途_安星定位
#define TRIP_LBS_AGREE                                                        @"TL0080"//旅途_安星定位_协议同意
#define TRIP_LBS_THINKMORE                                                    @"TL0081"//旅途_安星定位_协议再想想
#define TRIP_LBS_ADDNEW                                                       @"TL0082"//旅途_安星定位_绑定新设备
#define TRIP_LBS_ADD                                                          @"TL0001"//旅途_安星定位_添加设备
#define TRIP_LBS_RETEST                                                       @"TL0083"//旅途_安星定位_获取失败重新加载
#define TRIP_COMPANY                                                          @"ST0026"//旅途_公司
#define TRIP_HOME                                                             @"ST0027"//旅途_回家
#define TRIP_NAVIGATIONFAIL_KNOW                                              @"TR0037"//旅途_导航下发失败_知道了
#define TRIP_NAVIGATIONFAIL_NO                                                @"TR0103"//旅途_导航下发失败_地址未设置_不了
#define TRIP_NAVIGATIONFAIL_SET                                               @"TR0104"//旅途_导航下发失败_地址未设置_去设置
#define TRIP_FUELCONSUMPTIONPAGETIME                                 		  @"FE0078"
#define TRIP_ENERGYCONSUMPTIONPAGETIME                               		  @"EE0063"
#define TRIP_SMARTDRIVERPAGETIME                                     	 	  @"SD0045"
#define TRIP_FOOTPRINTSPAGETIME_SUCCEED                              		  @"FT0008"
#define Trip_Veh_GetLocation_Loadtime                                		  @"TR0105"

//生活
#define LIFE_REFRESH                                                          @"LI0001"//生活_下拉刷新
#define LIFE_BANNER                                                           @"JL0069"//生活_广告
//#define LIFE_BANNERTIME                                                       @"LI0002"//生活_广告页面加载成功开始时间、加载结束时间
#define LIFE_MORE                                                             @"LI0004"//生活_实用功能更多
#define LIFE_SOCIAL                                                           @"JL0087"//生活_星友圈

//生活_实用功能

#define UF_ONSTARLINK                                                         @"SH0038"//智能互联
#define UF_JOYLIFE_CLUB_CHEVROLET                                             @"JL0057"//车主俱乐部-雪弗兰
#define UF_JOYLIFE_CLUB_CADILLAC                                              @"JL0058"//车主俱乐部-凯迪拉克
#define UF_VIOLATION_SEARCH                                                   @"JL0044"//违章查询
#define UF_RISKCHECK                                                          @"VS0001"//险贷检提醒
#define UF_MUSIC                                                              @"JL0084"//随星听
#define UF_MAINTENANCE                                                        @"JL0068"//保养建议
#define UF_JOYLIFE                                                            @"JL0098"//安悦扫码充电
#define UF_CARVALUATIONCARD                                                   @"SV0011"//爱车评估
#define UF_RECOMMENDATION                                                     @"JL0085"//星推荐
#define UF_DRIVELICENSE                                                       @"JL0027"//换证
#define UF_TRAVELSECURE                                                       @"UF0001"//出行保障
#define UF_INSPECTION                                                         @"UF0002"//车检
#define UF_BOOKSOUND                                                          @"UF0003"//有声书
#define UF_COMMONWEAL                                                         @"UF0004"//安吉星公益
#define UF_CHANGE                                                             @"UF0005"//实用功能_编辑
#define UF_BACK                                                               @"UF0006"//实用功能_返回
#define UF_CHANGESAVE                                                         @"UF0007"//实用功能_编辑保存
#define UF_CHANGECANCEL                                                       @"UF0008"//实用功能_编辑取消（安卓为返回箭头）
#define UF_CHANGESAVE_A                                                       @"UF0009"//实用功能_编辑弹窗保存（仅针对安卓）
#define UF_CHANGECANCEL_A                                                     @"UF0010"//实用功能_编辑弹窗取消（仅针对安卓）


//MY我的(模块)
#define ME_SS_HOMEMESSAGECARD_SETTING                                         @"SE0094"//我的_服务设置_首页消息卡片设置
#define ME_NS_FORUMMESSAGE                                                    @"SE0095"//我的_提醒设置_论坛消息
#define ME_PAGERELOAD_DRAG                                                    @"SV0001"//我的_下拉刷新
#define ME_MESSAGECENTER                                                      @"M0003"//我的_消息中心
#define ME_SET                                                                @"MY0052"//我的_设置
#define ME_MY                                                                 @"M0005"//我的_头像
#define ME_SERVICEPACKAGE_CURRENTPACKAGETAB                                   @"PC0005"//我的_剩余天数
#define ME_DATAPACKAGE_CURRENTPACKAGETAB                                      @"PC0020"//我的_剩余流量
#define ME_PURCHASE_HOTSALE                                                   @"PC0010"//我的_购买套餐
#define ME_PURCHASE_DATA                                                      @"PC0013"//我的_流量充值
#define ME_UBI                                                                @"ST0010"//我的_车联保险
#define ME_UBI_MORE                                                           @"UB0015"//我的_车联保险_更多
#define ME_UBI_CHECKNOW                                                       @"UB0016"//我的_车联保险_立即查看
#define ME_ONSTARTRAVEL_ONSTARTRIP                                            @"AC0001"//我的_星享之旅_安星之旅
#define ME_ONSTARTRAVEL_FOLLOWSTARTRIP                                        @"AC0011"//我的_星享之旅_智星之旅
#define ME_ONSTARTRAVEL_SMARTSTARTRIP                                         @"AC0019"//我的_星享之旅_随星之旅
#define ME_ONSTARTRAVEL_LUCKSTARTRIP                                          @"AC0029"//我的_星享之旅_吉星之旅
#define ME_ONSTARTRAVEL_ONSTARGUARD                                           @"AC0031"//我的_星享之旅_On星之旅
//#define ME_SERVICEPACKAGES_SERVICEPACKAGE                                     @"PC0001"//我的_套餐_安吉星套餐
//#define ME_SERVICEPACKAGES_DATAPACKAGE                                        @"PC0024"//我的_套餐_4G互联套餐
//#define ME_SERVICEPACKAGES_AUTORENEWPACKAGE                                   @"PC0046"//我的_套餐_自动续约套餐
//#define ME_SERVICEPACKAGES_PREPAIDCARD                                        @"PC0025"//我的_套餐_预付费卡激活
#define ME_CASHFLOW                                                           @"JL0065"//我的_用车手账
#define ME_CASHFLOW_ADD                                                       @"CF0002"//我的_用车手账_记一笔
#define ME_MYCOMMONWEAL                                                       @"MY0114"//我的_我的公益
#define MY_Message_banner_loadtime                                                       @"MY0145"//我的_消息中心_banner加载时长（开始时间/结束时间/加载结果）
//#define ME_CUSTOMERSERVICE_USERMANUAL                                         @"MY0062"//我的_客户服务_用户手册
//#define ME_CUSTOMERSERVICE_ABOUTONSTAR                                        @"MY0095"//我的_客户服务_关于安吉星
//#define ME_CUSTOMERSERVICE_QUESTIONFEEDBACK                                   @"MY0079"//我的_客户服务_问题反馈
//#define ME_CUSTOMERSERVICE_CONTACT                                            @"ME0001"//我的_客户服务_联系官方

//车辆

#define VEHICLE_PAGERELOAD_DRAG                                               @"CA0019"//车辆_下拉刷新
#define CARCONDITION_RELOAD                                                   @"SV0005"//车况卡片_重新加载
#define SMARTVEHICLE_BANNER                                                   @"SV0015"//车辆Banner位（对应原智享车banner)
#define AREMANUAL                                                             @"SV0016"//AR电子手册
#define STARTRAVELTT                                                          @"TT0004"//首页置顶文案
#define GETPERSONALINFOR_FAIL                                                 @"CA0001"//个人信息获取失败
#define GETPERSONALINFOR_FAIL_CLICKREFRESH                                    @"CA0002"//个人信息获取失败->点击刷新
//#define VEHICLEPIC_LOAD_FAIL                                                  @"CA0003"//车辆图片获取失败
#define VEHICLEPIC_LOAD_TIME                                                  @"CA0004"//车辆图片获取时间（时长为毫秒）
#define VEHICLEDIA_PIC_CLICK_ENTRY                                            @"CA0005"//车况_图片_点击_进入车况
#define VEHICLEDIA_ENTRY                                                      @"CA0006"//车辆_我的车况
#define VEHICLE_LOGIN_                                                        @"CA0007"//车辆_立即登录
#define VEHICLE_INFORFLOW_LOGIN_                                              @"CA0008"//车辆_信息流_登录安吉星
//#define VEHICLE_INFORFLOW_CARD_CLICK                                          @"CA0009"//车辆_信息流_卡片_点击（需要上传Business ID)
//#define VEHICLE_INFORFLOW_LINK_CLICK                                          @"CA0010"//车辆_信息流_链接_点击（需要上传Business ID)
//#define VEHICLE_INFORFLOW_BUTTON_CLICK                                        @"CA0011"//车辆_信息流_按钮_点击（需要上传Business ID)
//#define VEHICLE_INFORFLOW_CARD_DELETE                                         @"CA0012"//车辆_信息流_卡片_删除（需要上传Business ID)
#define VEHICLE_GETLOCATION                                                   @"CA0013"//车辆_点击获取车辆位置
#define VEHICLE_CHECKLOCATION                                                 @"CA0014"//车辆_点击查看车辆位置
#define VEHICLEDIA_LOADTIME                                                   @"CA0015"//车辆_首页车况的加载时长（单位为毫秒）
#define VEHICLE_GETLOCATION_LOADTIME                                          @"CA0016"//车辆_获取车辆位置的加载时长（从PIN码输入完成到加载完成）
#define VEHICLE_INFORFLOW_LOADTIME                                            @"CA0017"//车辆_信息流加载时长（单位为毫秒）（从信息流开始加载到加载完成）
#define SMARTVEHICLE_BANNER_LOADTIME                                          @"CA0018"//车辆Banner位加载时长（单位为毫秒）（从开始加载到图片加载完成）

//ON键
#define REMOTECONTROL_UNLOCK                                                  @"VC0002"//远程遥控_车门解锁
#define REMOTECONTROL_LOCK                                                    @"VC0003"//远程遥控_车门上锁
#define REMOTECONTROL_START                                                   @"VC0004"//远程遥控_远程启动
#define REMOTECONTROL_STOP                                                    @"VC0005"//远程遥控_远程熄火
#define REMOTECONTROL_LIGHTHORN                                               @"VC0006"//远程遥控_闪灯鸣笛
#define REMOTECONTROL_GUIDE                                                   @"VC0007"//远程遥控_使用说明
#define REMOTECONTROL_CARSHARE                                                @"VC0008"//远程遥控_车辆共享中心_远程遥控共享中心
#define REMOTECONTROL_WINDOWSUNLOCK                                           @"VC0018"//远程遥控_打开车窗
#define REMOTECONTROL_WINDOWSLOCK                                             @"VC0019"//远程遥控_关闭车窗
#define REMOTECONTROL_SUNROOFUNLOCK                                           @"VC0020"//远程遥控_打开天窗
#define REMOTECONTROL_SUNROOFLOCK_                                            @"VC0021"//远程遥控_关闭天窗
#define REMOTECONTROL_TRUNKUNLOCK                                             @"VC0022"//远程遥控_打开后备箱
#define REMOTECONTROL_DATAREFRESH                                             @"VC0023"//远程遥控_车况刷新
#define REMOTECONTROL_HVACSETTINGS                                            @"VC0024"//远程遥控_空调设置
#define REMOTECONTROL_HVACSETTINGS_BACK                                       @"VC0025"//远程遥控_空调设置_取消
#define REMOTECONTROL_HVACSETTINGS_ON                                         @"VC0026"//远程遥控_空调设置_空调开关开
#define REMOTECONTROL_HVACSETTINGS_OFF                                        @"VC0027"//远程遥控_空调设置_空调开关关
#define REMOTECONTROL_HVACSETTINGS_AUTO                                       @"VC0028"//远程遥控_空调设置_Auto
#define REMOTECONTROL_HVACSETTINGS_MAXFROEST                                  @"VC0029"//远程遥控_空调设置_Maxfroest
#define REMOTECONTROL_HVACSETTINGS_REARDEFOG                                  @"VC0030"//远程遥控_空调设置_reardefog
#define REMOTECONTROL_HVACSETTINGS_AIRINLET                                   @"VC0031"//远程遥控_空调设置_AirInlet
#define REMOTECONTROL_HVACSETTINGS_VENT                                       @"VC0032"//远程遥控_空调设置_vent
#define REMOTECONTROL_HVACSETTINGS_BI_LEVEL                                   @"VC0033"//远程遥控_空调设置_bi-level
#define REMOTECONTROL_HVACSETTINGS_FLOOR                                      @"VC0034"//远程遥控_空调设置_floor
#define REMOTECONTROL_HVACSETTINGS_FLOORWINDSHIELD                            @"VC0035"//远程遥控_空调设置_floorwindshield
#define REMOTECONTROL_HVACSETTINGS_SPEEDLOW                                   @"VC0036"//远程遥控_空调设置_风速减
#define REMOTECONTROL_HVACSETTINGS_SPEEDHIGH                                  @"VC0037"//远程遥控_空调设置_风速加
#define REMOTECONTROL_HVACSETTINGS_TEMPERATURELOW                             @"VC0038"//远程遥控_空调设置_温度减
#define REMOTECONTROL_HVACSETTINGS_TEMPERATUREHIGH                            @"VC0039"//远程遥控_空调设置_温度加
#define REMOTECONTROL_HVACSETTINGS_SEND                                       @"VC0040"//远程遥控_空调设置_下发到车

#define Remotecontrol_unlock_OpTime                                       	  @"VC0041"//远程遥控_车门解锁_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_lock_OpTime                                             @"VC0042"//远程遥控_车门上锁_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_lighthorn_OpTime                                        @"VC0043"//远程遥控_闪灯鸣笛_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_windowsunlock_OpTime                                    @"VC0044"//远程遥控_开启车窗_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_windowslock_OpTime                                      @"VC0045"//远程遥控_关闭车窗_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_sunroofunlock_OpTime                                    @"VC0046"//远程遥控_开启天窗_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_sunrooflock_OpTime                                      @"VC0047"//远程遥控_关闭天窗_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_trunkunlock_OpTime                                      @"VC0048"//远程遥控_开后备箱_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_hvacsettings_OpTime                                     @"VC0049"//远程遥控_空调设置_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_StartEngine_OpTime                                      @"VC0050"//远程遥控_远程启动_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_CancelStartEngine_OpTime                                @"VC0051"//远程遥控_取消启动_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_TBT_OpTime                                              @"VC0053"//远程遥控_下发TBT_操作时长（开始时间/结束时间/操作结果）
#define Remotecontrol_ODD_OpTime                                              @"VC0054"//远程遥控_下发ODD_操作时长（开始时间/结束时间/操作结果）


#define VEHICLEINFO_CHANGECARS                                                @"VI0027"//车辆信息_切换车辆
#define VEHICLEINFO_CHANGECARS_BACK                                           @"VI0028"//车辆信息_切换车辆_返回
#define VEHICLEINFO_CHANGECARS_ADDVEHICLE                                     @"VI0029"//车辆信息_切换车辆_添加车辆
#define VEHICLEINFO_OPERATHISTORY                                             @"VI0002"//车辆信息_操作历史
#define VEHICLEINFO_OPERATHISTORY_BACK                                        @"VI0003"//车辆信息_操作历史_返回
#define ON_VEHICLESHARINGCENTER_CLICK                                         @"ON0001"//On键_车辆共享中心_点击
#define ON_ICMVEHICLESTATUS_SUCCESS                                           @"ON0002"//ON键_ICM部件状态_显示成功
#define ON_ICMVEHICLESTATUS_CLICK_REFRESH                                     @"ON0003"//ON键_ICM部件状态_点击刷新
#define ON_CARSHARINGCENTER                                                   @"ON0004"//On键_车辆共享中心_点击
#define SMARTVEHICLE_BLE_KEYENTRY                                             @"SV0021"//On键_车辆共享中心_我收到的蓝牙钥匙共享
#define SMARTVEHICLE_BLE_CARSHARINGENTRY                                      @"SV0022"//On键_车辆共享中心_蓝牙钥匙共享管理

//快捷键
#define QUICKLY_MORE                                                          @"HB0001"//快捷键_更多
#define QUICKLY_REMOTESTART                                                   @"HB0002"//快捷键_远程启动
#define QUICKLY_CANCELSTART                                                   @"HB0003"//快捷键_取消启动
#define QUICKLY_DOORLOCK                                                      @"HB0004"//快捷键_车门上锁
#define QUICKLY_DOORUNLOCK                                                    @"HB0005"//快捷键_车门解锁
#define QUICKLY_HORNSLIGHTS                                                   @"HB0006"//快捷键_闪灯鸣笛
#define QUICKLY_LOCATOR                                                       @"HB0007"//快捷键_车辆位置
#define QUICKLY_DEALERRESERVATION                                             @"HB0008"//快捷键_经销商预约
#define QUICKLY_PREFERDEALER                                                  @"HB0009"//快捷键_首选经销商
#define QUICKLY_RECENTHISTORY                                                 @"HB0010"//快捷键_车辆历史操作
#define QUICKLY_SECURITYZONE                                                  @"HB0011"//快捷键_电子围栏
#define QUICKLY_CHARGEMANAGEMENT                                              @"HB0013"//快捷键_充电管理
#define QUICKLY_VEHICULARWIFI                                                 @"HB0014"//快捷键_车载WiFi
#define QUICKLY_SEARCHPOI                                                     @"HB0019"//快捷键_搜索兴趣点（即刻出发）
#define QUICKLY_TOHOME                                                        @"HB0020"//快捷键_一键到家
#define QUICKLY_TOOFFICE                                                      @"HB0021"//快捷键_一键到公司
#define QUICKLY_OVD                                                           @"HB0022"//快捷键-车辆检测报告
#define QUICKLY_CLUB                                                          @"HB0023"//快捷键-车主俱乐部（凯迪拉克）
#define QUICK_CLUB                                                            @"HB0024"//快捷键-车主俱乐部（雪佛兰）
#define QUICK_SERVICEPACKAGE                                                  @"HB0025"//快捷键-购买套餐包
#define QUICK_LBS                                                             @"HB0027"//快捷键_安星定位
#define QUICK_CHARGESTATION                                                   @"HB0028"//快捷键_附近充电站
#define QUICK_EDIT                                                            @"HB0030"//快捷键_编辑
#define QUICK_DONE                                                            @"HB0031"//快捷键_完成
#define BACKTOHOME                                                            @"HB0032"//返回主界面
#define QUICKLY_OPENSUNROOF                                                   @"HB0035"//快捷键_天窗开启
#define QUICKLY_CLOSESUNROOF                                                  @"HB0036"//快捷键_天窗关闭
#define QUICKLY_OPENWINDOWS                                                   @"HB0037"//快捷键_车窗开启
#define QUICKLY_CLOSEWINDOWS                                                  @"HB0038"//快捷键_车窗关闭
#define QUICKLY_OPENTRUNK                                                     @"HB0039"//快捷键_后备箱开启
#define QUICKLY_HVACSETTING                                                   @"HB0040"//快捷键_空调操控
#define QUICKLY_BLE_SHAREMYCAR                                                @"HB0041"//快捷键_蓝牙钥匙共享
#define QUICKLY_BLE_RECEIVEDSHARING                                           @"HB0042"//快捷键_蓝牙钥匙包
#define QUICKLY_OILSTATION                                                    @"HB0043"//快捷键_附近加油站
#define QUICKLY_MYTRIP                                                        @"HB0044"//快捷键_近期行程(驾驶行为评价二级功能)
#define QUICKLY_ONSTARFRIEND                                                  @"HB0045"//快捷键_星友圈
#define QUICKLY_REARVIEW                                                      @"HB0046"//快捷键_智能后视镜
#define QUICKLY_ANYUECHARGE                                                   @"HB0047"//快捷键_安悦扫码充电
#define QUICKLY_CHEDAIXIANREMIND                                              @"HB0048"//快捷键_车贷险提醒
#define QUICKLY_CARESTIMATE                                                   @"HB0049"//快捷键_爱车评估
#define QUICKLY_ONSTARLINK                                                    @"HB0050"//快捷键_智联映射

//车辆-车况
#define CARCONDITIONS_BACK                                                    @"CC0001"//车况_返回
#define CARCONDITIONS_MAINTAINSUGGEST                                         @"CC0004"//车况_查看维修保养建议
#define CARCONDITIONS_MAINTAINSUGGEST_BACK                                    @"CC0005"//车况_保养建议_返回
#define CARCONDITIONS_MAINTAINSUGGEST_CONTACTDEALER                           @"CC0006"//车况_保养建议_联系经销商
#define CARCONDITIONS_SEARCHNEARBYCHARGER                                     @"CC0007"//车况_查找附近充电站
#define CARCONDITIONS_CHARGESETTING                                           @"CC0008"//车况_充电设置
#define CARCONDITIONS_MAINTAINSUGGEST_BANNER                                  @"CC0009"//维护保养建议banner
#define SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE                           @"CC0010"//智享车_车况_长图分享
#define VEHICLE_CAR_CONDITION_VEHICLE_SETTING                                 @"CC0020"//车辆_车况_车辆设置
#define VehicleDia_Refresh_Loadtime                                           @"CC0025"//车辆_车况_刷新加载时长（开始时间/结束时间/加载结果）

#define VEHICLE_CAR_CONDITION_VEHICLE_SETTING_CHARGESETTING                   @"CC0021"//车辆_车况_车辆设置_充电设置
#define VEHICLE_CAR_CONDITION_VEHICLE_SETTING_WIFISETTING                     @"CC0022"//车辆_车况_车辆设置_车载Wifi设置
#define VEHICLE_CAR_CONDITION_VEHICLE_SETTING_VEHICLECONTROLHISTORY           @"CC0024"//车辆_车况_车辆设置_车辆操作历史

//智能后视镜
#define Rearview_manual                                                       @"SH0071"     //智能后视镜_使用说明书
#define Rearview_userinformationchange                                        @"SH0072"     //智能后视镜_修改信息
#define Rearview_userinformationchange_save                                   @"SH0073"     //智能后视镜_修改信息_保存
#define Rearview_userinformationchange_cancel                                 @"SH0074"     //智能后视镜_修改信息_取消
#define Rearview_device                                                       @"SH0075"     //智能后视镜_单个后视镜卡片
#define Rearview_device_locationshare                                         @"SH0076"     //智能后视镜_单个后视镜卡片_位置分享
#define Rearview_device_locationshare_towechatfriend                          @"SH0077"     //智能后视镜_单个后视镜卡片_位置分享_微信好友
#define Rearview_device_locationshare_towechatmoments                         @"SH0078"     //智能后视镜_单个后视镜卡片_位置分享_朋友圈
#define Rearview_device_locationshare_cancel                                  @"SH0079"     //智能后视镜_单个后视镜卡片_位置分享_取消
#define Rearview_devicechange                                                 @"SH0080"     //智能后视镜_单个后视镜卡片右上角修改按钮
#define Rearview_devicechange_deviceinformationchange                         @"SH0081"     //智能后视镜_单个后视镜卡片右上角修改按钮_修改信息
#define Rearview_devicechange_deviceunbundle                                  @"SH0082"     //智能后视镜_单个后视镜卡片右上角修改按钮_解绑设备
#define Rearview_devicechange_deviceinformationchange_save                    @"SH0083"     //智能后视镜_单个后视镜卡片右上角修改按钮_修改信息_保存
#define Rearview_devicechange_deviceinformationchange_cancel                  @"SH0084"     //智能后视镜_单个后视镜卡片右上角修改按钮_修改信息_返回
#define Rearview_devicechange_deviceunbundle_success                          @"SH0085"     //智能后视镜_单个后视镜卡片右上角修改按钮_解绑设备_成功返回
#define Rearview_devicechange_deviceunbundle_fail                             @"SH0086"     //智能后视镜_单个后视镜卡片右上角修改按钮_解绑设备_失败返回
#define Rearview_wechatlocationshare                                          @"SH0087"     //智能后视镜_微信位置分享
#define Rearview_wechatlocationshare_openinapp                                @"SH0088"     //智能后视镜_微信位置分享_在安吉星中打开



#endif /* SOSDaapFuncID90_h */
