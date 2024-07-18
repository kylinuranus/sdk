//
//  SOSOperationHistoryViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSOperationHistoryViewController.h"
#import "SOSHistroyTableViewCell.h"
#import "LoadingView.h"

@interface SOSOperationHistoryViewController ()<ErrorBackDelegate>
{
    NSMutableArray *statusData;
}
@end

@implementation SOSOperationHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"车辆操作历史";
    self.tableView.tableFooterView = [UIView new];
    _tableView.backgroundColor = [SOSUtil onstarLightGray];
    _tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    statusData = [[NSMutableArray alloc] init];
    self.backRecordFunctionID = VEHICLEINFO_OPERATHISTORY_BACK;
    self.backDaapFunctionID = VEHICLEINFO_OPERATHISTORY_BACK;
    
    [self getRequestStatusesResult];
}

#pragma mark - 加载数据
- (void)getRequestStatusesResult{
//    [Util showLoadingView];
    [LoadingView.sharedInstance startIn:self.view];
    NSString *urlStr = [NSString stringWithFormat:ONSTAR_API_REMOTE_HISTORY, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    NSString *url = [ NSString stringWithFormat:@"%@%@",BASE_URL,urlStr];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        
        NSDictionary *responseDict = [Util dictionaryWithJsonString:returnData];
        NSString *error = [[[responseDict objectForKey:@"commandResponse"] objectForKey:@"body"] objectForKey:@"errorCode"];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LoadingView sharedInstance]stop];
                [self goErrorPage:NSLocalizedString(@"fail_recentOperation", nil)];
            });
            return ;
        }
        NSArray *array = [[responseDict objectForKey:@"commandResponses"] objectForKey:@"commandResponse"];
        NSString *requestStatus ;
        statusData = [[NSMutableArray alloc] init];
        int serviceResponseCount = 0;
        if (array && [array isKindOfClass:[NSArray class]]) {
            serviceResponseCount = (int)[array count];
        }
        for (int i = 0; i < serviceResponseCount; i++) {
            NSString *requestType = [[array objectAtIndex:i]objectForKey:@"type"];
            NSString *completeTime = [[array objectAtIndex:i]objectForKey:@"completionTime"];
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            
            requestStatus = [[array objectAtIndex:i]objectForKey:@"status"];//response.status;
            [tempDict setObject:requestStatus forKey:REMOTE_REQUEST_STATUS];
            [tempDict setObject:NONil(requestType) forKey:REMOTE_REQUEST_TYPE];
            [tempDict setObject:NONil(completeTime)  forKey:REMOTE_REQUEST_COMPLETE_TIME];
            [statusData addObject:tempDict];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(statusData.count == 0)	{
                [[LoadingView sharedInstance]stop];
                [self goErrorPage:NSLocalizedString(@"NO_recentOperation", nil)];
            }else{
                [[LoadingView sharedInstance]stop];
                [self.tableView reloadData];
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        if (![[dic objectForKey:@"error"] isKindOfClass:[NSDictionary class]]) {
            NSString *errorInfo = [dic objectForKey:@"error"];
            if ([errorInfo isEqualToString:@"invalid_token"])	return ;
            else	{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isFailPage = YES;
                    [[LoadingView sharedInstance] stop];
                    //显示失败页面
                    [self goErrorPage:NSLocalizedString(@"fail_recentOperation", nil)];
                });
            }
        }	else	[[LoadingView sharedInstance] stop];
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}

#pragma mark - 显示失败页面
- (void)goErrorPage:(NSString *)detail{
    ErrorPageVC *errorPage = [[ErrorPageVC alloc]initWithErrorPage:NSLocalizedString(@"recentStatusTitle", @"") imageName:@"NO_recentOperation" detail:detail];
    errorPage.delegate = self;
    [self.navigationController pushViewController:errorPage animated:YES];
}

