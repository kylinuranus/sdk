//
//  DealerCityTableV.h
//  Onstar
//
//  Created by huyuming on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DealerCityCell.h"
#import "DealerSubCitysTableV.h"


@interface DealerCityTableV : UITableView<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id <ViewControllerChooseCityDelegate> delegateCity;
@property (nonatomic, weak) id <ViewControllerChooseCityRouteDelegate> delegateForRoute;
@property (nonatomic, strong) SOSCityGeocodingInfo *cityInfo;
@property (assign) BOOL isOpen;
@property (nonatomic, strong)NSIndexPath *selectIndex;
- (void)initData;

@end
