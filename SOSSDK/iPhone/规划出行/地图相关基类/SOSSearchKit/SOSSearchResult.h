//
//  SOSSearchResult.h
//  Onstar
//
//  Created by Onstar on 13-6-22.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//
#import "AppPreferences.h"
#import "SOSMapHeader.h"
#import "BaseAnnotation.h"
#import "SOSPoiHistoryDataBase.h"

typedef enum	{
	SOSPOICollectionState_Non = 0,
    SOSPOICollectionState_Not_Collected,
    SOSPOICollectionState_Collected
}	SOSPOICollectionState;

@class BaseAnnotationView;

/// POI 信息类，继承自NSObject类。用于存储 POI 的相关信息，例如，地址、名称、类型等。
@interface SOSPOI : NSObject<NSCopying>

/// POI 点 ID, 用于收藏等信息
@property (nonatomic, copy) NSString *pguid;

/// POI 点收藏状态
@property (nonatomic, assign) SOSPOICollectionState collectionState;

/// POI点地址
@property (nonatomic, copy) NSString *address;
///// 首选POI List第一个点地址
//@property (nonatomic, copy) NSString *firstShowAddress;

/// POI点名称
@property (nonatomic, copy) NSString *name;

/// POI点别名
@property (nonatomic, copy) NSString *nickName;

/// POI点类型
@property (nonatomic, copy) NSString *type;

/// POI点相关URL地址
@property (nonatomic, copy) NSString *url;

/// POI点电话号码
@property (nonatomic, copy) NSString *tel;

/// 经度坐标,longitude
@property (nonatomic, copy) NSString *x;

/// 经度坐标,x
@property (nonatomic, copy) NSString *longitude;

/// 纬度坐标, latitude
@property (nonatomic, copy) NSString *y;

/// 纬度坐标, y
@property (nonatomic, copy) NSString *latitude;

/// 周边搜索时,距离中心点距离
@property (nonatomic, copy) NSString *distance;

/// 驾车距离
@property (nonatomic, copy) NSString *driverDistance;

/// 匹配度
@property(nonatomic, copy) NSString* match;

/// 区域代码
@property (nonatomic, copy) NSString *code;

/// 省份
@property(nonatomic, copy) NSString* province;

/// 城市
@property(nonatomic, copy) NSString* city;

@property (nonatomic,  copy) NSString *cityCode;

@property (nonatomic,  copy) NSString *cityNameEng;

/// 我的位置 MyLocation 车辆位置 VehicleLocation
@property (nonatomic, copy) NSString* locationName;

/// POI点名称 + 附近
@property (nonatomic, copy) NSString* locationAddress;

/// POI类型
@property (nonatomic, assign) POIType sosPoiType;

/// POI 收藏 ID
@property (nonatomic, copy) NSString *destinationID;







/// 足迹主键ID,用于我的足迹交互
@property (nonatomic, strong) NSNumber *ftID;

/// 城市内足迹统计总数,用于我的足迹交互
@property (nonatomic, copy) NSNumber *cityCount;

/// 用于和地图交互
@property (nonatomic, strong) BaseAnnotation *annotion;

/// 用于和地图交互
@property (nonatomic, strong) BaseAnnotationView *annotionView;

/// 地图标记图片名,用于和地图交互
@property (nonatomic, copy) NSString *annotationImgName;

/// 地图标记图片,用于和地图交互
@property (nonatomic, strong) UIImage *annotationImg;

/// 车辆位置获取时间,用于地图交互
@property (nonatomic, copy) NSString *operationTime;

/// 是否应该在足迹地图中显示大图边(仅适用于概览模式的足迹POI点)
@property (nonatomic, assign) BOOL shouldShowBigAnnotation;

/// POI 的获得时间
@property (nonatomic, copy) NSString *operationDateStrValue;

/// POI 得获取时间 (刚刚/xx分钟前/xx小时前/xx天前) 需要先设置 operationDateStrValue
@property (nonatomic, copy, readonly) NSString *gapTime;

