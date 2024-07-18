//
//  DeelerSubCitysTableV.m
//  Onstar
//
//  Created by huyuming on 16/1/26.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "DealerSubCitysTableV.h"
#import "AppPreferences.h"
#import "Util.h"
#import "SOSSearchResult.h"

#define ITERM_CITIES                    @"cities"
#define ID_PROVINCE_LIST_TABLE_CELL		@"ID_PROVINCE_LIST_TABLE_CELL"
#define ID_CITY_LIST_TABLE_CELL         @"ID_CITY_LIST_TABLE_CELL"

@implementation DealerSubCitysTableV     {
//    NSArray *allCitys;
    DealerSubCitysTableV *subCitysTable;
    IBOutlet UILabel  *labelStatusTitle;
    IBOutlet UITableView *tableChooseProvince;
    UIImageView *actionSheetBG;
}


@synthesize delegateCity = _delegateCity;
@synthesize delegateForRoute = _delegateForRoute;
@synthesize cityInfo =_cityInfo;
@synthesize whoCallIn = _whoCallIn;




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath     {
    
    return 55.0f;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section     {
    NSLog(@"---------  %lu ----- ",(unsigned long)self.allCitys.count);
    return [self.allCitys count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath     {
    tableView.backgroundColor = [UIColor whiteColor];
    int row = (int)[indexPath row];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    static NSString *cellIdentifier = @"DealerSubCitysCell";
    UINib *nib = [UINib nibWithNibName:@"DealerSubCitysCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    DealerSubCitysCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSString *cityName = NONil(_allCitys[row][@"CityName"]);

    cell.cityNameLB.adjustsFontSizeToFitWidth = YES;
    cell.cityNameLB.text= cityName;
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DealerCityBgColor"]];
    //    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.checkMarkImgV.hidden = YES;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath     {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    DealerSubCitysCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checkMarkImgV.hidden = NO;
    
    NSInteger row = indexPath.row;

    if ([indexPath isEqual:self.selectIndex]) {
    } else {
        NSLog(@"choose City");
        [self chooseCity:self.allCitys[row]];
    }
}


- (void)chooseCity:(NSDictionary *)cityInfoDict     {
    if (!self.cityInfo) {
        self.cityInfo = [[SOSCityGeocodingInfo alloc] init];
    }
    self.cityInfo.city = cityInfoDict[@"CityName"];
    self.cityInfo.ecity = cityInfoDict[@"CityNameEng"];
    self.cityInfo.code = cityInfoDict[@"CityCode"];
    self.cityInfo.x = cityInfoDict[@"Longitude"];
    self.cityInfo.y = cityInfoDict[@"Latitude"];
    if (_delegateCity && [_delegateCity respondsToSelector:@selector(didChooseCity:)]) {
        [_delegateCity didChooseCity:self.cityInfo];
    }else if (_delegateForRoute && [_delegateForRoute respondsToSelector:@selector(chooseRoutePreviewCity:)]) {
        [_delegateForRoute chooseRoutePreviewCity:self.cityInfo];
    }
}


- (void)tableView:(UITableView *)_tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath     {
    DealerSubCitysCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    cell.checkMarkImgV.hidden = YES;
}


@end
