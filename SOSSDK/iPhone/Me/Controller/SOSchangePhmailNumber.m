//
//  SOSchangePhmailNumber.m
//  Onstar
//
//  Created by Genie Sun on 2017/3/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSchangePhmailNumber.h"
#import "SOSbeforeNumTableViewCell.h"
#import "SOSphoneTableViewCell.h"
#import "SOSmailTableViewCell.h"
#import "SOSwarningTableViewCell.h"
#import "SOSRemindSet.h"

static NSUInteger const kNumtextField = 1000;
static NSUInteger const kCodetextField = 1001;

@interface SOSchangePhmailNumber () <UITextFieldDelegate>
{
    BOOL isSendCheckOK;
    BOOL isExist;
    NSString *labelTipNew;
    NSString *labelTipCode;

    NSIndexPath *firsterrorPath;
    NSIndexPath *seconderrorPath;
    
    NSTimer *timerCheckCode;
    BOOL timeStart;
    
    UIButton *codeBtn;
    
}
@property (nonatomic, strong) UITextField *userTf;
@property (nonatomic, strong) UITextField *codeTf;

@property(nonatomic, assign) NSUInteger index;
@end

@implementation SOSchangePhmailNumber

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.table.tableFooterView = [UIView new];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;

    switch (self.pagetype) {
        case changephoneNb:
            self.title = @"提醒手机号设置";
//            self.backRecordFunctionID = MobileSetting_ClickBack;
            self.backRecordFunctionID = NS_notification_mobile_back;
            self.tipLb.text = @" *提醒手机号是用于各类安全提醒设置，可以与账户绑定的手机号不一样";
            self.oldInfo = self.notObject.phone;
            break;
        case changemailNb:
            self.title = @"提醒邮箱设置";
//            self.backRecordFunctionID = EmailSetting_ClickBack;
            self.backRecordFunctionID = NS_notification_email_back;
            self.tipLb.text = @" *提醒邮箱是用于各类安全提醒设置，可以与账户绑定的邮箱不一样";
            self.oldInfo = self.notObject.mail;
            break;
        default:
            break;
    }
    
    if (self.info) {
        self.index = 0;
    }else{
        self.index = 1;
        self.tableheight.constant = 210.f;
        [self.view layoutIfNeeded];
    }
    
    //不加会崩溃
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RAC(self.submitBtn, enabled) = [RACSignal
                                        combineLatest:@[
                                                        self.userTf.rac_textSignal,
                                                        self.codeTf.rac_textSignal,
                                                        ] reduce:^(NSString *user, NSString *code) {
                                                            return @(user.stringByTrim.length > 0 && code.stringByTrim.length > 0);
                                                        }];
    });
    
    self.submitBtn.enabled = NO;
    [self.submitBtn setBackgroundColor:[SOSUtil onstarButtonDisableColor] forState:UIControlStateDisabled];
    [self.submitBtn setBackgroundColor:[SOSUtil onstarButtonEnableColor] forState:UIControlStateNormal];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SOSDaapManager sendActionInfo:self.backRecordFunctionID];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.info ? 6 : 5 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && self.info) {
        return 40.f;
    }else if (indexPath.row == 1 - self.index || indexPath.row == 3 - self.index || indexPath.row == 5 - self.index)
    {
        return 30.f;
    }else if (indexPath.row == 2 - self.index || indexPath.row == 4 - self.index){
        return 44.f;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && self.info) {
        static NSString *identifier = @"cell";
        SOSbeforeNumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle SOSBundle] loadNibNamed:@"SOSbeforeNumTableViewCell" owner:self options:nil][0];
        }

        cell.beforeLb.text = self.pagetype==changephoneNb?@"原手机号:":@"原邮箱:";
        cell.lb_phone.text = [self.info substringFromIndex:5];
        return cell;
    }else if (indexPath.row == 3 - self.index || indexPath.row == 5 - self.index){
        static NSString *identifier = @"cell";
        SOSwarningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle SOSBundle] loadNibNamed:@"SOSwarningTableViewCell" owner:self options:nil][0];
        }
        if (indexPath.row > 3) {
            seconderrorPath = indexPath;
            if (![labelTipCode isEqualToString:@""] && labelTipNew) {
                cell.warnLb.hidden = NO;
                cell.warnImage.hidden = NO;
                cell.warnLb.text = labelTipCode;
            }else{
                cell.warnLb.hidden = YES;
                cell.warnImage.hidden = YES;
            }
        } else {
            firsterrorPath = indexPath;
            if (![labelTipNew isEqualToString:@""] && labelTipNew) {
                cell.warnLb.hidden = NO;
                cell.warnImage.hidden = NO;
                cell.warnLb.text = labelTipNew;
            }else{
                cell.warnLb.hidden = YES;
                cell.warnImage.hidden = YES;
            }
        }
        
        return cell;

    }else if (indexPath.row == 1 - self.index)
    {
        static NSString *identifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 2 - self.index){
        static NSString *identifier = @"cell";
        SOSphoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle SOSBundle] loadNibNamed:@"SOSphoneTableViewCell" owner:self options:nil][0];
        }
        if (self.pagetype == changephoneNb) {
            cell.userIcon.image = [UIImage imageNamed:@"手机-短信icon"];
            cell.usertf.placeholder = @"请输入新手机号";
        }else if (self.pagetype == changemailNb){
            cell.userIcon.image = [UIImage imageNamed:@"邮箱icon"];
            cell.usertf.placeholder = @"请输入新邮箱";
            cell.usericonheight.constant = 12;
            cell.usericonwidth.constant = 16;
            cell.iconright.constant = 14;
            cell.userTfLeft.constant = 14;
            [cell layoutIfNeeded];
        }
        firsterrorPath = indexPath;
        self.userTf = cell.usertf;
        cell.usertf.delegate = self;
        cell.usertf.tag = kNumtextField;
        return cell;

    }else if (indexPath.row == 4 - self.index){
        static NSString *identifier = @"cell";
        SOSmailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle SOSBundle] loadNibNamed:@"SOSmailTableViewCell" owner:self options:nil][0];
        }
        cell.codeTf.tag = kCodetextField;
        [cell sendCodeBtn:^(UIButton *sendBtn) {
            [self sendCheck];
        }];
        codeBtn = cell.codeBtn;
        self.codeTf = cell.codeTf;
        seconderrorPath = indexPath;
        cell.codeTf.delegate = self;

        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (IBAction)submit:(id)sender {
    [self checkUserTfinfo:self.userTf];
    
    [self checkCodeTfInfo:self.codeTf];
    [self checkValidationCode];
}

