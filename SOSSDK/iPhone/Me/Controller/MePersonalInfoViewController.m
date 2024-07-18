//
//  MePersonalInfoViewController.m
//  Onstar
//
//  Created by Apple on 16/6/24.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "MePersonalInfoViewController.h"
#import "ViewControllerFingerprintpw.h"
#import "SOSCardUtil.h"
#import "ChangePasswordViewController.h"
#import "CustomerInfo.h"
#import "ChangeEmailViewController.h"
#import "ChangeMobileViewController.h"
#import "SOSCheckRoleUtil.h"
#import "LoadingView.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "MePersonalInfoViewCell.h"
#import "AccountInfoUtil.h"
#import "CustomCover.h"
#import "NSString+JWT.h"
#import "PushNotificationManager.h"
#import "SOSPersonalInfomationViewController.h"
#import "SOSNickNameViewController.h"
#import "SOSVisitorPersonalHeader.h"
#import "OwnerViewController.h"
#import "TLSOSEditPasswordViewController.h"
#import "SOSBiometricsManager.h"
#import "NSString+SOSCategory.h"
#import "SOSVerifyPersonInfoView.h"

@interface MePersonalInfoItem : NSObject
@property (nonatomic ,copy)NSString * itemDescription;
@property (nonatomic ,assign)NSInteger index;
- (instancetype)initWithItemDesc:(NSString *)itemDesc index:(NSInteger )index_;
@end
@implementation MePersonalInfoItem
- (instancetype)initWithItemDesc:(NSString *)itemDesc index:(NSInteger )index_
{
    if (self = [super init]) {
        _itemDescription = itemDesc;
        _index = index_;
    }
    return self;
}
@end

@interface MePersonalInfoViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>     {
    BOOL hasBindWechat;
    NSMutableArray * functionArray;
}
@property (nonatomic, strong) CustomCover *cover;
@property (nonatomic ,copy)NSString * verifyTip;

@end

@implementation MePersonalInfoViewController

- (void)viewDidLoad     {
    [super viewDidLoad];
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    self.title = @"个人信息";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupTableView];
    functionArray = [NSMutableArray array];
    
    [self getSubscriberInfo];
    [self queryUserBindWechatState];
}

- (void)setupTableView      {
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.rowHeight = 54;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MePersonalInfoViewCell class]) bundle:nil] forCellReuseIdentifier:@"cellID"];
    //非车主增加升级车主header
    if ([SOSCheckRoleUtil isVisitor]) {
        SOSVisitorPersonalHeader * vHeader = [SOSVisitorPersonalHeader viewFromXib];
        [vHeader.upgradeButton addTarget:self action:@selector(upgradeSubscriber) forControlEvents:UIControlEventTouchUpInside];
        self.tableView.tableHeaderView = vHeader;
        [vHeader mas_makeConstraints:^(MASConstraintMaker *make){
            make.width.mas_equalTo(self.view.frame.size.width);
            make.height.mas_equalTo(115);
        }];
    }
}
- (void)upgradeSubscriber
{
    OwnerViewController * scanVIN = [[OwnerViewController alloc] initWithNibName:@"OwnerViewController" bundle:nil];
    [SOSRegisterInformation sharedRegisterInfoSingleton].registerWay = SOSRegisterWayAddVehicle;
    [self.navigationController pushViewController:scanVIN animated:YES];
}
- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    _mobilePhoneNumber = [CustomerInfo sharedInstance].changePhoneNo;
    _emailAddress = [CustomerInfo sharedInstance].changeEmailNo;
    
    //增加实名认证入口
    @weakify(self);
    [AccountInfoUtil cheeckNeedVerifyPersionInfoBlock:^(bool needVerify,NSString *verUrl, NSString *verifyTip) {
        if (needVerify) {
            @strongify(self);
                    SOSVerifyPersonInfoView *view = [[NSBundle SOSBundle] loadNibNamed:@"SOSVerifyPersonInfoView" owner:self options:nil][0];
                    view.verifyTip = verifyTip;
            self.verifyTip = verifyTip;
                    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
                    view.verURI = verUrl;
                    view.verifyTip = verifyTip;
                    view.pageType = SOSVerifyTypePersonInfo;
                    self.tableView.tableHeaderView = view;
                    view.nav = self.navigationController;
                
        }
    }];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MePersonalInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
