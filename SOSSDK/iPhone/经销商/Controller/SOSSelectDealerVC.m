//
//  SelectDealerVC.m
//  Onstar
//
//  Created by huyuming on 16/1/22.
//  Refactor by Liang Tao on 18/1/24.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//  选择经销商

#import "SOSSelectDealerVC.h"
#import "FunctionCellForDealer.h"
#import "AroundDealerMode.h"
#import "SOSSearchResult.h"
#import "LoadingView.h"
#import "CustomerInfo.h"
#import "RequestDataObject.h"
#import "ResponseDataObject.h"
#import "SOSUserLocation.h"
#import "DealersUtil.h"
#import "RegisterUtil.h"
#import "BaseSearchOBJ.h"
#import "SOSPreferredTableViewCell.h"
#import "UITableView+Category.h"
#import "SOSDealerPickCityController.h"
#import "SOSDealerSearchController.h"

@interface SOSSelectDealerVC() <UITableViewDelegate, UITableViewDataSource, ViewControllerChooseCityDelegate, GeoDelegate, ErrorDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray *dealers;
@property (strong, nonatomic) NNDealers *selectDealer;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchContainerView;
@property (weak, nonatomic) IBOutlet UIButton *currentCityBtn;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (nonatomic, strong) SOSCityGeocodingInfo *city;
@property (nonatomic, strong) NNUpdatePreferDealer *updateRequest;
@property (assign, nonatomic) CLLocationCoordinate2D reLocatedCoord;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) BaseSearchOBJ *searchOBJ;
@property (weak, nonatomic) SOSDealerSearchController *searchVC;
@end

//默认上海市citycode
static NSString * const defaultCityCode = @"310000";

@implementation SOSSelectDealerVC

- (void)initData {
    _dealers = @[].mutableCopy;
}

- (void)initView {
    self.title = @"选择经销商";
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    confirmBtn.tintColor = [UIColor colorWithHexString:@"107FE0"];
    [confirmBtn sizeToFit];
    [confirmBtn addTarget:self action:@selector(confirmDealer:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:confirmBtn];

    _tableView.rowHeight = 150.f;
    _tableView.backgroundColor = [SOSUtil onstarLightGray];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerNib:[SOSPreferredTableViewCell class]];
    
    _searchTF.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self startLocate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)startLocate {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    _locationManager = locationManager;
    [Util showLoadingView];
}

#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dealers.count > 0 ? _dealers.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [_dealers count]) {
        FunctionCellForDealer *cell = (FunctionCellForDealer *)[[[UIViewController alloc] initWithNibName:@"FunctionCellForDealer" bundle:nil] view];
        cell.name.text = @"未找到经销商";
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    SOSPreferredTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SOS_GetClassString(SOSPreferredTableViewCell)];
    cell.detailLb.tag = indexPath.section;
    NNDealers *dealer = _dealers[indexPath.row];
    [cell initCellWithDealer:dealer withPath:indexPath selectIndexPath:nil];
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_dealers.count != 0) {
        _selectDealer = (_dealers[indexPath.row]);
        _selectedIndex = indexPath.row;
    }
}

#pragma mark - text field notification
- (void)textFieldTextDidChange:(NSNotification *)notification {
    [SOSDaapManager sendActionInfo:Dealeraptmt_PrfdealerChange_Search];
    if (_searchTF.text.length <= 0) {
        [self finishSearching];
    }else {
        if (!_searchVC) {
            SOSDealerSearchController *vc = [SOSDealerSearchController new];
            vc.dealers = _dealers;
            [self addChildViewController:vc];
            [self.view addSubview:vc.view];
            [vc.view mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.bottom.right.equalTo(self.view);
                make.top.equalTo(_searchContainerView.mas_bottom);
            }];
            _searchVC = vc;
            [_tableView reloadData];
            _selectDealer = nil;
            _selectedIndex = -1;
        }
        _searchVC.searchKey = _searchTF.text;
    }
}