///验证验证码
- (void)checkValidationCode {
    NSString *newInfo = [Util trim:self.userTf];
    NSString *validateCode = [Util trim:self.codeTf];
    if ([Util isBlankString:newInfo] || [Util isBlankString:validateCode]) {
        return;
    }
    labelTipNew = @"";
    [self.table reloadRowsAtIndexPaths:@[firsterrorPath] withRowAnimation:UITableViewRowAnimationTop];
    labelTipCode = @"";
    [self.table reloadRowsAtIndexPaths:@[seconderrorPath] withRowAnimation:UITableViewRowAnimationTop];

    [Util showLoadingView];
    [SOSRemindSet sendNOtifyCodewithSubscriberId:[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId
                                          userTf:newInfo
                                      pageNumber:self.pagetype
                                         secCode:validateCode
                                         Success:^(NNErrorDetail *error) {
                                              [Util hideLoadView];
                                             if ([error.code isEqualToString:@"E0000"]) {
                                                 [self updateUserInfo];
                                             }
                                             else{
                                                 [Util toastWithMessage:error.msg];
                                             }
                                         } Failed:^{
                                             [Util hideLoadView];
                                         }];
}

///更新手机号或者邮箱
- (void)updateUserInfo {
    
    NNNotifyConfigRequest *request = [[NNNotifyConfigRequest alloc] init];
    if (self.pagetype == changephoneNb) {
        [request setPhone:[Util trim:self.userTf]];
        [request setMail:self.notObject.mail];
        //[[SOSReportService shareInstance] recordActionWithFunctionID:MobileSetting_ClickSave];
        [SOSDaapManager sendActionInfo:NS_notification_mobile_save];

    }else if (self.pagetype == changemailNb){
        [request setPhone:self.notObject.phone];
        [request setMail:[Util trim:self.userTf]];
        //[[SOSReportService shareInstance] recordActionWithFunctionID:EmailSetting_ClickSave];
        [SOSDaapManager sendActionInfo:NS_notification_email_save];
    }
    [request setBtype:@"TAN"];
    [request setVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    [request setWechat_checked:self.notObject.wechat_checked];
    [request setMobile_checked:self.notObject.mobile_checked];
    [request setSubscriber_id:[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId];
    [request setSms_checked:self.notObject.sms_checked];
    [request setMail_checked:self.notObject.mail_checked];
    [request setOldphone:self.notObject.oldphone];
    [request setIscall:self.notObject.iscall];
    
    [SOSRemindSet notigyConfigInformation:@"PUT"
                                     body:[request mj_JSONString]
                                    btype:nil
                                  Success:^(NNNotifyConfig *notify) {
                                      [Util toastWithMessage:@"更新成功！"];
                                      if (self.pagetype == changephoneNb) {
              
                                          [SOSDaapManager sendActionInfo:NS_notification_mobile_save_success];
                                          
                                      }else if (self.pagetype == changemailNb){
             
                                          [SOSDaapManager sendActionInfo:NS_notification_email_save_success];
                                      }
                                      dispatch_async(dispatch_get_main_queue(), ^{
//                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"needRe-load" object:nil];
                                          [self.navigationController popViewControllerAnimated:YES];
                                      });
                                      
                                  } Failed:^{
                                  }];
}

- (void)sendCheck
{

    if (self.pagetype == changephoneNb) {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:MobileSetting_GetVerificationCode];
        [SOSDaapManager sendActionInfo:NS_notification_mobile_verifycode];

    } else {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:EmailSetting_GetVerificationCode];
        [SOSDaapManager sendActionInfo:NS_notification_email_verifycode];
    }
    
    [self checkUserTfinfo:self.userTf];
    labelTipNew = @"";

    if(isSendCheckOK)
    {
        [self sendValidationCode];
    }
}

/// 发送验证码
- (void)sendValidationCode {
    NSString *newUserTf = [Util trim:self.userTf];

    labelTipNew = @"";
    [self.table reloadRowsAtIndexPaths:@[firsterrorPath] withRowAnimation:UITableViewRowAnimationTop];
    [Util showLoadingView];
    [SOSRemindSet sendNOtifyCodewithSubscriberId:[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId
                                          userTf:newUserTf
                                      pageNumber:self.pagetype
                                         secCode:nil
                                         Success:^(NNErrorDetail *error) {
                                             [Util hideLoadView];
                                             if ([error.code isEqualToString:@"E0000"]) {
//                                                 [Util toastWithMessage:@"验证码发送成功！"];
                                                 timeStart = YES;
                                                 if (timerCheckCode) {
                                                     [timerCheckCode invalidate];
                                                     timerCheckCode = Nil;
                                                 }
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     timerCheckCode = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
                                                 });
                                             }else{
                                                 [Util toastWithMessage:error.msg];
                                             }

                                         } Failed:^{
                                             [Util toastWithMessage:@"验证码发送失败"];
                                         }];
}

