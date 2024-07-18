//
//  DealerCityTableV.m
//  Onstar
//
//  Created by huyuming on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "DealerCityTableV.h"
#import "SOSSearchResult.h"
#import "UITableView+Category.h"

#define ITERM_CITIES                    @"cities"
#define ID_PROVINCE_LIST_TABLE_CELL		@"ID_PROVINCE_LIST_TABLE_CELL"
#define ID_CITY_LIST_TABLE_CELL         @"ID_CITY_LIST_TABLE_CELL"

@interface DealerCityTableV() <ViewControllerChooseCityDelegate>
@end

@implementation DealerCityTableV     {
    NSArray *allCitys;
    DealerSubCitysTableV *subCitysTable;
}


- (void)initData {
    self.delegate = self;
    self.dataSource = self;
    self.rowHeight = 55.f;
    allCitys = [[Util cityInfoArray] mutableCopy];
    self.estimatedSectionHeaderHeight = 0;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self registerNib:[DealerCityCell class]];
    [self tableView:self didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

}

- (void)didChooseCity:(SOSCityGeocodingInfo *)cityInfo {
    if (_delegateCity) {
        [_delegateCity didChooseCity:cityInfo];
    }
}

//- (void)chooseCity:(NSDictionary *)cityInfoDict     {
//    if (!self.cityInfo) {
//        self.cityInfo = [[SOSCityGeocodingInfo alloc] init];
//    }
//    self.cityInfo.city = cityInfoDict[@"CityName"];
//    self.cityInfo.ecity = cityInfoDict[@"CityNameEng"];
//    self.cityInfo.code = cityInfoDict[@"CityCode"];
//    self.cityInfo.x = cityInfoDict[@"Longitude"];
//    self.cityInfo.y = cityInfoDict[@"Latitude"];
//    NSLog(@"=== === cityInfo.code === === %@", self.cityInfo.code);
//    // 只可能有一种情况选择城市
//    if (_delegateCity && [_delegateCity respondsToSelector:@selector(didChooseCity:)]) {
//        [[NSUserDefaults standardUserDefaults] setObject:self.cityInfo.city forKey:K_CITY_NAME];
//        [[NSUserDefaults standardUserDefaults] setObject:self.cityInfo.code forKey:K_CITY_CODE];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [_delegateCity didChooseCity:self.cityInfo];
//    }else if (_delegateForRoute && [_delegateForRoute respondsToSelector:@selector(chooseRoutePreviewCity:)]) {
//        [_delegateForRoute chooseRoutePreviewCity:self.cityInfo];
//    }
//    // 返回相应页面
//}

#pragma mark -

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath     {
//    cell.backgroundColor = [UIColor clearColor];
//}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section     {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section     {
    return [allCitys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath     {
    DealerCityCell *cell = [tableView dequeueReusableCellWithIdentifier:SOS_GetClassString(DealerCityCell)];
    cell.provinceName.text = allCitys[indexPath.row][@"ProvinceName"];
    cell.standLineImgV.hidden = YES;
    cell.contentView.backgroundColor = colorFromRGB(242.0, 242.0, 248.0, 0.6);
    return cell;
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     {
    [_tableView reloadData];
    DealerCityCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.standLineImgV.hidden = NO;
    if (!subCitysTable) {
        subCitysTable = [[DealerSubCitysTableV alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.41-1, self.top, SCREEN_WIDTH*0.59, self.height)];
        subCitysTable.allCitys = allCitys[indexPath.row][@"cities"];
        subCitysTable.dataSource = subCitysTable;
        subCitysTable.delegate = subCitysTable;
        
        subCitysTable.delegateCity = self;
        [self.superview addSubview:subCitysTable];
    }else{
        subCitysTable.allCitys = allCitys[indexPath.row][@"cities"];
        NSLog(@"\n\n\n\n------ 要刷新的城市 %@\n\n ",subCitysTable.allCitys);
        [subCitysTable reloadData];
    }
}


//- (void)tableView:(UITableView *)_tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
//{
//    DealerCityCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
//    cell.contentView.backgroundColor = colorFromRGB(242.0, 242.0,248.0, 0.6);
//    cell.standLineImgV.hidden = YES;
//}

@end
