//
//  SOSNavigateHeader.h
//  Onstar
//
//  Created by Coir on 13/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#ifndef SOSNavigateHeader_h
#define SOSNavigateHeader_h

/** 选点操作类型 */
typedef enum {
    /// 空值
    OperationType_Void = 0,
    /// 设置围栏中心点
    OperationType_set_Geo_Center,
    /// 设置路线起点
    OperationType_set_Route_Begin_POI,
    /// 设置路线终点
    OperationType_set_Route_Destination_POI,
    /// 设置住家地址
    OperationType_Set_Home,
    /// 设置公司地址
    OperationType_Set_Company,
    /// 设置住家地址, 然后下发
    OperationType_Set_Home_Send_POI,
    /// 设置公司地址, 然后下发
    OperationType_Set_Company_Send_POI,
    /// 设置组队出行目的地
    OperationType_Set_GroupTrip_Destination,
}   SelectPointOperation;

typedef NS_ENUM(NSUInteger, TableDataType) {
    ///搜索历史
    TableDataTypeHistory,
    ///收藏夹
    TableDataTypeCollection,
    ///搜索结果
    TableDataTypeSearchResult,
    ///搜索联想提示
    TableDataTypeAssociateTips,
};

/// 搜索联想提示 Cell 高度
static const int KAssociateCellHeight = 80;
/// 搜索历史纪录 Cell 高度
static const int KHistoryCellHeight = 80;
/// 住家/公司 Cell 高度
static const int KHomeAndCompanyCellHeight = 120;
/// 搜索结果每页显示条数
static const int KOffsetSearchResult = 20;
/// 搜索结果 Cell 高度
static const int KSearchResultCellHeight = 66;
/// 更多，清除历史纪录 Cell 高度
static const int KMoreAndClearHistoryCellHeight = 56;

#endif /* SOSNavigateHeader_h */
