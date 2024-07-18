//
//  SelectProvinceViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/9/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^provinceSelectBlock)(SOSClientAcronymTransverter *selectProvince);
//选择省份／城市界面
@interface SelectProvinceViewController : SOSBaseViewController
@property(nonatomic,copy)provinceSelectBlock selectBlock;
@property(nonatomic,copy)NSString * selectPro;   //传入要查询省份的编码
@property(nonatomic,copy)NSString * proTitle;   //省份
@property(nonatomic,strong)NSArray *  proList;  //传入省份集合
@end