/// POI 是否有效 (目前仅用于判断 Car Location 是否有效) 需要先设置 operationDateStrValue
@property (nonatomic, assign, readonly) BOOL isValidLocation;

/// POI 关键字,用于展示地图搜索列表页
@property (nonatomic, copy) NSString *keyWords;

/// SOSPoiHistory
@property (assign, nonatomic) HistoryPoiType historyPoiType;

- (BOOL)isEqualToPOI:(SOSPOI *)poi;

- (CLLocationCoordinate2D)getPOICoordinate2D;

- (NSString *)formatDistance;

- (NSString *)distanceWithUnit;

- (NSString *)distanceUnit;


@end





///LBS 信息类，继承自SOSPOI类。用于存储 LBS 的相关信息
@interface SOSLBSPOI : SOSPOI

/// LBS 设备编号
@property (nonatomic, copy) NSString *LBSIMEI;

/// LBS 设备名称
@property (nonatomic, copy) NSString *LBSDeviceName;

/// LBS 刷新时间 (设备位置更新时间)
@property (nonatomic, copy) NSString *LBSUpdateTime;

/// LBS 电量状态
@property (nonatomic, copy) NSString *LBSPowerState;

/// LBS 是否在线 (0 不在线   1 在线)
@property (nonatomic, copy) NSString *LBSIsOnline;
/// LBS 状态 (0:未启用,1:运动,2:静止,3:离线)
@property (nonatomic, copy) NSString *LBSState;

/// LBS 当前位置停留时间
@property (nonatomic, copy) NSString *LBSStayTime;


/// LBS POI 刷新时间  (地图页面内,用于计算停留时间)
@property (nonatomic, strong) NSDate *LBSMapUpdateTime;

@end




@interface FootPrintPOI : NSObject

///主键
@property (nonatomic,strong) NSNumber *seqId;

///对应车辆 VIN
@property (nonatomic,strong) NSString *vin;

///国家
@property (nonatomic,strong) NSString *destCountry;

///省份
@property (nonatomic,strong) NSString *destState;

///城市
@property (nonatomic,strong) NSString *destCity;

///纬度,x
@property (nonatomic,strong) NSNumber *lastDestLatitude;

///纬度,x
@property (nonatomic,strong) NSNumber *destLatitude;

///经度,y
@property (nonatomic,strong) NSNumber *lastDestLongitude;

///经度,y
@property (nonatomic,strong) NSNumber *destLongitude;

///街道名
@property (nonatomic,strong) NSString *destStreetName;

///街道门牌号
@property (nonatomic,strong) NSString *destStreetNum;

///省内统计总数
@property (nonatomic,strong) NSNumber *stateCount;

///城市内统计总数
@property (nonatomic,strong) NSNumber *cityCount;

///统计总数
@property (nonatomic,strong) NSNumber *totalCount;

///总排名百分比
@property (nonatomic,strong) NSNumber *totalRank;

///城市排名百分比
@property (nonatomic,strong) NSNumber *cityRank;

///
@property (nonatomic,strong) NSString *lastFlag;

///时间
@property (nonatomic,strong) NSString *processingStartTime;

///
@property (nonatomic,strong) NSString *statusCode;

///城市数目
@property (nonatomic,strong) NSNumber *cityCountNum;

///是否应该在足迹地图中显示大图边(仅适用于概览模式的足迹点)
@property (nonatomic, assign) BOOL shouldShowBigAnnotation;

- (SOSPOI *)toPOIPoint;

@end

///POI 查询结果类，继承自NSObject类。用于存储 POI 的查询结果，例如，查询到的 POI 记录数等。 
@interface SOSPoiSearchResult : NSObject

///允许返回记录数与用户权限有关系 
@property(nonatomic,assign) NSInteger count;

///当前返回记录数 
@property(nonatomic,assign) NSInteger record;

