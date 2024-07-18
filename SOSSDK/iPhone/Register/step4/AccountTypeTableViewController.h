//
//  AccountTypeTableViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/8/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger ,SourceType)
{
    SourceTypeGender,      //性别类型数据源
    SourceTypeVehicleType  //账户类型数据源
};
typedef void(^typeSelectBlock)(SOSClientAcronymTransverter *selectValue);

@interface AccountTypeTableViewController : UITableViewController
@property(nonatomic,assign)SourceType type;
@property(nonatomic,copy)typeSelectBlock selectBlock;
- (instancetype)initWithSource:(SOSClientAcronymTransverterCollection *)sourceArr dataSourceType:(SourceType)dataType;
@end
