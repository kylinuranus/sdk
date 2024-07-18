//
//  SOSDaapFuncID83.h
//  Onstar
//
//  Created by WQ on 2018/7/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#ifndef SOSDaapFuncID83_h
#define SOSDaapFuncID83_h
//MA8.3新增FunctionID全量表
#define TCPS_protocol_update_prompt_agree                                     @"TCPS0001"//TCPS协议更新提示_同意
#define TCPS_protocol_update_prompt_reject                                    @"TCPS0002"//TCPS协议更新提示_不同意
#define SPLASH_AD                                                             @"HP0008"//APP闪屏广告
#define SPLASH_AD_SKIP                                                        @"HP0010"//APP闪屏广告手动关闭
#define Splash_AD_Skip_AUTO                                                   @"HP0012"//APP闪屏广告自动关闭
#define Splash_AD_Pic_Loadtime                                                @"HP0015"//APP闪屏广告自动关闭

#define JOYLIFEAD_CLOUD_MUSIC                                                 @"JL0084"//随星听
#define GOOD_RECOMMENDATION_MORE                                              @"JL0085"//精彩推荐_更多
#define GOOD_RECOMMENDATION_PIC                                               @"JL0086"//精彩推荐入口图片
#define CLOUD_MUSIC_RECONNECTION                                              @"CM0018"//随星听_长连接手动重连
#define UBI_INSURANCE_RICKSCORE                                               @"UB0001"//车联保险_跳转到驾驶行为报告页面的超链接
#define UBI_INSURANCE_PACKAGE_DETAILS                                         @"UB0002"//车联保险_套餐详情
#define UBI_INSURANCE_ACTIVITY_RULE                                           @"UB0003"//车联保险_活动规则
#define UBI_INSURANCE_ACTIVITY_TEXT                                           @"UB0004"//车联保险_活动协议
#define UBI_INSURANCE_CHECK                                                   @"UB0005"//车联保险_勾选框
#define UBI_INSURANCE_ATTEND                                                  @"UB0006"//车联保险_朕要参加
#define UBI_INSURANCE_ALLOW                                                   @"UB0007"//车联保险_勾选框
#define UBI_INSURANCE_ACTIVITYTEXT_ATTEND                                     @"UB0008"//车联保险_活动协议_朕要参加
#define UBI_INSURANCE_ACTIVITYTEXT_CHECK                                      @"UB0009"//车联保险_活动协议_勾选框
#define UBI_INSURANCE_DISCLAIMER_KNOW                                         @"UB0010"//车联保险_免责声明_知道了
#define UBI_INSURANCE_DISCLAIMER_NOT REMIND                                   @"UB0011"//车联保险_免责声明_下次不再提醒

#define My_massage_banner                                                     @"MY0103"//消息中心_banner
#define My_massage_activity                                                   @"MY0104"//消息中心_活动
#define My_massage_notificition                                               @"MY0105"//消息中心_通知
#define My_massage_activity_delete                                            @"MY0106"//消息中心_删除活动
#define My_massage_notificition_delete                                        @"MY0107"//消息中心_删除通知
#define My_massage_activity_back                                              @"MY0108"//消息中心_活动返回
#define My_massage_notificition_back                                          @"MY0109"//消息中心_通知返回
#define My_massage_activity_showallmessage                                    @"MY0110"//消息中心_活动新消息
#define My_massage_notificition_showallmessage                                @"MY0111"//消息中心_通知新消息
#define My_massage_detail                                                     @"MY0112"//消息中心_查看详情
#define My_massage_push                                                       @"MY0113"//消息中心_消息推送