//    cell.viewCtrl = self;
    MePersonalInfoItem * item = functionArray[indexPath.section][indexPath.row];
    cell.leftLabel.text = item.itemDescription;
    cell.rightTrailingConstraint.constant = 37;

    switch (item.index) {
        case 0:
        {
            cell.rightLabel.hidden = YES;
            cell.arrowImgV.hidden = NO;
            cell.photoBtn.hidden = NO;
            cell.bottomLineView.hidden = NO;
        }
            break;
        case 1:
        {
            cell.rightLabel.text = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
            cell.rightLabel.hidden = NO;
            cell.arrowImgV.hidden = YES;
            cell.photoBtn.hidden = YES;
            cell.bottomLineView.hidden = NO;
            cell.rightTrailingConstraint.constant = 15;
        }
            break;
        case 2:
        {
            cell.rightLabel.text = [CustomerInfo sharedInstance].tokenBasicInfo.nickName.isNotBlank ? [NSString maskNickName:[CustomerInfo sharedInstance].tokenBasicInfo.nickName] :@"无";
            cell.rightLabel.hidden = NO;
            cell.arrowImgV.hidden = NO;
            cell.photoBtn.hidden = YES;
            cell.bottomLineView.hidden = NO;
        }
            break;
        case 7:
        {
            cell.rightLabel.text = @"解绑";
            [cell.rightLabel setTextColor:[UIColor sos_ColorWithHexString:@"6896ED"]];
            cell.rightLabel.hidden = NO;
            cell.arrowImgV.hidden = YES;
            cell.photoBtn.hidden = YES;
            cell.bottomLineView.hidden = NO;
        }
            break;
            
        default:
        {
            cell.rightLabel.hidden = YES;
            cell.arrowImgV.hidden = NO;
            cell.photoBtn.hidden = YES;
            cell.bottomLineView.hidden = NO;
        }
            break;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MePersonalInfoItem * item = functionArray[indexPath.section][indexPath.row];
    
    switch (item.index) {
        case 0:
        {
            [SOSDaapManager sendActionInfo:Profile_portrait];

            MePersonalInfoViewCell *cell  = (MePersonalInfoViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell userImageClicked];
        }
            break;
        case 2:
        {
            [SOSDaapManager sendActionInfo:Profile_nickname];
            MePersonalInfoViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            SOSNickNameViewController * nick = [[SOSNickNameViewController alloc] initWithNibName:@"SOSNickNameViewController" bundle:nil];
            [nick setUpdateBlock:^(NSString * newNickName){
                cell.rightLabel.text= newNickName;
            }];
            [self.navigationController pushViewController:nick animated:YES];
        }
            break;
        case 3:
        {
            ChangeEmailViewController *changeEmail = [[ChangeEmailViewController alloc]initWithNibName:@"ChangeEmailViewController" bundle:nil];
            changeEmail.oldEmail = _emailAddress;
            [self.navigationController pushViewController:changeEmail animated:YES];
        }
            break;
        case 4:
        {
            [SOSDaapManager sendActionInfo:Profile_password];
            TLSOSEditPasswordViewController *vc = [TLSOSEditPasswordViewController new];
            vc.backRecordFunctionID = Password_back;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:
        {
            [SOSDaapManager sendActionInfo:Profile_fingerprint];
            UIStoryboard *fingerPwStoryboard = [UIStoryboard storyboardWithName:[Util getPersonalcenterStoryBoard] bundle:nil];
            ViewControllerFingerprintpw *fingerPrint = [fingerPwStoryboard instantiateViewControllerWithIdentifier:@"ViewControllerFingerprintpw"];
            [self.navigationController pushViewController:fingerPrint animated:YES];
        }
            break;
        case 6:
            //星用户信息
        {
            [self willRouteToPersonInfoVc];
        }
            break;
        case 7:
            //解绑
        {
            [Util showAlertWithTitle:@"解除与微信的绑定吗?" message:nil completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex ==1) {
                    [AccountInfoUtil unBindUserWechatHandler:^(BOOL unBindResult) {
                        if (unBindResult) {
                            [Util toastWithMessage:@"解绑成功"];
                            //更新界面
                            if (functionArray.count == 4) {
                                [tableView beginUpdates];
                                [functionArray removeObjectAtIndex:3];
                                [tableView deleteSection:3 withRowAnimation:(UITableViewRowAnimationAutomatic)];
                                 [tableView endUpdates];
                            }
                        }else{
                            [Util toastWithMessage:@"解绑失败"];
                        }
                    }];
                }
            } cancleButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        }
            break;
        default:
            break;
    }
}

