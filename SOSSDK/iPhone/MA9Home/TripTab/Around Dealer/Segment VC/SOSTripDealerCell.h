//
//  SOSTripDealerCell.h
//  Onstar
//
//  Created by Coir on 2019/5/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Cell 类型
typedef enum {
    /// 加油站
    SOSTripCellType_AMap_Oil_Station = 1,
    /// 加油站
    SOSTripCellType_SOS_Oil_Station,
    /// 经销商
    SOSTripCellType_Dealer,
    /// 经销商 ( 所有品牌--需显示品牌角标 )
    SOSTripCellType_Dealer_ALl,
}	SOSTripCellType;

@interface SOSTripDealerCell : UITableViewCell

@property (assign, nonatomic) SOSTripCellType cellType;

/// 供 附近经销商页面 使用
@property (nonatomic, strong) NNDealers *dealer;

/// 高德加油站, 供 附近加油站页面 使用
@property (nonatomic, strong) SOSPOI *poi;
/// 优惠加油 , 第三方油站 , 供 附近加油站页面 使用
@property (nonatomic, strong) SOSOilStation *oilStation;

@end

NS_ASSUME_NONNULL_END