#pragma mark - search dealer
- (IBAction)pickCity:(UIButton *)sender {
    
    [SOSDaapManager sendActionInfo:Dealeraptmt_PrfdealerChange_City];
    
    __weak __typeof(self)weakSelf = self;
    SOSDealerPickCityController *vc = [SOSDealerPickCityController new];
    vc.currentCity = _city;
    vc.pickedCity = ^(SOSCityGeocodingInfo *city) {
        [weakSelf finishSearching];
        weakSelf.city = city;
        NSString *cityName = city.city;
        [weakSelf updatePickBtnTitle:cityName];
        [weakSelf requestDealerWithCityCode:city.code];
        weakSelf.selectDealer = nil;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updatePickBtnTitle:(NSString *)cityName {
    if (cityName.length > 3) {
        cityName = [[cityName substringToIndex:3] stringByAppendingString:@"..."];
    }
    [_currentCityBtn setTitle:cityName forState:UIControlStateNormal];
}

- (void)finishSearching {
    [_searchTF resignFirstResponder];
    _searchTF.text = nil;
    [_searchVC.view removeFromSuperview];
    [_searchVC removeFromParentViewController];
}

#pragma mark - http request
- (void)requestDealerWithCityCode:(NSString *)cityCode {
    [_dealers removeAllObjects];
    NNAroundDealerRequest *request = [[NNAroundDealerRequest alloc] init];
    if ([cityCode length] == 0)     {
        [request setCityCode:@"0"]; // Get prefer dealer list
    } else {
        [request setCityCode:cityCode];
    }
    NSString *brandStr = @"ALL";
    if (self.isForRegisterOrAddVehicle) {
        //如果是注册或者添加车辆
    }
    else
    {
        //如果不是注册／添加车辆，是登录后选择经销商之类操作
        if ([[CustomerInfo sharedInstance] currentVehicle].brand) {
            brandStr = [SOSUtil brandToMSP:[[CustomerInfo sharedInstance] currentVehicle].brand];
        }
    }
    [request setDealerBrand:brandStr];
    NNCurrentlocation *locationRequest = [[NNCurrentlocation alloc] init];
    if (CLLocationCoordinate2DIsValid(_reLocatedCoord)) {
        locationRequest.latitude = [NSString stringWithFormat:@"%f", _reLocatedCoord.latitude];
        locationRequest.longitude = [NSString stringWithFormat:@"%f",_reLocatedCoord.longitude];
    }
    [request setCurrentLocation:locationRequest];
    if (self.currentQueryType == queryPreferDealer) {
        [request setQueryType:@"AFTER_SALE"];
    }else {
        [request setQueryType:@"PRE_SALE"];
    }
   
    [Util showLoadingView];
    
    [RegisterUtil queryDealerInfo:request subscriberID:_q_subscriberId?_q_subscriberId:[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId accountId:_q_accountId?_q_accountId:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId vinStr:_q_vin?_q_vin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin pageSize:self.query_pagesize successHandler:^(NSString *responseStr) {
        NNAroundDealerResponse *response = [[NNAroundDealerResponse alloc] init];
        response.dealers = [NNDealers mj_objectArrayWithKeyValuesArray:responseStr];
        if (response) {
            for (NNDealers *dealer in [response dealers]) {
                if ([dealer cityCode] && [dealer dealerName]) {
                    [_dealers addObject:dealer];
                }
            }
//            dispatch_sync(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                [_tableView scrollToTop];
//            });
        }
        [Util hideLoadView];

    } failureHandler:^(NSString *responseStr, NSError *error) {
//        dispatch_sync(dispatch_get_main_queue(), ^{
            [Util hideLoadView];
            [_dealers removeAllObjects];
            [_tableView reloadData];
            [_tableView scrollToTop];
//        });
    }];
}

- (void)updatePreferredDealer:(NNDealers *)dealer {
    if (dealer.dealersid.isNotBlank) {
        [Util showLoadingView];
        [DealersUtil updateFirstDealerWithPartID:dealer.dealersid successHandler:^(SOSNetworkOperation *operation, id responseData) {
            //        dispatch_sync(dispatch_get_main_queue(), ^{
            [self requestFinished:responseData];
            //        });
            
        } failureHandler:^(NSString *responseStr, NSError *error) {
            //        dispatch_sync(dispatch_get_main_queue(), ^{
            [[LoadingView sharedInstance] stop];
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
            //        });
        }];
    }else{
        [Util toastWithMessage:@"操作无法完成"];
    }

}

- (void)requestFinished:(NSString *)request     {
    [Util hideLoadView];
    _updateRequest = [NNUpdatePreferDealer mj_objectWithKeyValues:[Util dictionaryWithJsonString:request]];
    NNErrorDetail *errorInfo = _updateRequest.errorinfo;//[_updateRequest valueForKeyPath:@"errorInfo"];
    NSString *msg = nil;
    if ([[errorInfo code] isEqualToString:@"SB022_MSG017"]) {
        // 提示系统正在升级
        msg = @"系统正在升级，请您稍后再试";
    } else if ([errorInfo.msg length] > 0 || [[_updateRequest status] length] == 0) {
        msg = @"修改首选经销商失败";
    } else if ([_updateRequest.status.lowercaseString isEqualToString:@"failed"]){
        msg = @"修改首选经销商失败";
    }else {
        msg = @"修改首选经销商成功";
        if (_choosePreferDealer) {
            _choosePreferDealer(_selectDealer);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    [Util showAlertWithTitle:nil message:msg completeBlock:nil];

}

/**
 确认选择的Dealer
 */
- (void)confirmDealer:(id)sender {
    [SOSDaapManager sendActionInfo:Dealeraptmt_PrfdealerChange_Determine];
    [_searchTF resignFirstResponder];
    if (!_selectDealer && !_searchVC.selectedDealer) {
        [Util showAlertWithTitle:nil message:@"请选择一个经销商" completeBlock:nil];
        return;
    }
    //从注册界面进入
    if (_selectDealerBlock) {
        _selectDealerBlock(_selectDealer ? : _searchVC.selectedDealer);
        [self.navigationController popViewControllerAnimated:YES];
    }
    //更换首选经销商
    if (_choosePreferDealer) {
        [self updatePreferredDealer:_selectDealer ? : _searchVC.selectedDealer];
        [SOSDaapManager sendActionInfo:PrfdealerChange_save];
        return;
    }
    
}

#pragma mark - CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    _reLocatedCoord = location.coordinate;
    //逆地理编码获取当前城市的citycode
    [self reGeoCodeSearchCurrentLocation];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [manager stopUpdatingLocation];
    manager.delegate = nil;
}

- (void)reGeoCodeSearchCurrentLocation {
    BaseSearchOBJ *searchOBJ = [BaseSearchOBJ new];
    searchOBJ.geoDelegate = self;
    searchOBJ.errorDelegate = self;
    [searchOBJ reGeoCodeSearchWithLocation:[AMapGeoPoint locationWithLatitude:_reLocatedCoord.latitude longitude:_reLocatedCoord.longitude]];
    _searchOBJ = searchOBJ;
}

- (void)baseSearch:(id)searchOption Error:(NSString*)errCode
{
    [Util hideLoadView];
    [self requestDealerWithCityCode:defaultCityCode];
}
- (void)reverseGeocodingResults:(NSArray *)results  {
    if (results == nil || results.count == 0) {
        // city code is null, set defualt value *this case is imposible
        // this case sosReverseGeocodingFialed will be called
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util toastWithMessage:@"地图服务失败,请稍后再试"];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        return;
    }
    SOSPOI *resultPOI = results[0];
    NSString *cityName = @"";
    NSString *cityCode = @"";

    if ([Util isNotEmptyString:resultPOI.city] ) {
        cityName = resultPOI.city;
    } else {
        cityName  = @"上海市";
    }
    [self updatePickBtnTitle:cityName];

    
    //获取citycode
    NSArray *allCitys = [Util cityInfoArray];
    NSArray *citys = nil;
    for (NSDictionary *province in allCitys) {
        if ([resultPOI.province isEqualToString:[province objectForKey:@"ProvinceName"]]) {
            citys = [province objectForKey:@"cities"];
            break;
        }
    }
    if (citys.count > 0) {
        for (NSDictionary *city in citys) {
            if ([cityName isEqualToString:[city objectForKey:@"CityName"]]) {
                cityCode = [city objectForKey:@"CityCode"];
                break;
            }
        }
    }

    [self requestDealerWithCityCode:cityCode];
    SOSCityGeocodingInfo *city = [SOSCityGeocodingInfo new];
    city.city = cityName;
    city.code = cityCode;
    _city = city;
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    manager.delegate = nil;
    [Util hideLoadView];
    [self requestDealerWithCityCode:defaultCityCode];
    SOSCityGeocodingInfo *city = [SOSCityGeocodingInfo new];
    city.city = @"上海市";
    city.code = defaultCityCode;
    _city = city;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_dealers removeAllObjects];
}


@end