///总记录数 
@property(nonatomic,assign) NSInteger total;

///返回的POI对象的序列 
@property(nonatomic,strong) NSArray*  pois;

@end



///网络导航信息类，继承自NSObject类。 
@interface SOSRoute : NSObject

///道路名称 
@property (nonatomic, copy) NSString *roadName;

///方向 
@property (nonatomic, copy) NSString *direction;

///行驶距离 
@property (nonatomic, copy) NSString *roadLength;

///辅助动作 
@property (nonatomic, copy) NSString *action;

///动作 
@property (nonatomic, copy) NSString *accessorialInfo;

///行驶时间 
@property (nonatomic, copy) NSString *driveTime;

///道路等级 
@property (nonatomic, copy) NSString *grade;

///道路描述 
@property (nonatomic, copy) NSString *form;

///行驶路段坐标 格式(x1,y1) 
@property (nonatomic, copy) NSString *coor;

///本段道路行驶描述 
@property (nonatomic, copy) NSString *textInfo;

@end

///步行/骑行/驾车方案 路径规划结果
@interface SOSMapPath : NSObject
///起点和终点的距离
@property (nonatomic, assign) NSInteger  distance;
///预计耗时（单位：秒）
@property (nonatomic, assign) NSInteger  duration;
///导航策略
@property (nonatomic, copy)   NSString  *strategy;
///导航路段 SOSRoute 数组
@property (nonatomic, strong) NSArray<SOSRoute *> *steps;
///此方案费用（单位：元）
@property (nonatomic, assign) CGFloat    tolls;
///此方案收费路段长度（单位：米）
@property (nonatomic, assign) NSInteger  tollDistance;
///此方案交通信号灯个数
@property (nonatomic, assign) NSInteger  totalTrafficLights;

@end

///途经城市信息类，继承自NSObject类。用于描述途经城市的信息。 
@interface SOSRouteCity : NSObject

///城市名 
@property (nonatomic, copy) NSString *cityName;

///城市英文名 
@property (nonatomic, copy) NSString *cityEnglishName;

///地区代码 
@property (nonatomic, copy) NSString *code;

///电话区号 
@property (nonatomic, copy) NSString *telnum;

@end

///网络导航查询结果类，继承自NSObject类。用于存储网络导航查询的结果信息。 
@interface SOSRouteSearchResult : NSObject

///导航段数 
@property(nonatomic,assign) NSInteger count;

///外包矩形范围 
@property (nonatomic, copy) NSString *bounds;

///搜索时间 
@property (nonatomic, copy) NSString *searchtime;

///行驶路段坐标串 格式(x1,y1,x2,y2,x3,y3....) 
@property (nonatomic, copy) NSString *coors;

///MARoute对象数组，存储返回的路段信息 
@property(nonatomic,strong) NSArray*  routes;

///导航距离 
@property (nonatomic, copy) NSString *length;

///途经城市 SOSRouteCity对象数组 
@property(nonatomic,strong) NSArray* viaCities;

@end

///距离查询结果类，继承自NSObject类。用于存储距离查询的结果信息。 
@interface SOSDistanceSearchResult : NSObject

///距离 
@property (nonatomic, copy) NSString *distance;

@end


///偏移查询结果类，继承自NSObject类。 
@interface SOSRGCItem : NSObject

///偏移后的经度坐标 
@property (nonatomic, copy) NSString *x;

///偏移后的纬度坐标 
@property (nonatomic, copy) NSString *y;

@end

///偏移查询结果数组类，继承自NSObject类。 

@interface SOSRGCSearchResult : NSObject

///返回的MARGCItem对象的序列 
@property(nonatomic,strong) NSArray* rgcItemArray;

@end

///地理兴趣点信息类，继承自NSObject类。 
@interface SOSGeoPOI : NSObject

///名称 
@property (nonatomic, copy) NSString *name;

///等级 
@property (nonatomic, copy) NSString *level;