- (void)willRouteToPersonInfoVc {
   
        if ([SOSCheckRoleUtil isOwner]) {
            if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.isDefaultPin) {
                //是初始pin码
                //弹出pin完善页面
                [SOSCardUtil routerToPinModificationWithDismissBlock:^{
                                        [self routeToPersonInfoVc];
                                    }];

            }else{
                [self routeToPersonInfoVc];
            }
        }
    else {
        [self routeToPersonInfoVc];
    }
    
}
- (void)routeToPersonInfoVc {
    [SOSDaapManager sendActionInfo:Psn_BBWC];
    
    SOSPersonalInfomationViewController *changeInfoVc = [[SOSPersonalInfomationViewController alloc] init];
    changeInfoVc.verifyTip = self.verifyTip;
    changeInfoVc.backToMain = ^{   //星用户信息种如果更改了手机号且合并成功后，需要退回首页再跳登录页
        [self.navigationController popToRootViewControllerAnimated:NO];
        [[LoginManage sharedInstance] presentLoginNavgationController:[SOS_APP_DELEGATE fetchMainNavigationController]];
    };
    CustomNavigationController *nav = [[CustomNavigationController alloc] initWithRootViewController:changeInfoVc];
    [self presentViewController:nav animated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView	{
    return functionArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section	{
//    BOOL shouldShowHeader = !(section == 0 && [SOSUtil shouldShowVerifyPersonInfo]);
//    return shouldShowHeader ? 20.0f : 0;
    BOOL shouldShowHeader = !(section == 0);
       return shouldShowHeader ? 20.0f : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section	{
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath	{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 75.0f;
    }	 else		return 45.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section     {
    
    return  ((NSArray *)(functionArray[section])).count;
}
-(void)generateTableSource{
    //头像
    MePersonalInfoItem * itemHead_photos= [[MePersonalInfoItem alloc] initWithItemDesc:NSLocalizedString(@"Head_photos", nil) index:0];
    //用户名
    MePersonalInfoItem * itemAccount= [[MePersonalInfoItem alloc] initWithItemDesc:NSLocalizedString(@"Account", nil) index:1];
    //昵称
    MePersonalInfoItem * itemNick= [[MePersonalInfoItem alloc] initWithItemDesc:NSLocalizedString(@"Me_NickName", nil) index:2];
    NSArray *avatarArr = @[itemHead_photos,itemAccount,itemNick];
    [functionArray addObject:avatarArr];
    //密码
    MePersonalInfoItem * itemChange_Password= [[MePersonalInfoItem alloc] initWithItemDesc:NSLocalizedString(@"Change_Password", nil) index:4];
    //生物密码
    
    MePersonalInfoItem * itemFingerprint_Password= [[MePersonalInfoItem alloc] initWithItemDesc:@"指纹密码" index:5];
    NSArray *passwordArr;
    if (![SOSBiometricsManager isSupportBiometrics] || ![SOSCheckRoleUtil isOwner]) {
        passwordArr = @[itemChange_Password];
    }
    else {
        if ([SOSBiometricsManager isSupportFaceId]) {
            itemFingerprint_Password.itemDescription = @"面容 ID 解锁";
        }
        passwordArr = @[itemChange_Password, itemFingerprint_Password];
    }
    [functionArray addObject:passwordArr];
    
    MePersonalInfoItem * itemContact_Address= [[MePersonalInfoItem alloc] initWithItemDesc:@"星用户信息" index:6];
    NSArray *infomationArr = @[itemContact_Address];
    [functionArray addObject:infomationArr];
    
    if (hasBindWechat) {
        [self addWechatTableSource];
    }
}
-(void)addWechatTableSource{
    
    if (functionArray.count >1) {
        MePersonalInfoItem * itemWechat_unBind= [[MePersonalInfoItem alloc] initWithItemDesc:@"微信账号" index:7];
        NSArray *infomationArr = @[itemWechat_unBind];
        [functionArray addObject:infomationArr];
    }
}
- (void)getSubscriberInfo     {
    [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
    [AccountInfoUtil getAccountInfo:YES Success:^(NNExtendedSubscriber *subscriber) {
         [Util hideLoadView];
        _mobilePhoneNumber = subscriber.mobile;
        _emailAddress = subscriber.email;
        
        [CustomerInfo sharedInstance].changePhoneNo = subscriber.mobile;
        [CustomerInfo sharedInstance].changeEmailNo = subscriber.email;
        [CustomerInfo sharedInstance].licenseExpireDate = subscriber.licenseExpireDate;
        //TODO 7.3
//        [CustomerInfo sharedInstance].accountNumber = subscriber.accountNumber;
        [CustomerInfo sharedInstance].province= subscriber.province;
        [CustomerInfo sharedInstance].city= subscriber.city;
        [CustomerInfo sharedInstance].address1= subscriber.address;
        [CustomerInfo sharedInstance].address2= subscriber.address;
        [CustomerInfo sharedInstance].zip= subscriber.zip;
        [self generateTableSource];
        [self.tableView reloadData];
    } Failed:^{
        [Util hideLoadView];
    }];
}

-(void)queryUserBindWechatState{
    [AccountInfoUtil queryUserWechatBindStatusHandler:^(BOOL hasBind) {
        if (hasBind) {
            hasBindWechat = YES;
            [self addWechatTableSource];
            [self.tableView reloadData];
        }
    }];
}

@end
