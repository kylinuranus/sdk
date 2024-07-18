//
//  SOSPreferredDealerViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPreferredDealerViewController.h"
#import "SOSSelectDealerVC.h"
#import "PurchaseModel.h"
#import "LoadingView.h"
#import "SOSDealerEmptyView.h"
#import "SOSPOIMapVC.h"
#import "SOSUserLocation.h"
#import "PreferDealerRequestClient.h"

@interface SOSPreferredDealerViewController ()<PreferDealerRequestClientDelegate, SOSPreferredTableViewCellDelegate>
@property (nonatomic, strong) NNPreferDealerDataResponse *myPreferDealerResponse;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (assign, nonatomic) BOOL hasData;
@property (strong, nonatomic) NNDealers *dealer;
@property (strong, nonatomic) SOSDealerEmptyView *emptyView;
@property (weak, nonatomic) SOSPOI *currentLocationPOI;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *changeBtnBottomConstraint;
@property (assign, nonatomic) BOOL isFirstLoad;

@end

@implementation SOSPreferredDealerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    if ([SOSCheckRoleUtil isDriverOrProxy]) {
//        _changeBtn.enabled = NO;
//        _changeBtn.backgroundColor = [UIColor lightGrayColor];
//    }
    _isFirstLoad = YES;
//    _currentLocationPOI = [CustomerInfo sharedInstance].currentPositionPoi;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _changeBtnBottomConstraint.constant = self.view.sos_safeAreaInsets.bottom;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isFirstLoad) {
        _isFirstLoad = NO;
    }else {
        [self getPreferredDealer];
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _hasData ? 1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSPreferredTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSPreferredTableViewCell"];
    if (!cell) {
        cell = [[NSBundle SOSBundle] loadNibNamed:@"SOSPreferredTableViewCell" owner:self options:nil][0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.shouldShowDistance = _currentLocationPOI;
    cell.isFromPrefer = YES;
    [cell initCellWithDealer:_dealer withPath:nil selectIndexPath:nil];
    cell.showArrow = YES;
    cell.delegate = self;
    cell.dealers = @[_dealer];
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        [self pushMapVc:_dealer];

}

- (void)getPreferredDealer {
    [[LoadingView sharedInstance] startIn:self.view];
    if (!_currentLocationPOI) {
        @weakify(self);
        [[SOSUserLocation sharedInstance] getLocationWithAccuarcy:kCLLocationAccuracyKilometer NeedReGeocode:YES isForceRequest:NO NeedShowAuthorizeFailAlert:YES success:^(SOSPOI *poi) {
            @strongify(self);
            self.currentLocationPOI = poi;
            [self startRequest];
        } Failure:^(NSError *error) {
            if (error.code == 5) {
                return;
            }
            [Util toastWithMessage:@"可能由于您的GPS信号问题暂时无法为您展开距离信息，请稍候再试"];
            [self startRequest];
        }];
    }else {
        [self startRequest];
    }
}

- (void)startLoadData:(SOSPOI *)currentLocationPOI {
    _currentLocationPOI = currentLocationPOI;
    [self startRequest];
}

- (void)startRequest {
    PreferDealerRequestClient *client = [[PreferDealerRequestClient alloc] init];
    [client getPreferredDealer:self sospoi:_currentLocationPOI];
    client.delegate = self;

}

#pragma mark - PreferDealerRequestClientDelegate
- (void)requestDataFinished:(NSString *)requestStr     {
    _dealer = [NNDealers mj_objectWithKeyValues:[Util dictionaryWithJsonString:requestStr]];
    _hasData = [_dealer.isPreferredDealer boolValue];
    
    dispatch_async_on_main_queue(^{
        [self.table reloadData];
        [Util hideLoadView];
        NSString *buttonStr = _hasData? @"更换首选经销商" : @"设置首选经销商";
        [_changeBtn setTitle:buttonStr forState:UIControlStateNormal];
        self.emptyView.hidden = _hasData;
    });
}

- (IBAction)changePreferDealer:(id)sender{

    SOSSelectDealerVC *dealerVC = [SOSSelectDealerVC new];
    dealerVC.query_pagesize = @"10";
    dealerVC.backRecordFunctionID = PrfdealerChange_back;
    [SOSDaapManager sendActionInfo:Dealeraptmt_PrfdealerChange];
    dealerVC.choosePreferDealer = ^(id dealerModel) {
        
    };
    [self.navigationController pushViewController:dealerVC animated:YES];
}

- (SOSDealerEmptyView *)emptyView{
    if (!_emptyView) {
        _emptyView = [SOSDealerEmptyView viewFromXib];
        _emptyView.frame = self.table.bounds;
        [self.view addSubview:_emptyView];
        [self.view bringSubviewToFront:_emptyView];
    }
    return _emptyView;
}

- (void)pushMapVc:(NNDealers *)dealers{
    [SOSDaapManager sendActionInfo:Prfdealer_address];
    SOSPOIMapVC *indexVC = [[SOSPOIMapVC alloc] initWithPoiInfo:dealers.poi];
    indexVC.backDaapFunctionID = Dealeraptmt_Map_back;
    indexVC.dealer = dealers;
    indexVC.mapType = MapTypeShowDealerPOI;
    [CustomerInfo sharedInstance].isInDelear = YES;
    [self.navigationController pushViewController:indexVC animated:YES];
    
}

- (void)dealloc
{
    [CustomerInfo sharedInstance].isInDelear = NO;
    NSLog(@"dealloc-----");
}

@end
