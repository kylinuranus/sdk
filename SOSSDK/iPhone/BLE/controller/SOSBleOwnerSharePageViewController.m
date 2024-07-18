//
//  SOSBleOwnerSharePageViewController.m
//  Onstar
//
//  Created by onstar on 2018/7/19.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleOwnerSharePageViewController.h"
#import "SOSBleOwnerShareListViewController.h"
#import "SOSOwnerHistorySharePageViewController.h"
#import "SOSBleNetwork.h"
#import "SOSAuthorInfo.h"
#import "LoadingView.h"
#import "SOSBleUtil.h"
#import "SOSBleShareDateView.h"
#import <RMUniversalAlert/RMUniversalAlert.h>
#import <PGDatePicker/PGDatePickManager.h>
#import "WeiXinMessageInfo.h"
#import "NavigateShareTool.h"
#import "SOSBleQRViewController.h"
#import "SOSBleCarInfoView.h"
#import "SOSRemoteTool.h"
#import <DateTools/DateTools.h>
#import "SOSBlePinUtil.h"

@interface SOSBleOwnerSharePageViewController ()

@property (nonatomic, copy) NSArray *tempDataArray;
@property (nonatomic, copy) NSArray *permDataArray;
@property (nonatomic, copy) NSArray *historyTempDataArray;
@property (nonatomic, copy) NSArray *historyPermDataArray;
@end

@implementation SOSBleOwnerSharePageViewController
{
    SOSBleOwnerShareListViewController *tempShareVc;
    SOSBleOwnerShareListViewController *foreverShareVc;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"蓝牙钥匙共享管理";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加新共享" style:UIBarButtonItemStylePlain target:self action:@selector(shareMyCar)];
    
    
    [self configPage];
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self request];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self request];
}

- (void)configPage {
    SOSBleCarInfoView *carInfoView = [SOSBleCarInfoView viewFromXib];
    [carInfoView showOwnerCarInfo];
    [self.view addSubview:carInfoView];
    
    [carInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(70);
    }];
    
    
    [self.segmentVC.view mas_updateConstraints:^(MASConstraintMaker *make){
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(60);
        make.bottom.mas_equalTo(self.view.bottom).mas_offset(-self.view.sos_safeAreaInsets.bottom - 50);
    }];
    
    
    tempShareVc = [SOSBleOwnerShareListViewController new];
    foreverShareVc = [SOSBleOwnerShareListViewController new];
    
    [self setUpWithItems:@[@"临时共享",@"永久共享"] childVCs:@[tempShareVc, foreverShareVc]];
    
    UIButton *historyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [historyBtn setTitle:@"历史记录" forState:UIControlStateNormal];
    [historyBtn setBackgroundColor:[UIColor colorWithRed:226/255.0 green:228/255.0 blue:230/255.0 alpha:1] forState:UIControlStateNormal];
    [historyBtn addTarget:self action:@selector(gotoHistory) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:historyBtn];
    [historyBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(self.view.bottom).mas_offset(-self.view.sos_safeAreaInsets.bottom);
    }];
}

- (void)setUpWithItems:(NSArray *)items childVCs:(NSArray *)vcArray        {
    //    3 添加标题数组和控住器数组
    [self.segmentVC setUpWithItems:items childVCs:vcArray];
    //    4  配置基本设置  可采用链式编程模式进行设置
    [self.segmentVC.segmentBar updateWithConfig:^(LLSegmentBarConfig *config) {
        config.sBBackColor = [UIColor whiteColor];
        config.itemNormalColor([UIColor colorWithHexString:@"94A2B3"]).itemSelectColor([UIColor colorWithHexString:@"4E5059"]).indicatorColor([UIColor colorWithHexString:@"6896ED"]).itemFont([UIFont systemFontOfSize:16.f]).indicatorHeight(2).indicatorExtraW(5);
    }];
}

/**
 发起新共享
 */
- (void)shareMyCar {
    if (self.selectedIndex == 0) {
        [SOSDaapManager sendActionInfo:BLEOwner_TempCarsharing_Add_New];
    }else {
        [SOSDaapManager sendActionInfo:BLEOwner_PermCarsharing_Add_New];
    }
    [SOSDaapManager sendActionInfo:BLEOwner_Uppercorner_Add_New];
    [SOSBlePinUtil checkPINCodeSuccess:^{
        
        
        
        [RMUniversalAlert showActionSheetInViewController:self
                                                withTitle:nil
                                                  message:nil
                                        cancelButtonTitle:@"取消"
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:@[@"临时共享",@"永久共享"]
                       popoverPresentationControllerBlock:nil
                                                 tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {
                                                     if (buttonIndex == alert.firstOtherButtonIndex) {
                                                         //临时
                                                         [self showTempShareView];
                                                     }else if (buttonIndex == alert.firstOtherButtonIndex+1) {
                                                         //永久
                                                         [self showPermQrPageRequest];
                                                     }else {
                                                         [SOSDaapManager sendActionInfo:BLEOwner_Add_New_Cancle];
                                                     }
                                                     
                                                 }];
        
    }];
    
    
    
    
}

