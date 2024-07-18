//
//  SOSDaapFuncID91.h
//  Onstar
//
//  Created by TaoLiang on 2019/5/16.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#ifndef SOSDaapFuncID92_h
#define SOSDaapFuncID92_h


#define    Uf_Edriver    					                          	@"UF0011"        // 代驾
#define    Uf_Edriver_Disclaimer_Yes                              		@"UF0012"        // 代驾_免责声明_立即前往
#define    Uf_Edriver_Disclaimer_Cancel                              	@"UF0013"        // 代驾_免责声明_取消
//#define    Uf_Edriver_Getlocation_Allow                                  @"UF0014"        // 代驾_获取位置_好
//#define    Uf_Edriver_Getlocation_No                                     @"UF0015"        // 代驾_获取位置_不允许

#define    LBS_setting_geofence_emptyadd    	                        @"TL0048"        // 安星定位_设备信息_电子围栏_添加电子围栏
#define    LBS_setting_geofence_add_back                              	@"TL0049"        // 安星定位_设备信息_电子围栏_添加电子围栏_返回
#define    LBS_setting_geofence_add_remind_back                       	@"TL0054"        // 安星定位_设备信息_电子围栏_添加电子围栏_提醒_返回
#define    LBS_setting_geofence_add_remind_setting                     	@"TL0055"        // 安星定位_设备信息_电子围栏_添加电子围栏_提醒_保存
#define    LBS_setting_geofence_add_remind_exit                        	@"TL0056"        // 安星定位_设备信息_电子围栏_添加电子围栏_提醒_选中出围栏提醒
#define    LBS_setting_geofence_add_remind_enter                       	@"TL0057"        // 安星定位_设备信息_电子围栏_添加电子围栏_提醒_选中进围栏提醒
#define    LBS_setting_geofence_add_devicelocation                   	@"TL0058"        // 安星定位_设备信息_电子围栏_添加电子围栏_设备位置
#define    LBS_setting_geofence_add_mylocation                         	@"TL0059"        // 安星定位_设备信息_电子围栏_添加电子围栏_我的位置
#define    LBS_setting_geofence_add_radius                             	@"TL0062"        // 安星定位_设备信息_电子围栏_添加电子围栏_编辑半径
#define    LBS_setting_geofence_add_confirm                            	@"TL0063"        // 安星定位_设备信息_电子围栏_添加电子围栏_确认添加

#define    Trip_LBS_setting_geofence_switch_On    						@"TL0084"        // 旅途_安星定位_电子围栏_围栏开关_开
#define    Trip_LBS_setting_geofence_switch_Off    						@"TL0085"        // 旅途_安星定位_电子围栏_围栏开关_关
#define    Trip_VehicleLocation_geofence_add    						@"TR0047"        // 旅途_车辆定位_电子围栏_去添加（未设置）
#define    Trip_VehicleLocation_geofence_edit    						@"TR0048"        // 旅途_车辆定位_电子围栏_编辑(已设置）
#define    Trip_VehicleLocation_geofence_add_cancel    					@"TP0242"        // 旅途_车辆定位_电子围栏_取消（未设置）
#define    Trip_VehicleLocation_geofence_edit_rename_save    			@"TP0243"        // 旅途_车辆定位_电子围栏_编辑_更改围栏名称_保存
#define    Trip_VehicleLocation_geofence_switch_on    					@"TP0244"        // 旅途_车辆定位_电子围栏_围栏开关_开
#define    Trip_VehicleLocation_geofence_switch_off    					@"TP0245"        // 旅途_车辆定位_电子围栏_围栏开关_关
#define    Trip_VehicleLocation_geofence_center_radius    				@"TP0246"        // 旅途_车辆定位_电子围栏_围栏中心和半径
#define    Trip_VehicleLocation_geofence_center_radius_click    		@"TP0247"        // 旅途_车辆定位_电子围栏_围栏中心和半径_中心点击
#define    Trip_VehicleLocation_geofence_center_radius_slide    		@"TP0248"        // 旅途_车辆定位_电子围栏_围栏中心和半径_半径滑动
#define    Trip_VehicleLocation_geofence_remind    						@"TP0249"        // 旅途_车辆定位_电子围栏_提醒
#define    Trip_VehicleLocation_geofence_remind_back    				@"TP0250"        // 旅途_车辆定位_电子围栏__提醒_返回
#define    Trip_VehicleLocation_geofence_remind_save    				@"TP0251"        // 旅途_车辆定位_电子围栏__提醒_保存

#define    CarConditions_back    										@"CC0001"        // 车况_返回
#define    CarConditions_OVD    										@"CC0002"        // 车况_检测报告
#define    OVD_back    													@"CC0003"        // 检测报告_返回
#define    CarConditions_maintainsuggest    							@"CC0004"        // 车况_查看维修保养建议
#define    CarConditions_maintainsuggest_back    						@"CC0005"        // 车况_保养建议_返回
#define    CarConditions_maintainsuggest_contactdealer    				@"CC0006"        // 车况_保养建议_联系经销商
#define    CarConditions_searchnearbycharger    						@"CC0007"        // 车况_查找附近充电桩
#define    CarConditions_chargesetting   				 				@"CC0008"        // 车况_充电设置

#define    CarConditions_maintainsuggest_banner    						@"CC0009"        // 维护保养建议banner
#define    SmartVehicle_Car condition_long graph share    				@"CC0010"        // 智享车_车况_长图分享
#define    Vehicle_Car condition_Vehicle Setting    					@"CC0020"        // 车辆_车况_车辆设置

#define    My_Training    												@"MY0144"        // 我的-车联课堂
#define    Quickly_Training    											@"HB0051"        // 快捷键_车联课堂


#endif /* SOSDaapFuncID92_h */