///经度坐标 
@property (nonatomic, copy) NSString *x;

///纬度坐标 
@property (nonatomic, copy) NSString *y;

///地址 
@property (nonatomic, copy) NSString *address;

///省份 
@property (nonatomic, copy) NSString *province;

///城市 
@property (nonatomic, copy) NSString *city;

///区域 
@property (nonatomic, copy) NSString *district;

///范围 
@property (nonatomic, copy) NSString *range;

///英文名称 
@property (nonatomic, copy) NSString *ename;

///英文省份 
@property (nonatomic, copy) NSString *eprovince;

///英文城市 
@property (nonatomic, copy) NSString *ecity;

///英文区域 
@property (nonatomic, copy) NSString *edistrict;

///英文地址 
@property (nonatomic, copy) NSString *eaddress;

@end

///地理编码查询结果类，继承自NSObject类。 
@interface SOSGeoCodingSearchResult : NSObject

///返回的记录条数 
@property(nonatomic,assign) NSInteger count;

///返回的地理兴趣点(MAGeoPOI对象)队列 
@property(nonatomic,strong) NSArray* geoCodingArray;

@end

///省信息类，继承自NSObject类。 
@interface SOSProvince : NSObject

///省份名称 
@property (nonatomic, copy) NSString *name;

///省份编码 
@property (nonatomic, copy) NSString *code;

@end

///城市信息类，继承自NSObject类。 
@interface SOSCity : NSObject

///城市名称 
@property (nonatomic, copy) NSString *name;

///城市编码 
@property (nonatomic, copy) NSString *code;

///电话区号 
@property (nonatomic, copy) NSString *tel;

@end

///区域信息类，继承自NSObject类。 
@interface SOSDistrict : NSObject

///区域名称 
@property (nonatomic, copy) NSString *name;

///区域编码 
@property (nonatomic, copy) NSString *code;

///区域中心点经度 
@property (nonatomic, copy) NSString *x;

///区域中心点纬度 
@property (nonatomic, copy) NSString *y;

///区域矩形范围 
@property (nonatomic, copy) NSString *bounds;

@end

///道路信息类，继承自NSObject类。 
@interface SOSRoad : NSObject

///道路id 
@property (nonatomic, copy) NSString *Id;

///道路名称 
@property (nonatomic, copy) NSString *name;

///道路英文名称 
@property (nonatomic, copy) NSString *ename;

///道路宽度 
@property (nonatomic, copy) NSString *width;

///道路等级 
@property (nonatomic, copy) NSString *level;

///道路方向 
@property (nonatomic, copy) NSString *direction;

///距离参数点距离 
@property (nonatomic, copy) NSString *distance;

@end

///道路交叉口信息类，继承自NSObject类。 
@interface SOSCross : NSObject

///交叉口名称 
@property (nonatomic, copy) NSString *name;

///交叉口经度 
@property (nonatomic, copy) NSString *x;

///交叉口纬度 
@property (nonatomic, copy) NSString *y;

@end

///城市信息类
@interface SOSCityGeocodingInfo : NSObject

///城市名称 
@property (nonatomic, copy) NSString *city;

///城市编码 
@property (nonatomic, copy) NSString *code;

///电话区号 
@property (nonatomic, copy) NSString *tel;

///等级 (政府等级?) 
@property (nonatomic, copy) NSString *level;

///政府 经度坐标 
@property (nonatomic, copy) NSString *x;

///政府 纬度坐标 
@property (nonatomic, copy) NSString *y;

///政府 地址 
@property (nonatomic, copy) NSString *address;

///省份 
@property (nonatomic, copy) NSString *province;


///政府 英文名称? 
@property (nonatomic, copy) NSString *ename;

///英文省份 
@property (nonatomic, copy) NSString *eprovince;

///英文城市 
@property (nonatomic, copy) NSString *ecity;

///政府 英文地址? 
@property (nonatomic, copy) NSString *eaddress;

@end