#pragma mark - ErrorBackDelegate
- (void)errorPageBackTapped{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [statusData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];

    SOSHistroyTableViewCell *cell_status = [tableView dequeueReusableCellWithIdentifier:@"SOSHistroyTableViewCell"];
    if (!cell_status) {
        cell_status = [[NSBundle SOSBundle] loadNibNamed:@"SOSHistroyTableViewCell" owner:self options:nil][0];
        cell_status.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *tempType = [[statusData objectAtIndex:row] valueForKey:REMOTE_REQUEST_TYPE];
    NSMutableString *tempCompleteTime = [[NSMutableString alloc] initWithString:[[statusData objectAtIndex:row] valueForKey:REMOTE_REQUEST_COMPLETE_TIME]];
    NSInteger length = [tempCompleteTime length];
    
    if (length !=0 ) {
        [tempCompleteTime replaceCharactersInRange: NSMakeRange(23, length - 23) withString:@""];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:XML_DATE_FORMAT];
    
    NSDate *date = [Util convertGTM0ToGTM8WithDate:[df dateFromString:tempCompleteTime]];
    
    [df setDateFormat:DATE_YEAR];
    NSString *year = [df stringFromDate:date];
    [df setDateFormat:DATE_MONTH];
    NSString *month = [df stringFromDate:date];
    [df setDateFormat:DATE_DAY];
    NSString *day = [df stringFromDate:date];
    [df setDateFormat:DATE_HOUR];
    NSString *hour = [df stringFromDate:date];
    [df setDateFormat:DATE_MINUTE];
    NSString *minute = [df stringFromDate:date];
    [df setDateFormat:DATE_SECOND];
    NSString *second = [df stringFromDate:date];
    
    NSString *completTime = nil;
    
    NSString *currentLanguage = [SOSLanguage getCurrentLanguage];
    if ([currentLanguage isEqualToString:LANGUAGE_CHINESE])
        completTime = [NSString stringWithFormat:NSLocalizedString(@"remoteRecentHistoryDateFormat", @"") , year, month, day, hour, minute, second];
    else
        completTime = [NSString stringWithFormat:NSLocalizedString(@"remoteRecentHistoryDateFormat", @"") , month, day, year, hour, minute, second];
    
    // 正在执行
    if (length ==0 ) {
        completTime = @"";
    }
    
    NSString *labeleName = nil;
    NSString *imageName = nil;
    if ([tempType isEqualToString:@"lockDoor"]) {
        labeleName = NSLocalizedString(@"remoteLockButtonTitle", nil);
        imageName = @"lock_icon.png";
    } else if ([tempType isEqualToString:@"unlockDoor"]) {
        labeleName = NSLocalizedString(@"remoteUnlockButtonTitle", nil);
        imageName = @"unlock_icon.png";
    } else if ([tempType isEqualToString:@"start"]) {
        labeleName = NSLocalizedString(@"remoteRemoteStartButtonTitle", nil);
        imageName = @"qidong_icon.png";
    } else if ([tempType isEqualToString:@"cancelStart"]) {
        labeleName = NSLocalizedString(@"remoteRemoteStopButtonTitle", nil);
        imageName = @"xihuo_icon.png";
    } else if ([tempType isEqualToString:@"alert"]) {
        labeleName = NSLocalizedString(@"remoteVehicleAlertButtonTitle", nil);
        imageName = @"weizhi_icon.png";
    } else if ([tempType isEqualToString:@"chargeOverride"]) {
        labeleName = NSLocalizedString(@"chargeNavigateTitle", nil);
        imageName = @"phev_chargeMode.png";
    } else if ([tempType isEqualToString:@"location"]) {
        labeleName = NSLocalizedString(@"Remote_FMV", nil);
        imageName = @"vehicle_icon.png";
    } else if ([tempType isEqualToString:@"diagnostics"]) {
        labeleName = NSLocalizedString(@"Remote_DataRefresh", nil);
        imageName = @"refresh_icon.png";
    } else if ([tempType isEqualToString:@"sendTBTRoute"]) { // tbt
        labeleName = NSLocalizedString(@"navigateSearchResultDetailSendToCar", nil);
        imageName = @"rm_tbt.png";
    } else if ([tempType isEqualToString:@"sendNavDestination"]) { // odd
        labeleName = NSLocalizedString(@"navigateSearchResultDetailSendODD", nil);
        imageName = @"rm_odd.png";
    } else if([tempType isEqualToString:@"getChargingProfile"]) {//getChargingProfile
        labeleName = NSLocalizedString(@"ev_getMode", nil);
        imageName = @"phev_chargeMode.png";
    }else if([tempType isEqualToString:@"setChargingProfile"]) {//setChargingProfile
        labeleName = NSLocalizedString(@"ev_setMode", nil);
        imageName = @"phev_chargeMode.png";
    }else if([tempType isEqualToString:@"getCommuteSchedule"]) {//getCommuteSchedule
        labeleName = NSLocalizedString(@"ev_getSchedule", nil);
        imageName = @"PHEV_departTime.png";
    }else if([tempType isEqualToString:@"setCommuteSchedule"]) {//setCommuteSchedule
        labeleName = NSLocalizedString(@"ev_setSchedule", nil);
        imageName = @"PHEV_departTime.png";
    }else if([tempType isEqualToString:@"getHotspotInfo"]) {//get wifi
        labeleName = NSLocalizedString(@"wifi_get", nil);
        imageName = @"rm_wifi.png";
    }else if([tempType isEqualToString:@"getHotspotStatus"]) {//get wifi
        labeleName = NSLocalizedString(@"wifi_get", nil);
        imageName = @"rm_wifi.png";
    }else if([tempType isEqualToString:@"setHotspotInfo"]) {//set wifi
        labeleName = NSLocalizedString(@"wifi_set", nil);
        imageName = @"rm_wifi.png";
    }else if([tempType isEqualToString:@"enableHotspot"]) {//enable wifi
        labeleName = NSLocalizedString(@"wifi_enable", nil);
        imageName = @"rm_wifi.png";
    }else if([tempType isEqualToString:@"disableHotspot"]) {//disable wifi
        labeleName = NSLocalizedString(@"wifi_disable", nil);
        imageName = @"rm_wifi.png";
    }
    // 以下为ICM 2.0 新增操作
    else if([tempType.lowercaseString isEqualToString:@"sethvacsettings"]) {		// 设置空调
        labeleName = @"远程控制空调";
        imageName = @"rm_wifi.png";
    }	else if([tempType.lowercaseString isEqualToString:@"opentrunk"]) {			// 打开后备箱
        labeleName = @"打开后备箱";
        imageName = @"rm_wifi.png";
    }    else if([tempType.lowercaseString isEqualToString:@"closewindows"]) {		// 关闭车窗
        labeleName = @"关闭车窗";
        imageName = @"rm_wifi.png";
    }    else if([tempType.lowercaseString isEqualToString:@"openwindows"]) {		// 打开车窗
        labeleName = @"打开车窗";
        imageName = @"rm_wifi.png";
    }    else if([tempType.lowercaseString isEqualToString:@"closesunroof"]) {		// 关闭天窗
        labeleName = @"关闭天窗";
        imageName = @"rm_wifi.png";
    }    else if([tempType.lowercaseString isEqualToString:@"opensunroof"]) {		// 打开天窗
        labeleName = @"打开天窗";
        imageName = @"rm_wifi.png";
    }
    // My21
    else if ([tempType.lowercaseString isEqualToString:@"locktrunk"]) {
        labeleName = @"后备箱上锁";
    }else if ([tempType.lowercaseString isEqualToString:@"unlocktrunk"]) {
        labeleName = @"后备箱解锁";
    }
    else {
        labeleName = NSLocalizedString(@"未知操作（TODO）", nil);
        imageName = @"refresh_icon.png";
    }
    
    labeleName = [labeleName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    cell_status.detailTextLabel.text = completTime;
    cell_status.imageView.image = [UIImage imageNamed:imageName];
    cell_status.textLabel.text = labeleName;
    NSString *tempStatus = [[statusData objectAtIndex:row] valueForKey:REMOTE_REQUEST_STATUS];
    
    [cell_status.imageView setContentMode:UIViewContentModeScaleAspectFit];
    if ([tempStatus isEqualToString:SERVER_RESPONSE_SUCCESS]) {
        cell_status.imageView.image = [UIImage imageNamed:@"green_big"];
    }
    else if ([tempStatus isEqualToString:SERVER_RESPONSE_INPROGRESS]) {
        cell_status.imageView.image = [UIImage imageNamed:@"yellow_big"];
    }
    else if ([tempStatus isEqualToString:SERVER_RESPONSE_FAILURE]) {
        cell_status.imageView.image = [UIImage imageNamed:@"red_big"];
    }
    
    return cell_status;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
     *以下代码兼容IOS6-8
     *IOS7仅需要设置separatorInset为UIEdgeInsetsZero就可以让分割线顶头了
     *而IOS8需要将separatorInset设置为UIEdgeInsetsZero并且还需要将tabelView和tabelViewCell的layoutMargins设置为UIEdgeInsetsZero
     */
    UIEdgeInsets lineInsets = UIEdgeInsetsZero;
    //setSeparatorInset IOS7之后才支持
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:lineInsets];
    }
    
    //setLayoutMargins IOS8之后才支持
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:lineInsets];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:lineInsets];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
