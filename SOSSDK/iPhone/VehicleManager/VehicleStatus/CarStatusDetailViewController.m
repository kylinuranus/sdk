//
//  CarStatusDetailViewController.m
//  Onstar
//
//  Created by Joshua on 14-9-10.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import "CarStatusDetailViewController.h"
#import "CarStatusCell.h"
#import "CustomerInfo.h"
#import "UIImageView+Banner.h"
#import "UIImageView+WebCache.h"
#import "SOSWebViewController.h"
#import "CustomNavigationController.h"
#import "OwnerLifeBannerView.h"
#import "SOSCheckRoleUtil.h"
#import "SOSLoginDbService.h"
#import "SOSDealerTool.h"
#import "SOSCardUtil.h"

#define COLOR_RED       UIColorHex(#C50000)
#define COLOR_YELLOW    UIColorHex(#F18F19)
#define COLOR_GREEN     UIColorHex(#6CCA46)
#define COLOR_WHITE     ([UIColor colorWithRed:0xFF/255.0f green:0xFF/255.0f blue:0xFF/255.0f alpha:1.0f])

@interface CarStatusDetailViewController ()     {
    NSArray *gasInfo;
    NSArray *oilInfo;
    NSArray *tireInfo;
    NSArray *batteryInfo;
    NSArray *brakeInfo;
    NSMutableArray *mileageInfo;
    NSArray *evRangeInfo;
    NSMutableArray *cellArray;
    
//    SOSBanner *bannerView;
}


@property (nonatomic, strong) OwnerLifeBannerView *bannerView;
@property(nonatomic, assign) BOOL showMaintenanceFlag;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *banerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBtnBottom;
@property (nonatomic, assign) VehicleStatus brakeStatus;
@end

@implementation CarStatusDetailViewController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _searchBtnBottom.constant = self.view.sos_safeAreaInsets.bottom + 30;
    self.view.backgroundColor = UIColorHex(#F3F5FE);
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"查看维修保养建议";
    if (Util.vehicleIsMy21) {
        _brakeStatus = SOSVehicleVariousStatus.brakeStatus;
    }
    [searchDealerButton setTitle:@"联系经销商" forState:UIControlStateNormal];
    [searchDealerButton setCommonStyle];
    [searchDealerButton setBackgroundColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateSelected];

    searchDealerButton.hidden = YES;
//    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGTOKENSUCCESS) {
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        [CustomerInfo selectVehicleDataFromDB:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        NSInteger fuelLevel = [[CustomerInfo sharedInstance].fuelLavel floatValue];
        if (fuelLevel != 0 || [Util vehicleIsEV]) {
            _showMaintenanceFlag = YES;
        }
        
        if ([SOSCheckRoleUtil isOwner]) {
            searchDealerButton.hidden = NO;
        }
        
    }

    if (_showMaintenanceFlag) {
        noMaintenanceSgstView.hidden = YES;
        contentTableView.delegate = self;
        contentTableView.dataSource = self;
        [self generateMileageHints];
        [self setupData];
        [self loadCell];
    }else{
        noMaintenanceSgstView.hidden = NO;
    }
//与苏南沟通暂时去掉
//    [self loadBanner];
    self.backRecordFunctionID = _isFromOwnerLife?maintenance_back:CARCONDITIONS_MAINTAINSUGGEST_BACK;
    self.backDaapFunctionID = _isFromOwnerLife?maintenance_back:CARCONDITIONS_MAINTAINSUGGEST_BACK;
}

