//
//  DeelerSubCitysTableV.h
//  Onstar
//
//  Created by huyuming on 16/1/26.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DealerCityCell.h"
#import "DealerSubCitysCell.h"

@class SOSCityGeocodingInfo;
@protocol ViewControllerChooseCityDelegate <NSObject>
@optional
- (void)didChooseCity:(SOSCityGeocodingInfo *)cityInfo;
@end

@protocol ViewControllerChooseCityRouteDelegate <NSObject>
@optional
- (void)chooseRoutePreviewCity:(SOSCityGeocodingInfo *)cityInfo;
@end

@interface DealerSubCitysTableV : UITableView<UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong) NSArray *allCitys;
@property (nonatomic,strong) NSString *whoCallIn;
@property (nonatomic, weak) id<ViewControllerChooseCityDelegate> delegateCity;
@property (nonatomic, weak) id<ViewControllerChooseCityRouteDelegate> delegateForRoute;
@property (nonatomic, strong) SOSCityGeocodingInfo *cityInfo;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil whoCallIn:(NSString *)who;
@property (assign)BOOL isOpen;
@property (nonatomic,strong)NSIndexPath *selectIndex;


//- (void)loadCitysFrom;
@end
