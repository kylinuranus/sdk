//
//  RemoteControlAuthSettingViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/5/19.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "RemoteControlAuthSettingViewController.h"
#import "OthersUtil.h"
#import "UIImageView+WebCache.h"

@interface RemoteControlAuthSettingViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSArray *authTimes ;

}
@property (strong, nonatomic)IBOutlet UIView *toolView; // 工具条

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timePickerTopConstraint;
@end

@implementation RemoteControlAuthSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIPickerView appearance] setBackgroundColor:[UIColor whiteColor]];
    self.title = NSLocalizedString(@"Remote_Control_Auth_Setting", nil);
    
    authTimes = [NSArray arrayWithObjects:@"无限时",@"24小时",@"7天",@"30天", nil];//后端按照小时接受，所以要转换小时 = 0、24、7*24、30*24
    [self.authTimeSelectButton setTitle:[self authHourToString:_shareUser.limit] forState:UIControlStateNormal];

//    //计算picker显示
//    if (!_shareUser.authorizeStatus) {
//        //默认24小时
////        [self.authTimeSelectButton setTitle:@"无限时" forState:UIControlStateNormal];
//        [_timePicker selectRow:0 inComponent:0 animated:YES];
//    }
//    else
    {
        [_timePicker selectRow:[authTimes indexOfObject:[self authHourToString:_shareUser.limit]] inComponent:0 animated:YES];
    }
    if (_shareUser.faceUrl.length>0) {
        [self.authUserAvatar sd_setImageWithURL:[NSURL URLWithString:_shareUser.faceUrl] placeholderImage:[UIImage imageNamed:kDefault_Account_Avatar]];
    }
    self.backRecordFunctionID =Carshare_authorise_back;
    [SOSDaapManager sendActionInfo:Carshare_authorise_infor];
}

//取消选择时间
- (IBAction)cancleDateSelect:(id)sender {
    [self selectTimePicker:nil];
    [SOSDaapManager sendActionInfo:Carshare_authorise_time_cancel];
}
//确认选择时间
- (IBAction)confirmDateSelect:(id)sender {
    //设置界面时间
    [self.authTimeSelectButton setTitle:[self authHourToString:[self authTimeStringToHour:[_timePicker selectedRowInComponent:0]]] forState:UIControlStateNormal];
    [self selectTimePicker:nil];
    [SOSDaapManager sendActionInfo:Carshare_authorise_time_confirm];
}

- (IBAction)updateAuthTime
{
    [Util showLoadingView];
    RemoteControlSharePostUser * postUser =[RemoteControlSharePostUser mj_objectWithKeyValues:[_shareUser mj_keyValues]];
    if (!_shareUser.authorizeStatus) {
        [postUser setAuthorizeStatus:@"1"];//如果是未授权状态，需要设置为授权状态
    }
    [postUser setLimit:[self authTimeStringToHour:[_timePicker selectedRowInComponent:0]]];
    [OthersUtil setCarsharingAuthorzation:postUser SuccessHandler:^(NSString * responseStr,NNError *res) {
        //更新成功
        dispatch_async_on_main_queue(^{
            [Util hideLoadView];
            NSDictionary *d = [Util dictionaryWithJsonString:responseStr];
            if ([d[@"errorCode"] isEqualToString:@"E0000"]) {
                //更新列表，提示冲突话术
                [self.navigationController popViewControllerAnimated:YES];
                [SOSUtil showCustomAlertWithTitle:@"设置成功" message:@"多方同时操作可能导致功能失效，请尽量避免" completeBlock:^(NSInteger buttonIndex) {
                    [SOSDaapManager sendActionInfo:Carshare_authorise_time_Iknow];
                }];
            }
            else
            {
                [SOSUtil showCustomAlertWithTitle:@"提示" message:d[@"errorMsg"] completeBlock:nil];
            }
        });
       
        
    } failureHandler:^(NSString *responseStr, NNError *error) {
        [Util hideLoadView];
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];    //addByWQ 20180712 E9000错误不需要弹设置是失败
        if (responseStr) {
            if ([dic[@"code"] isEqualToString:@"E9000"]) {
                return ;
            }
        }
        [SOSUtil showCustomAlertWithTitle:@"提示" message:@"设置失败，请稍后再试" completeBlock:nil];
    }];
    [SOSDaapManager sendActionInfo:Carshare_authorise_time_Update];
}
- (IBAction)selectTimePicker:(id)sender {
//    self.timePicker.hidden = !self.timePicker.hidden;
    if (self.timePickerTopConstraint.constant == 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.timePickerTopConstraint.constant = - (self.timePicker.frame.size.height +44);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.timePickerTopConstraint.constant = 0;
        }];
    }
    [SOSDaapManager sendActionInfo:Carshare_authorise_time];
}

- (NSString *)authHourToString:(NSInteger)authHour
{
    switch (authHour) {
        case 0:
            return @"无限时";
            break;
        case 24:
            return @"24小时";
            break;
        case 168:
            return @"7天";
            break;
        case 720:
            return @"30天";
            break;
        default:
            return @"无限时";
            break;
    }
}
- (NSInteger)authTimeStringToHour:(NSInteger )index
{
//    NSInteger index = [authTimes indexOfObject:timeStr];
    switch (index) {
        case 0:
            return 0;
            break;
        case 1:
            return 24;
            break;
        case 2:
            return 168;
            break;
        case 3:
            return 720;
            break;
        default:
            return 0;
            break;
    }
}
- (void)configAuthUser:(SOSRemoteControlShareUser *)authUser
{
    _shareUser = authUser;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UIPickerViewDataSource
//返回显示的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
//显示每组键(列数)的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return authTimes.count;
}
#pragma mark UIPickerViewDelegate
////设置列高
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
//    return 44.0f;
//}

////被选中的第几列 的 第几行
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    if(component ==0){
//        //刷新对应列
//        [self.pickerView reloadComponent:1];
//        //当选择第一列时 第二列切到第一行
//        [self.pickerView selectRow:0 inComponent:component+1 animated:YES];
//    }
//}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
        return authTimes[row];

}

@end