- (void)setupData
{
    if (Util.vehicleIsMy21) {
        switch (self.brakeStatus) {
            case BRAKE_GREEN:
                brakeInfo = @[@"刹车片正常", COLOR_GREEN, @"请放心驾驶"];
                break;
            case BRAKE_YELLOW:
                brakeInfo = @[@"刹车片磨损严重", COLOR_YELLOW, @"请尽快更换"];
                break;
            case BRAKE_RED:
                brakeInfo = @[@"刹车片寿命即将耗尽", COLOR_RED, @"请立即更换"];
                break;
            default:
                brakeInfo = nil;
                break;
        }
        if ([CustomerInfo.sharedInstance.brakePadLifeStatus.uppercaseString isEqualToString:BRAKE_PAD_LIFE_Service]) {
            brakeInfo = @[@"暂时无法获取刹车片状态", [UIColor colorWithHexString:@"#A4A4A4"], @"请稍后再试"];
        }
    }
    switch (self.gasStatus) {
        case GAS_GREEN_PERFECT:
            gasInfo = @[@"SufficientGas", COLOR_GREEN, @"SufficientGasHint1"];
            break;
        case GAS_GREEN_GOOD:
            gasInfo = @[@"SufficientGas", COLOR_GREEN, @"SufficientGasHint2"];
            break;
        case GAS_YELLOW:
            gasInfo = @[@"LowGas", COLOR_YELLOW, @"LowGasHint"];
            
            break;
        case GAS_RED:
            gasInfo = @[@"EmptyGas", COLOR_RED, @"EmptyGasHint"];
            break;
        default:
            gasInfo = nil;
    }
    
    switch (self.oilStatus) {
        case OIL_GREEN:
            oilInfo = @[@"NormalOil", COLOR_GREEN, @"NormalOilHint"];
            break;
        case OIL_YELLOW:
            oilInfo = @[@"LowOil", COLOR_YELLOW, @"LowOilHint", @"OnstarOilWarning"];
            break;
        case OIL_RED:
            oilInfo = @[@"EmptyOil", COLOR_RED, @"EmptyOilHint", @"OnstarOilWarning"];
            break;
        default:
            oilInfo = nil;
            break;
    }
    
    switch (self.pressureStatus) {
        case PRESSURE_GREEN:
            tireInfo = @[@"NormalTirePressure", COLOR_GREEN, @"NormalTirePressureHint"];
            break;
        case PRESSURE_YELLOW:
            tireInfo = @[@"LowTirePressure", COLOR_YELLOW, @"LowTirePressureHint"];
            break;
        case PRESSURE_RED:
            tireInfo = @[@"AbnormalPressure", COLOR_RED, @"AbnormalPressureHint"];
            break;
        default:
            tireInfo = nil;
            break;
    }
    
    switch (self.batteryStatus) {
        case BATTERY_GREEN:
            batteryInfo = @[@"NormalBattery", COLOR_GREEN];
            break;
        case BATTERY_YELLOW:
            batteryInfo = @[@"LowBattery", COLOR_YELLOW];
            break;
        case BATTERY_RED:
            batteryInfo = @[@"LowBattery", COLOR_RED];
            break;
        default:
            batteryInfo = nil;
            break;
    }
    
    if ([Util vehicleIsEV]) {
        gasInfo = nil;
        oilInfo = nil;
        batteryInfo = nil;
        mileageInfo = nil;
        if (![[CustomerInfo sharedInstance].bevBatteryRange isEqualToString:@"--"] && [CustomerInfo sharedInstance].bevBatteryRange.floatValue < 50) {
            evRangeInfo = @[@"电池续航里程不足", COLOR_RED, @"电池续航里程不足50KM，请尽快为您的爱车充电"];
        }

    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([SOSCheckRoleUtil isDriverOrProxy] || [SOSCheckRoleUtil isOwner]) {
        searchDealerButton.hidden = NO;
    }else{
        searchDealerButton.hidden = YES;
    }
}


- (void)loadBanner
{
    [OthersUtil getBannerByCategory:BANNER_MAINTAIN CarOwnersLiv:NO SuccessHandle:^(id responseStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置banner
            self.bannerView = [[OwnerLifeBannerView alloc] initWithFrame:bannerContentView.bounds];
            self.bannerView.viewCtrl = self;
            [bannerContentView addSubview:self.bannerView];
//            self.bannerView.bannerFunctionIDArray= @[Maintainence_banner1,Maintainence_banner2,Maintainence_banner3,Maintainence_banner4,Maintainence_banner5];
            NSArray *imgArray = [NNBanner mj_objectArrayWithKeyValuesArray:responseStr];
            if (imgArray.count) {
                self.banerHeightConstraint.constant = 90;
            }else {
                self.banerHeightConstraint.constant = 0;
            }
            self.bannerView.imageArray = imgArray;
        });
    } failureHandler:^(NSString *responseStr, NSError *error) {
    }];
}