- (void)showTempShareView {
    [SOSDaapManager sendActionInfo:BLEOwner_Add_New_TempCarsharing];
    if ([self checkShareNumberEnough]) {

        SOSBleShareDateView * dateView = [SOSBleShareDateView viewFromXib];
        @weakify(self)
        dateView.dateButtonTapBlock = ^(SOSBleShareDateView *dateV, UIButton *button) {
            //显示日期选择器
            @strongify(self)
            [self showDatePickerTarget:button dateView:dateV];
        };
        
        dateView.shareButtonTapBlock = ^(SOSBleShareDateView *dateV) {
            
            //新增授权
            @strongify(self)
            
                NSDictionary *params = @{@"idpUserId": [CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@"",
                                         @"authorizationType": @"TEMP",
                                         @"disclaimer": @"ND",
                                         @"permission": @"All",
                                         @"startTime": @(dateV.startTime.timeIntervalSince1970*1000),
                                         @"endTime": @(dateV.endTime.timeIntervalSince1970*1000),
                                         @"vin": [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin?:@""
                                         
                                         };
                [self shareRequestWithParams:params successBlock:^{
                    [dateV dismiss];
                }];
                [SOSDaapManager sendActionInfo:BLEOwner_Add_New_TempCarsharing_Send];
    //        }
        };
        
        
        [self.navigationController.view addSubview:dateView];
        [dateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.navigationController.view);
        }];
    }
}
-(BOOL)checkShareNumberEnough{
    if (self.tempDataArray.count + self.permDataArray.count >= 10) {
        [Util toastWithMessage:@"您的共享授权已达到10个，需要关闭其他共享才可以发起新共享"];
        [SOSDaapManager sendActionInfo:BLEOwner_Add_New_TempCarsharing_Send_fail_over10];
        return NO;
    }else{
        return YES;
    }
}
- (void)showPermQrPageRequest {
    if ([self checkShareNumberEnough]) {
        
        [SOSDaapManager sendActionInfo:BLEOwner_Add_New_PermCarsharing];
        [SOSDaapManager sendActionInfo:BLEOwner_Add_New_PermCarsharing_QR];
        NSDate *now = [[NSDate date] dateByAddingDays:-1];
        
        NSDictionary *params = @{@"idpUserId": [CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@"",
                                 @"authorizationType": @"PERM",
                                 @"disclaimer": @"ND",
                                 @"permission": @"All",
                                 @"startTime": @((long)now.timeIntervalSince1970*1000),
                                 @"vin": [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin?:@""
                                 
                                 };
        [self shareRequestWithParams:params successBlock:nil];
    }
}

- (void)shareRequestWithParams:(NSDictionary *)params successBlock:(void (^)(void))successBlock {
    [SOSBleNetwork bleShareOwnerAuthorizationsParams:params
                                             success:^(SOSAuthorInfo *authorInfo) {
                                                 if ([authorInfo.statusCode isEqualToString:@"0000"]) {
                                                     if ([[params objectForKey:@"authorizationType"] isEqualToString:@"TEMP"]) {
                                                         //临时 分享
                                                         [self toShareWithUrl:authorInfo.shareUrl];
                                                         !successBlock?:successBlock();
                                                     }else {
                                                         [self request];
                                                         //永久 跳转
                                                         [self toPermQrPageWithUrl:authorInfo.shareUrl];
                                                     }
                                                 }else {
                                                     [Util toastWithMessage:authorInfo.message];
                                                     //                                                     [SOSUtil showCustomAlertWithTitle:@"提示" message:authorInfo.message completeBlock:nil];
                                                     if ([authorInfo.statusCode isEqualToString:@"5020"]) {
                                                         [SOSDaapManager sendActionInfo:BLEOwner_Add_New_TempCarsharing_Send_fail_timeconflict];
                                                     }else if ([authorInfo.statusCode isEqualToString:@"5010"]) {
                                                         [SOSDaapManager sendActionInfo:BLEOwner_Add_New_TempCarsharing_Send_fail_over10];
                                                     }
                                                 }
                                             } Failed:^(NSString *responseStr, NSError *error) {
                                                 [Util toastWithMessage:[Util visibleErrorMessage:responseStr]];
                                                 //                                                  [SOSUtil showCustomAlertWithTitle:@"提示" message:[Util visibleErrorMessage:responseStr] completeBlock:nil];
                                             }];
}

- (void)toShareWithUrl:(NSString *)url
{
    WeiXinMessageInfo *messageInfo = [[WeiXinMessageInfo alloc] init];
    messageInfo.messageTitle = @"安吉星@车辆共享";
    messageInfo.messageDescription = @"您收到了一个来自好友的车辆蓝牙操控分享，请点击开启分享之旅。";
#ifdef SOSSDK_SDK
    url = [NSString stringWithFormat:@"%@&sc=%@",url,[SOSSDKKeyUtils bleSchemeUrl]];
#endif
    messageInfo.messageWebpageUrl = url;
    messageInfo.shareWechatRecordFunctionID = BLEOwner_Add_New_TempCarsharing_Send_Friend;//分享微信报告ID
    messageInfo.shareMomentsRecordFunctionID = BLEOwner_Add_New_TempCarsharing_Send_Friends;//分享朋友圈报告ID
    messageInfo.shareCancelRecordFunctionID = BLEOwner_Add_New_TempCarsharing_Send_fail;
    
    messageInfo.messageThumbImage = [UIImage imageNamed:@"pic_IMG_60x60"];
    [[NavigateShareTool sharedInstance] shareWithWeiXinMessageInfo:messageInfo];
}

- (void)toPermQrPageWithUrl:(NSString *)url {
    SOSBleQRViewController *qrVc = [[SOSBleQRViewController alloc] initWithNibName:@"SOSBleQRViewController" bundle:nil];
    qrVc.qrUrl = url;
    [self.navigationController pushViewController:qrVc animated:YES];
}

- (void)showDatePickerTarget:(UIButton *)button dateView:(SOSBleShareDateView *)dateV{
    PGDatePickManager *datePickManager = [[PGDatePickManager alloc] init];
    datePickManager.headerHeight = 50;
    datePickManager.cancelButtonTextColor = [UIColor colorWithHexString:@"107FE0"];
    datePickManager.confirmButtonTextColor = [UIColor colorWithHexString:@"107FE0"];
    PGDatePicker *datePicker = datePickManager.datePicker;
    datePicker.datePickerMode = button.tag < 3 ? PGDatePickerModeDate:PGDatePickerModeTime;
    if (button.tag == 1) {
        datePicker.minimumDate = [NSDate date];
        [datePicker setDate:dateV.startTime];
    }else if (button.tag == 2) {
        datePicker.minimumDate = dateV.startTime;
        [datePicker setDate:dateV.endTime];
    }else if (button.tag == 3) {
        if ([dateV.startTime isToday]) {
            datePicker.minimumDate = [NSDate date];
        }
        [datePicker setDate:dateV.startTime];
    }else if (button.tag == 4) {
        if ([dateV.startTime isSameDay:dateV.endTime]) {
            datePicker.minimumDate = dateV.startTime;
        }
        [datePicker setDate:dateV.endTime];
    }
    
    datePicker.textColorOfSelectedRow = [UIColor blackColor];
    datePicker.lineBackgroundColor = [UIColor lightGrayColor];
    datePicker.rowHeight = 44;
    datePicker.selectedDate = ^(NSDateComponents *dateComponents) {
        NSString *title = button.tag < 3 ? [NSString stringWithFormat:@"%ld/%02ld/%02ld",(long)dateComponents.year,(long)dateComponents.month,(long)dateComponents.day]:[NSString stringWithFormat:@"%02ld:%02ld",(long)dateComponents.hour,(long)dateComponents.minute];
        [button setTitle:title forState:UIControlStateNormal];
        [dateV equalStartTime];
    };
    [self presentViewController:datePickManager animated:false completion:nil];
}


- (void)gotoHistory {
    [SOSDaapManager sendActionInfo:BLEOwner_History];
    SOSOwnerHistorySharePageViewController *historyVc = [SOSOwnerHistorySharePageViewController new];
    historyVc.sourceTempData = self.historyTempDataArray;
    historyVc.sourcePermData = self.historyPermDataArray;
    historyVc.fromOwnerShare = YES;
    [self.navigationController pushViewController:historyVc animated:YES];
}

- (void)request {
    [[LoadingView sharedInstance] startIn:self.view];
    [SOSBleNetwork getOwnerAuthorizationsListSuccess:^(SOSAuthorInfo *authorInfo) {
        if ([authorInfo.statusCode isEqualToString:@"0000"]) {
            [self disposeDataWithResp:authorInfo];
        }else {
            [Util toastWithMessage:authorInfo.message];
        }
        [Util hideLoadView];
    } Failed:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];
    }];
}

//将数据源分三组 排序
- (void)disposeDataWithResp:(SOSAuthorInfo *)authorInfo {
    NSArray *dataArray = [SOSBleUtil disposeDataWithAuthorInfo:authorInfo];
    self.tempDataArray = dataArray[0];
    self.permDataArray = dataArray[1];
    self.historyTempDataArray = dataArray[2];
    self.historyPermDataArray = dataArray[3];
    //    [self configPage];
    
    tempShareVc.sourceData = self.tempDataArray;
    foreverShareVc.sourceData = self.permDataArray;
    tempShareVc.fromOwnerShare = YES;
    foreverShareVc.fromOwnerShare = YES;
    [tempShareVc.tableView reloadData];
    [foreverShareVc.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
