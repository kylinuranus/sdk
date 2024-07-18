//
//  SOSCollectViewController.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSCollectViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NNGeoFence *geoFence;
@property(nonatomic, assign) BOOL fromGeoFecing;

/// 设置 家和公司地址 类型    (若不需要,传0或不设置)
@property (nonatomic, assign) SelectPointOperation operationType;
@end