- (void)generateMileageHints
{
    if (self.mileage >= 0) {
        mileageInfo = [[NSMutableArray alloc] init];
        [mileageInfo addObject:@"MaintainanceTips"];
        [mileageInfo addObject:UIColorHex(#6896ED)];
        [mileageInfo addObject:@"MaintainanceTipsHint"];
        
        if (_mileage < 9000.0f) {
            return;
        }
        NSInteger reminder = (int)_mileage % 10000;
        if (reminder <= 500 || reminder >= 9500) {
            [mileageInfo addObjectsFromArray:@[@"AirFilter", @"FuelFilter", @"PowerSteeringOil", @"Restrict"]];
        }
        reminder = (int)_mileage % 20000;
        if (reminder <= 1000 || reminder >= 19000) {
            [mileageInfo addObject:@"OilNozzleFuelLine"];
        }
        reminder = (int)_mileage % 25000;
        if (reminder <= 2500 || reminder >= 22500) {
            [mileageInfo addObject:@"BrakeFluid"];
        }
        reminder = (int)_mileage % 40000;
        if (reminder <= 4000 || reminder >= 36000) {
            [mileageInfo addObject:@"TransmissionFluid"];
            [mileageInfo addObject:@"EngineCoolant"];
        }
        [mileageInfo addObject:@"OnstarWarning2"];
    }
}

- (void)loadCell
{
    cellArray = [[NSMutableArray alloc] init];
    if (gasInfo) {
        CarStatusCell *cell = [[CarStatusCell alloc] init];
        [cell fillContent:gasInfo withMultiLabel:NO];
        [cellArray addObject:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (oilInfo) {
        CarStatusCell *cell = [[CarStatusCell alloc] init];
        [cell fillContent:oilInfo withMultiLabel:NO];
        [cellArray addObject:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (batteryInfo) {
        CarStatusCell *cell = [[CarStatusCell alloc] init];
        [cell fillContent:batteryInfo withMultiLabel:NO];
        [cellArray addObject:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (tireInfo) {
        CarStatusCell *cell = [[CarStatusCell alloc] init];
        [cell fillContent:tireInfo withMultiLabel:NO];
        [cellArray addObject:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([mileageInfo count] > 4) {
        CarStatusCell *cell = [[CarStatusCell alloc] init];
        [cell fillContent:mileageInfo withMultiLabel:YES];
        [cellArray addObject:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (evRangeInfo) {
        CarStatusCell *cell = [[CarStatusCell alloc] init];
        [cell fillContent:evRangeInfo withMultiLabel:NO];
        [cellArray addObject:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([Util vehicleIsMy21] && brakeInfo) {
        CarStatusCell *cell = [[CarStatusCell alloc] init];
        [cell fillContent:brakeInfo withMultiLabel:NO];
        [cellArray addObject:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
//    NSArray *arr = [CustomerInfo sharedInstance].bannerArr;
//    if (arr.count > 0) {
//        NSMutableArray *bannerArr = [NSMutableArray new];
//        UIImageView * firstImage =[[arr objectAtIndex:0] copy];
//        firstImage.bannerInfo.functionId =MaintenanceSgst_Banner;
//        [bannerArr addObject:firstImage];
//        SOSBanner *latestBanner = nil;
//        CarStatusCell *cell = [[CarStatusCell alloc] init];
//        latestBanner = [[SOSBanner alloc] initWithFrame:CGRectMake(20, 25, SCREEN_WIDTH - 40, 75.5) imageViewArray:bannerArr scrollType:eBannerScrollTypeCycle];
//        bannerView = latestBanner;
//        cell.frame = CGRectMake(0, 25, SCREEN_WIDTH, 75.5 + 25);
//        [cell.contentView addSubview:bannerView];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        [cellArray addObject:cell];
//    }
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [cellArray count] ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CarStatusCell *cell = [cellArray objectAtIndex:indexPath.row];
    CGFloat height = cell.frame.size.height;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath	{
    return [cellArray objectAtIndex:indexPath.row];
}

- (IBAction)searchAroundDealer:(id)sender	{
    NSString * functionID = _isFromOwnerLife?maintenance_dealer:CARCONDITIONS_MAINTAINSUGGEST_CONTACTDEALER;
    [SOSDaapManager sendActionInfo:functionID];
//    [SOSDealerTool jumpToDealerListMapVCFromVC:self WithPOI:nil isFromTripPage:NO];
    [SOSCardUtil routerToDealerRev];
}

- (void)dealloc{
    [mileageInfo removeAllObjects];
    [cellArray removeAllObjects];
}

@end
