//
//  SOSChangeVehicleViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSChangeVehicleViewController.h"
#import "SOSVehicleListTableViewCell.h"
#import "NSString+JWT.h"
#import "AccountInfoUtil.h"
//#import "CustomAlertView.h"
#import "NameInputViewController.h"
#import "OwnerViewController.h"
#import "LoadingView.h"
#import "UserCarInfoVC.h"
#import "ServiceController.h"
@interface SOSChangeVehicleViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) NSArray *tableArray;
@end

@implementation SOSChangeVehicleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.backRecordFunctionID = VEHICLEINFO_CHANGECARS_BACK;
    self.backDaapFunctionID = VEHICLEINFO_CHANGECARS_BACK;

    self.title = @"切换车辆";
    self.table.tableFooterView = [UIView new];
//    [self initNavigationBarButtonItem];
    //获取本人车辆列表
    [self getVehicleList_sendToBackground];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    @weakify(self);
    [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
        @strongify(self)
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (state.integerValue == LOGIN_STATE_NON ) {
                dispatch_async_on_main_queue(^{
                    [Util hideLoadView];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [Util showAlertWithTitle:nil message:@"切换车辆失败" completeBlock:nil];
                });
            }
            if (state.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
    //            if (selectBlock) {
    //                selectBlock();
    //            }
                [[NSNotificationCenter defaultCenter] postNotificationName:SOSkSwitchVehicleSuccess object:nil];

                [UserCarInfoVC getVehicleBasicInfoSuccess:^(BOOL success) {
                    [Util hideLoadView];
                    [self.navigationController popViewControllerAnimated:YES];
                    if (success) {
                        
                        [Util showAlertWithTitle:nil message:NSLocalizedString(@"vehicleManagementSuccessMessage", @"") completeBlock:nil];
                        
                    }else
                    {
                        [Util showAlertWithTitle:nil message:@"获取车辆信息失败" completeBlock:nil];
                    }
                }];
                
            }
        });
        
      
        
    }];
}
//- (void)initNavigationBarButtonItem
//{
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"添加车辆", nil)style:UIBarButtonItemStylePlain target:self action:@selector(addVehicle)];
//}
- (void)addVehicle
{
    [SOSDaapManager sendActionInfo:VEHICLEINFO_CHANGECARS_ADDVEHICLE];
    OwnerViewController * scanVIN = [[OwnerViewController alloc] initWithNibName:@"OwnerViewController" bundle:nil];
    scanVIN.vinCodeOnly = YES;
    scanVIN.backRecordFunctionID = AddCar_back;
    [SOSRegisterInformation sharedRegisterInfoSingleton].registerWay = SOSRegisterWayAddVehicle;
    [self.navigationController pushViewController:scanVIN animated:YES];
}
#pragma mark - 获取本人车辆列表
- (void)getVehicleList_sendToBackground {
    [Util showLoadingView];
    NSString *url = [NSString stringWithFormat:(@"%@" NEW_GET_VEHICLE_LIST), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId];
    @weakify(self);
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NNGetVehicleListResponse *httpResponse = [[NNGetVehicleListResponse alloc] init];
        [httpResponse setVehicles:[NNVehicle mj_objectArrayWithKeyValuesArray:[Util dictionaryWithJsonString:responseStr]]];
        _tableArray = [httpResponse vehicles];
        //刷新tableView
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util hideLoadView];
            [self.table reloadData];
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [operation setHttpMethod:@"GET"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation start];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _tableArray.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        SOSVehicleListTableViewCell *listCell = [tableView dequeueReusableCellWithIdentifier:@"SOSVehicleListTableViewCell1"];
        if (!listCell) {
            listCell = [[NSBundle SOSBundle] loadNibNamed:@"SOSVehicleListTableViewCell" owner:self options:nil][1];
        }
        return listCell;
    }
    SOSVehicleListTableViewCell *listCell = [tableView dequeueReusableCellWithIdentifier:@"SOSVehicleListTableViewCell"];
    if (!listCell) {
        listCell = [[NSBundle SOSBundle] loadNibNamed:@"SOSVehicleListTableViewCell" owner:self options:nil][0];
    }
    NNVehicle *vehicleInfo = [self.tableArray objectAtIndex:indexPath.row];
    NSMutableString *modelDesc = vehicleInfo.modelDesc.mutableCopy;
    NSInteger index = NSIntegerMax;
    NSString *temp = nil;
    for(int i =0; i < modelDesc.length; i++) {
        if ([[modelDesc substringWithRange:NSMakeRange(i, 1)] isEqualToString:@" "]) {
            index = i;
            temp = [modelDesc substringWithRange:NSMakeRange(i, 1)];
            break;
        }
    }
    if (index != NSIntegerMax) {
        [modelDesc insertString:@" ·" atIndex:index];
    }
    
    listCell.carNameLB.text = modelDesc;

    listCell.vinLB.text = [NSString stringWithFormat:@"%@",[Util recodesign:vehicleInfo.vin]];
    //LOGO
    if ([vehicleInfo.brand isEqualToString:@"buick"]) {
        listCell.carImgView.image = [UIImage imageNamed:@"brand_BUICK"];
    }else if ([vehicleInfo.brand isEqualToString:@"cadi"]) {
        listCell.carImgView.image = [UIImage imageNamed:@"brand_cadillac"];
    }else if ([vehicleInfo.brand isEqualToString:@"chevy"]) {
        listCell.carImgView.image = [UIImage imageNamed:@"brand_CHEVROLET"];
    }
    
    if ([vehicleInfo.vin isEqualToString:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin]) {
//        listCell.imageView.hidden = NO;
        listCell.bgView.layer.borderWidth = 2;
    }else{
//        listCell.imageView.hidden = YES;
        listCell.bgView.layer.borderWidth = 0;
    }
    return listCell;
}
//static void (^selectBlock)(void ) = nil;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    selectBlock = ^(){
//        SOSVehicleListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        cell.imageView.hidden = NO;
//        for (int i = 0; i < _tableArray.count; i ++) {
//            if (indexPath.row != i) {
//                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
//                SOSVehicleListTableViewCell *cell = [tableView cellForRowAtIndexPath:path];
//                cell.imageView.hidden = YES;
//            }
//        }
//    };
    if (indexPath.section == 0) {
        NNVehicle *selectedVehicleInfo =[self.tableArray objectAtIndex:indexPath.row];
        NSString *selectedAccountNo = selectedVehicleInfo.accountID;
        NSString *selectedVin = selectedVehicleInfo.vin;
        if (![selectedVin isEqualToString:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin]) {
//            if (![[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId isEqualToString:selectedAccountNo]) {
//                [self changeVehicleWithAccount:selectedAccountNo withVin:selectedVin inOneAccount:NO];
//            } else {
//                [self changeVehicleWithAccount:selectedAccountNo withVin:selectedVin inOneAccount:YES];
//            }
            
            //新切车接口中包含了info3切车判断是否补充姓名的逻辑，因此点击后直接调用切车
            NNChangeVehicleRequest * requestBody = [[NNChangeVehicleRequest alloc] init];
            requestBody.vin = selectedVin;
            requestBody.idpUserID =[CustomerInfo sharedInstance].userBasicInfo.idpUserId;
            requestBody.nickName = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
            requestBody.subscriberID = [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId;
            
            if (![[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId isEqualToString:selectedAccountNo]) {
                [self changeAndSaveAccount:selectedAccountNo withVin:selectedVin inOneAccount:NO params:[requestBody mj_JSONString]];
            } else {
                [self changeAndSaveAccount:selectedAccountNo withVin:selectedVin inOneAccount:YES params:[requestBody mj_JSONString]];
            }
        }
    }else {
        //添加添加车辆
        [self addVehicle];
    }
    
}



- (void)changeVehicleRequestWithAccount:(NSString *)accountID Vin:(NSString *)vin inOneAccount:(BOOL)isOneAccount params:(NSString *)parastr
{
   
     [self changeAndSaveAccount:accountID withVin:vin inOneAccount:isOneAccount params:parastr];
    
}

- (BOOL)changeAndSaveAccount:(NSString *)accountNo withVin:(NSString *)vin inOneAccount:(BOOL)isOneAccount params:(NSString *)paraStr
{
    __block BOOL isSuccess = NO;
    NSString *changeURL;
    NSString *tmpURL = [NSString stringWithFormat:INFO3_CHANGE_VEHICLE, accountNo];
    changeURL = [NSString stringWithFormat:@"%@%@", BASE_URL, tmpURL];
    NSLog(@"changeAndSaveAccount%@",[NSThread currentThread]);
    [Util showLoadingView];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:changeURL params:paraStr successBlock:^(SOSNetworkOperation *operation, NSString *responseStr) {
        //先根据response更新下vin号,给接口调用
        NNVehicle *vehicle = [NNVehicle mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];//
        [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin = vehicle.vin;
        if (isOneAccount) {
            if ([responseStr length] > 0) {
                NNVehicle *vehicle = [NNVehicle mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];//
                if ([vehicle vin].length > 0) {
                    // 同一个帐号内切车，需要重新获取vehicle commands
                    [self reLogin];
                }
            }
        } else {
            //不同账号切车需做重新登录
//            [[CustomerInfo sharedInstance]clearVehicleCommand];
                  [self reLogin];
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        // 切换失败，重新显示车辆列表
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        [self.table reloadData];
        isSuccess = NO;
        NSDictionary *errorDic = [responseStr mj_JSONObject];
        if ([errorDic[@"errorCode"] isEqualToString:@"E1001"]) {
            [self goInputName:accountNo vin:vin inOneAccount:isOneAccount];
        }
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
    return isSuccess;
}


-(void)goInputName:(NSString*)accountID vin:(NSString*)vin inOneAccount:(BOOL)isOneAccount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NameInputViewController * viewControl = [[NameInputViewController alloc] initWithNibName:@"NameInputViewController" bundle:nil];
        [viewControl setCompleteBlock:^(NSString * firstName,NSString * lastName){
            NNChangeVehicleRequest * requestBody = [[NNChangeVehicleRequest alloc] init];
            requestBody.vin = vin;
            requestBody.idpUserID =[CustomerInfo sharedInstance].userBasicInfo.idpUserId;
            requestBody.firstName = firstName;
            requestBody.lastName = lastName;
            requestBody.nickName = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
            requestBody.subscriberID = [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId;

            dispatch_async(dispatch_get_main_queue(), ^{
                //添加一个loading界面
                [Util showLoadingView];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self changeVehicleRequestWithAccount:accountID Vin:vin inOneAccount:isOneAccount params:[requestBody mj_JSONString]];
                });
            });
        }];
        [self.navigationController pushViewController:viewControl animated:YES];
    });
}

- (BOOL)reLogin
{
    
    [LoginManage sharedInstance].continueShowLoading = YES;
    [CustomerInfo sharedInstance].servicesInfo.hasResponse = NO;
    [LoginManage sharedInstance].needLoadCache = NO;
    [[ServiceController sharedInstance] stopPolling];
    [[LoginManage sharedInstance] oAuthReAuthToken:YES];
    return YES;
}

//#pragma mark -Register Response
//- (void)popMessage:(NSString *) message withTitle:(NSString *)title
//{
//    CustomAlertView *alertView = [[CustomAlertView alloc]initWithTitle:title Message:message Cancelbutton:NSLocalizedString(@"OkButtonTitle", nil) OtherButton:nil Delegate:self SuperView:self.view];
//    [alertView setAlertBackgroundImage:@"popup2"];
//    [alertView alertShow];
//}

- (void)CustomalertView:(id)customalertview buttonclickedAtindex:(NSInteger)index
{
    [SOSDaapManager sendActionInfo:VEHICLEINFO_CHANGECARS_BACK];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc
{
    NSLog(@"SOSChangeVehicleViewController Dealloc");
}
@end