#pragma mark - UITextFieldDelegate delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag == kNumtextField)
    {
        [self.view endEditing:YES];
    }
    else if(textField.tag == kCodetextField)
    {
        [self submit:nil];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField     {
    
    if (textField.tag == kNumtextField) {
        [self checkUserTfinfo:textField];
    }
    else if (textField.tag == kCodetextField)
    {
        [self checkCodeTfInfo:textField];
    }
    else{
        [textField resignFirstResponder];
    }
}

- (void)checkUserTfinfo:(UITextField*) textField {

    if ([[Util trim:textField] length] < 1) {
        labelTipNew =NSLocalizedString(@"NullField", @"");
        isSendCheckOK = NO;
        [self.table reloadRowsAtIndexPaths:@[firsterrorPath] withRowAnimation:UITableViewRowAnimationTop];
        return;
    }else{

        BOOL showAlert = [Util isValidatePhone:[Util trim:textField]];

        if (self.pagetype == changephoneNb) {
            labelTipNew = NSLocalizedString(@"SB022_MSG006", @"");
        } else if (self.pagetype == changemailNb){
            labelTipNew = NSLocalizedString(@"SB022_MSG007", @"");
            showAlert = [Util isValidateEmail:[Util trim:textField]];
        }
        
        if(!showAlert)
        {
            isSendCheckOK = NO;
            [self.table reloadRowsAtIndexPaths:@[firsterrorPath] withRowAnimation:UITableViewRowAnimationTop];
            return;
        }
        if(self.info){
            if([[Util trim:textField] isEqualToString:self.oldInfo]){
                if (self.pagetype == changephoneNb) {
                    labelTipNew = NSLocalizedString(@"mobile_same", @"");
                } else if (self.pagetype == changemailNb){
                    labelTipNew = NSLocalizedString(@"email_same", @"");
                }

                isSendCheckOK = NO;
                [self.table reloadRowsAtIndexPaths:@[firsterrorPath] withRowAnimation:UITableViewRowAnimationTop];
                return;
            }
        }
    }
    labelTipNew = @"";
    [self.table reloadRowsAtIndexPaths:@[firsterrorPath] withRowAnimation:UITableViewRowAnimationTop];
    isSendCheckOK = YES;
}

- (void)checkCodeTfInfo:(UITextField *) textField{
    if ([[Util trim:textField] length] < 1) {
        labelTipCode =NSLocalizedString(@"NullField", @"");
        [self.table reloadRowsAtIndexPaths:@[seconderrorPath] withRowAnimation:UITableViewRowAnimationTop];
        return;
    }else{
        labelTipCode = @"";
        [self.table reloadRowsAtIndexPaths:@[seconderrorPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string     {
    if (range.location >= 30)
        return NO; // return NO to not change text
    return YES;
}

- (void)timerFireMethod:(NSTimer *)theTimer     {
    NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    NSDateComponents *endTime = [[NSDateComponents alloc] init];    //初始化目标时间...
    NSDate *today = [NSDate date];    //得到当前时间
    
    NSDate *date = [NSDate dateWithTimeInterval:60 sinceDate:today];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    static int year;
    static int month;
    static int day;
    static int hour;
    static int minute;
    static int second;
    if(timeStart) {//从NSDate中取出年月日，时分秒，但是只能取一次
        year = [[dateString substringWithRange:NSMakeRange(0, 4)] intValue];
        month = [[dateString substringWithRange:NSMakeRange(5, 2)] intValue];
        day = [[dateString substringWithRange:NSMakeRange(8, 2)] intValue];
        hour = [[dateString substringWithRange:NSMakeRange(11, 2)] intValue];
        minute = [[dateString substringWithRange:NSMakeRange(14, 2)] intValue];
        second = [[dateString substringWithRange:NSMakeRange(17, 2)] intValue];  //2016-1-4验证码
        timeStart= NO;
    }
    
    [endTime setYear:year];
    [endTime setMonth:month];
    [endTime setDay:day];
    [endTime setHour:hour];
    [endTime setMinute:minute];
    [endTime setSecond:second];
    NSDate *todate = [cal dateFromComponents:endTime]; //把目标时间装载入date
    
    //用来得到具体的时差，是为了统一成北京时间
    unsigned int unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth| NSCalendarUnitDay| NSCalendarUnitHour| NSCalendarUnitMinute| NSCalendarUnitSecond;
    NSDateComponents *d = [cal components:unitFlags fromDate:today toDate:todate options:0];
    NSString *fen = [NSString stringWithFormat:@"%ld", (long)[d minute]];
    if([d minute] < 10) {
        fen = [NSString stringWithFormat:@"0%ld",(long)[d minute]];
    }
    NSString *miao = [NSString stringWithFormat:@"%ld", (long)[d second]];
    if([d second] < 10) {
        miao = [NSString stringWithFormat:@"0%ld",(long)[d second]];
    }
    
    if([d second] > 0) {
        [codeBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",NSLocalizedString(@"Resend", nil),(long)[d second]] forState:0];

        self.userTf.enabled = NO;
        codeBtn.enabled = NO;
        codeBtn.userInteractionEnabled = NO;
        //计时尚未结束，do_something
        
    } else if([d second] == 0) {
        [codeBtn setTitle:NSLocalizedString(@"Resend", nil) forState:0];
        //计时1分钟结束，do_something
        self.userTf.enabled = NO;
        codeBtn.userInteractionEnabled = YES;
        codeBtn.enabled = YES;
        
    } else{
        [theTimer invalidate];
        [timerCheckCode invalidate];
        timerCheckCode = Nil;
    }
}
@end