#define MAP_CARLOCATION_LASTMILNAVIGATION_NAVIGATION                          @"TR0075"//地图页_车辆位置_步行规划_导航
#define MAP_POIDETAIL_NAVIGATION                                              @"TR0076"//地图页_POI详情_导航
#define UBI_INSURANCE_ARROW                                                   @"SD0040"//UBI_保险_箭头
#define UBI_INSURANCE_BANNER                                                  @"SD0041"//UBI_保险_banner
#define SMARTDRIVER_HISTORY_MONTH_NOUBI                                       @"SD0042"//驾驶行为评价_统计历史_月度_好好开车，赚双重福利
#define SMARTDRIVER_HISTORY_MONTH_UBI                                         @"SD0043"//驾驶行为评价_统计历史_月度_查看安全驾驶收益
#define SMARTDRIVER_RECENT_TRIP                                               @"SD0044"//驾驶行为评价_近期行程
#define RECENT_TRAVEL_NO_TRAVEL_PROMPT_CONFIRMATION                           @"RT0001"//近期行程_无行程提示确认
#define RECENT_TRAVEL_RETURN                                                  @"RT0002"//近期行程_返回
#define RECENT_TRAVEL_SEARCH_ENTRANCE                                         @"RT0003"//近期行程_搜索入口
#define RECENT_TRAVEL_SEARCH_ENTRANCE_CANCEL                                  @"RT0004"//近期行程_搜索入口_取消
#define RECENT_TRAVEL_SEARCH_ENTRANCE_DELETE_INPUT                            @"RT0005"//近期行程_搜索入口_搜索框输入删除
#define RECENT_TRAVEL_SEARCH_ENTRANCE_SEARCH                                  @"RT0006"//近期行程_搜索入口_搜索
#define RECENT_TRAVEL_SEARCH_ENTRANCE_DELETE_SEARCH_HISTORY                   @"RT0007"//近期行程_搜索入口_搜索记录删除
#define RECENT_TRAVEL_SEARCH_ENTRANCE_CLEAR_HISTORY                           @"RT0008"//近期行程_搜索入口_清除历史
#define RECENT_TRAVEL_SELECT_DATE                                             @"RT0009"//近期行程_选择日期
#define RECENT_TRAVEL_SELECT_DATE_CLEAR                                       @"RT0010"//近期行程_选择日期_清空
#define RECENT_TRAVEL_SELECT_DATE_RETURN                                      @"RT0011"//近期行程_选择日期_返回
#define RECENT_TRAVEL_SELECT_DATE_QUERY                                       @"RT0012"//近期行程_选择日期_查询
#define RECENT_TRAVEL_SELECT_DATE_QUERY_CHANGE_DATE                           @"RT0013"//近期行程_选择日期_查询_更改日期
#define RECENT_TRAVEL_SELECT_DATE_QUERY_CLOSE                                 @"RT0014"//近期行程_选择日期_查询_关闭
#define RECENT_TRAVEL_EDIT                                                    @"RT0015"//近期行程_编辑
#define RECENT_TRAVEL_EDIT_SELECT_ALL                                         @"RT0016"//近期行程_编辑_全选
#define RECENT_TRAVEL_EDIT_SELECT_NONE                                        @"RT0017"//近期行程_编辑_全不选
#define RECENT_TRAVEL_EDIT_CANCEL                                             @"RT0018"//近期行程_编辑_取消
#define RECENT_TRAVEL_EDIT_DELECT                                             @"RT0019"//近期行程_编辑_删除
#define RECENT_TRAVEL_EDIT_DELECT_CONFIRMATION                                @"RT0020"//近期行程_编辑_删除_确定
#define RECENT_TRAVEL_EDIT_DELECT_CANCEL                                      @"RT0021"//近期行程_编辑_删除_取消
#define RECENT_TRAVEL_TRAVEL_RECORDS_EXPANSION                                @"RT0022"//近期行程_行程记录展开
#define RECENT_TRAVEL_TRAVEL_RECORDS_PACKUP                                   @"RT0023"//近期行程_行程记录收起
#define RECENT_TRAVEL_TRAVEL_RECORDS_DELECT                                   @"RT0024"//近期行程_行程记录删除
#define RECENT_TRAVEL_TRAVEL_RECORDS_DELECT_CONFIRMATION                      @"RT0025"//近期行程_行程记录删除_确定
#define RECENT_TRAVEL_TRAVEL_RECORDS_DELECT_CANCEL                            @"RT0026"//近期行程_行程记录删除_取消
#define RECENT_TRAVEL_TRAVEL_RECORDS_SHARE                                    @"RT0027"//近期行程_行程记录分享
#define RECENT_TRAVEL_TRAVEL_RECORDS_SHARE_WECHAT_FRIENDS                     @"RT0028"//近期行程_行程记录分享_微信好友
#define RECENT_TRAVEL_TRAVEL_RECORDS_SHARE_WECHAT_MOMENTS                     @"RT0029"//近期行程_行程记录分享_微信朋友圈
#define RECENT_TRAVEL_TRAVEL_RECORDS_SHARE_CANCEL                             @"RT0030"//近期行程_行程记录分享_取消
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL8                                @"MO0024"//点击小O成功跳转至小O页面
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL9                                @"MO0025"//跳转至小O页面成功

#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL11                               @"MO0026"//按地点搜索
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL12                               @"MO0027"//按时间搜索
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL13                               @"MO0028"//车辆熄火
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL14                               @"MO0029"//闪灯鸣笛
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL15                               @"MO0030"//闪灯
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL16                               @"MO0031"//鸣笛
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL17                               @"MO0032"//关车门
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL18                               @"MO0033"//车辆启动
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL19                               @"MO0034"//车门解锁
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL20                               @"MO0035"//车辆位置
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL21                               @"MO0036"//订餐服务
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL22                               @"MO0037"//车况查询
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL23                               @"MO0038"//胎压查询
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL24                               @"MO0039"//油量查询
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL25                               @"MO0040"//机油寿命查询
#define MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL26                               @"MO0041"//里程数查询





#endif /* SOSDaapFuncID83_h */
