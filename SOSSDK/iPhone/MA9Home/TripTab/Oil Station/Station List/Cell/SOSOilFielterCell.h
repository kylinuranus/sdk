//
//  SOSOilFielterCell.h
//  Onstar
//
//  Created by Coir on 2019/8/30.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSDealerTool.h"

NS_ASSUME_NONNULL_BEGIN

/// Cell 类型
typedef enum {
    /// 加油站
    SOSFielterCellType_Oil_Station = 1,
    /// 经销商品牌
    SOSFielterCellType_Dealer_Brand,
}	SOSFielterCellType;

@interface SOSOilFielterCell : UITableViewCell

/// Cell 类型
@property (assign, nonatomic) SOSFielterCellType cellType;

/// 经销商品牌
@property (assign, nonatomic) SOSDealerBrandType brandType;

@property (copy, nonatomic) NSString *titleStr;

@property (assign, nonatomic) BOOL selectedState;

+ (NSString *)getBrandImageNameWithBrandType:(SOSDealerBrandType)brandType;

+ (NSString *)getBrandNameWithBrandType:(SOSDealerBrandType)brandType;

@end

NS_ASSUME_NONNULL_END
