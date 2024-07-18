//
//  VersionManager.m
//  Onstar
//
//  Created by Apple on 16/12/13.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "VersionManager.h"
#import "UITableView+FDTemplateLayoutCell.h"
#if __has_include("SOSSDK.h")
#import "SOSSDK.h"
#endif
#import "SOSFlexibleAlertController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface SOSUpgradeDetailCell :UITableViewCell{
    
}
@property(nonatomic,strong) UILabel *label;
@property(nonatomic,copy)NSString * entity;
@end
@implementation SOSUpgradeDetailCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *dot = [[UIView alloc] init];
        dot.layer.backgroundColor = [UIColor colorWithRed:104/255.0 green:150/255.0 blue:237/255.0 alpha:1.0].CGColor;
        dot.layer.cornerRadius=3;
        [self.contentView addSubview:dot];
        [dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.width.height.mas_equalTo(6);
            make.left.mas_equalTo(self.contentView).offset(10);
        }];
        
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
        _label.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_label];
        
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(dot.mas_right).mas_offset(16);
            make.right.mas_equalTo(self.contentView);
            make.top.bottom.mas_equalTo(self.contentView);
        }];
        
    }
    
    return self;
    
}
-(void)setEntity:(NSString *)entity{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[entity stringByTrim] attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size: 12],NSForegroundColorAttributeName: [UIColor colorWithRed:130/255.0 green:131/255.0 blue:137/255.0 alpha:1.0]}];
    self.label.attributedText = string;

}
@end

@implementation SOSUpgradeDetailView
-(void)addDetailTips:(NSArray *)tips leftOffset:(CGFloat)loff{
    //    self.backgroundColor = [UIColor brownColor];
    UITableView * table = [[UITableView alloc] init];
    table.delegate = self ;
    table.dataSource = self;
    table.alwaysBounceVertical = NO;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [table registerClass:[SOSUpgradeDetailCell class] forCellReuseIdentifier:@"SOSUpgradeDetailCell"];
    [self addSubview:table];
    
    [table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(loff);
        make.top.bottom.mas_equalTo(self).mas_offset(10);
        make.right.mas_equalTo(self);
    }];
    
    self.tipsArray = tips;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:@"SOSUpgradeDetailCell" configuration:^(id cell) {
        
        ((SOSUpgradeDetailCell *)cell).entity = self.tipsArray[indexPath.row];
    }];
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SOSUpgradeDetailCell * cell =[tableView dequeueReusableCellWithIdentifier:@"SOSUpgradeDetailCell"];
    ((SOSUpgradeDetailCell *)cell).entity = self.tipsArray[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.tipsArray.count;
}

@end
@interface VersionManager()<UIAlertViewDelegate>

@end

@implementation VersionManager

+ (id)sharedInstance	{
    static VersionManager *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [self new];
    });
    return sharedOBJ;
}

- (void)checkNewVersion		{
    // One App
    if (SOS_ONSTAR_PRODUCT) {
        [self checkMustUpgrade];
//        [self checkPrepaymentAvailable];
    }
}
/**
 检查是否需要强制升级
 */
- (void)checkMustUpgrade	{
    
    NSString *url = [NSString stringWithFormat:(@"%@" MA82_API_Check_APPVersion), BASE_URL,APP_VERSION];
    @weakify(self);
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        @strongify(self);
        self.checkVersionResp = [SOSCheckAppVersionResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        if (self.checkVersionResp) {
            //有新版本需要升级
            if (self.checkVersionResp.update) {
                //需要强制升级
                if ([self.checkVersionResp.force isEqualToString:@"force"]) {
                    SOSUpgradeDetailView * te = [[SOSUpgradeDetailView alloc] initWithFrame:CGRectMake(0, 0, SCALE_WIDTH(150), SCALE_WIDTH(100))];
                    [te addDetailTips:[self.checkVersionResp.updateNote componentsSeparatedByString:@"|"] leftOffset:40];
                    SOSFlexibleAlertController * upgradeAlert = [SOSFlexibleAlertController alertControllerWithImageURL:self.checkVersionResp.alertImgUrl placeholderImage:[UIImage imageNamed:@"appupgrade_default"] width:180 height:160 title:[NSString stringWithFormat:@"请升级至%@版本继续使用",self.checkVersionResp.version] message:nil  customView:te preferredStyle:SOSAlertControllerStyleAlert];
                    @weakify(upgradeAlert);
                    [upgradeAlert setRightButtonBlock:^{
                        UIButton * rightB = [[UIButton alloc] init];
                        [rightB setImage:[UIImage imageNamed:@"icon_bbs_del_34x34"] forState:UIControlStateNormal];
                        [rightB addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
                            
                            [SOSDaapManager sendActionInfo:MandatoryUpgrade_PopupWindow_Update_Cancel responseSuccess:^{
                                [self forceQuit];
                            } responseFail:^{
                                [self forceQuit];
                            }];
                            @strongify(upgradeAlert);
                            [upgradeAlert dismissViewControllerAnimated:YES completion:^{
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [self forceQuit];
                                });
                            }];
                        }];
                        return rightB;
                    }];
                    SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"立即升级" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
                        [SOSDaapManager sendActionInfo:MandatoryUpgrade_PopupWindow_Update];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.checkVersionResp.marketUrl]];
                        [self forceQuit];
                    }];
                    [upgradeAlert addActions:@[action]];
                    [upgradeAlert show];
                }else{
                    if ([self.checkVersionResp.alert isEqualToString:@"alert"]) {
                        //不需要强制升级
                        NSString * latestVersion = self.checkVersionResp.version;
                        if (![self dontUpgradeDoubleClickWithVersion:latestVersion]) {
                            SOSUpgradeDetailView * te = [[SOSUpgradeDetailView alloc] initWithFrame:CGRectMake(0, 0, SCALE_WIDTH(150), SCALE_WIDTH(100))];
                            [te addDetailTips:[self.checkVersionResp.updateNote componentsSeparatedByString:@"|"] leftOffset:40];
                            SOSFlexibleAlertController * upgradeAlert = [SOSFlexibleAlertController alertControllerWithImageURL:self.checkVersionResp.alertImgUrl placeholderImage:[UIImage imageNamed:@"appupgrade_default"] width:180    height:160 title:[NSString stringWithFormat:@"请升级至%@版本继续使用",self.checkVersionResp.version] message:nil  customView:te preferredStyle:SOSAlertControllerStyleAlert];
                            
                            SOSAlertAction *action1 = [SOSAlertAction actionWithTitle:@"暂不升级" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
                                [SOSDaapManager sendActionInfo:NonMandatoryUpgrade_PopupWindow_Cancel];
                                [self recordDontUpgradeWithVersion:latestVersion];
                            }];
                            SOSAlertAction *action2 = [SOSAlertAction actionWithTitle:@"立即升级" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
                                [SOSDaapManager sendActionInfo:NonMandatoryUpgrade_PopupWindow_Update];
                                //更新
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.checkVersionResp.marketUrl]];
                            }];
                            [upgradeAlert addActions:@[action1,action2]];
                            [upgradeAlert show];
                        }
                    }
                    
                }
            }
            
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        [self checkNewVersionUpdateWithAppID:@"437190725" complete:nil faile:nil];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

//记录暂不升级
-(void)recordDontUpgradeWithVersion:(NSString *)version{
    if (UserDefaults_Get_Object(K_LATEST_VERSION)) {
        NSDictionary * latestDic = UserDefaults_Get_Object(K_LATEST_VERSION);
        if ([latestDic valueForKey:version]) {
            //            NSNumber * times = [latestDic valueForKey:version];
            UserDefaults_Set_Object(@{version:@(2)}, K_LATEST_VERSION);
            
        }else{
            UserDefaults_Set_Object(nil, K_LATEST_VERSION);
            UserDefaults_Set_Object(@{version:@(1)}, K_LATEST_VERSION);
        }
    }else{
        UserDefaults_Set_Object(@{version:@(1)}, K_LATEST_VERSION);
    }
}

//是否点击了2次暂不升级
-(BOOL)dontUpgradeDoubleClickWithVersion:(NSString *)version{
    if (UserDefaults_Get_Object(K_LATEST_VERSION)){
        NSDictionary * latestDic = UserDefaults_Get_Object(K_LATEST_VERSION);
        
        if ([[[latestDic allKeys] objectAtIndex:0]  isEqualToString:version]) {
            NSNumber * times = [latestDic objectForKey:version];
            if (times.integerValue == 2) {
                return YES;
            }else{
                return NO;
            }
            
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

- (void)checkNewVersionUpdateWithAppID:(NSString *)appid complete:(void (^) (void))complete faile:(void(^)(void))faile		{
    /*
     新版本检测
     有新版提示用户升级。
     如果用户点击升级，进入下载地址
     如果用户点击取消，这个版本不再提示
     */
    NSString *urlString = [NSString stringWithFormat:CHECK_ITUNES_VERSION,appid];
    
    SOSNetworkOperation *sosOperation = [[SOSNetworkOperation alloc]initWithNOSSLURL:urlString params:nil needReturnSourceData:NO successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSError *error = nil;
        NSDictionary *dict = [Util dictionaryWithJsonString:responseStr];
        if (!error) {
            if (complete)   complete();
            if (dict != nil) {
                NSInteger resultCount = [[dict objectForKey:@"resultCount"] integerValue];
                if (resultCount == 1) {
                    NSArray *resultsArray = [dict objectForKey:@"results"];
                    NSDictionary *resultDict  = [resultsArray objectAtIndex:0];
                    self.latestVersion = [resultDict objectForKey:@"version"];
                    self.trackViewUrl = [[resultDict objectForKey:@"trackViewUrl"] copy];
                    NSString *localVersion = APP_VERSION;
                    NSString *kLatestVersion = [Util readConfig:K_LATEST_VERSION];
                    if(!kLatestVersion.length){
                        [Util writeConfig:K_LATEST_VERSION setValue:localVersion];
                    }
                    //只有服务器版本同上大于本地版本和上个提醒版本，才会提示用户升级
                    if ([self.latestVersion compare:localVersion] == NSOrderedDescending && [self.latestVersion compare:kLatestVersion] == NSOrderedDescending) {
                        //提示更新
                        [Util showAlertWithTitle:nil message:@"安吉星手机应用已更新，是否需要更新？" completeBlock:^(NSInteger buttonIndex) {
                            [self upgardeWithIndex:buttonIndex];
                        } cancleButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    } else if ([self.latestVersion compare:localVersion] == NSOrderedSame){
                        [Util writeConfig:K_LATEST_VERSION setValue:self.latestVersion];
                    }
                }
            }
        } else   {
            if (faile)  faile();
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (faile)  faile();
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}



//- (void)checkSDKVersion		{
//    NSString *url = [BASE_URL stringByAppendingString:NEW_CHECK_APP_VERSION_URL];
//    NSDictionary *d = @{@"osType":@"IPHONE"};
//    NSString *s = [Util jsonFromDict:d];
//    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        @try {
//            CheckInAppVersionResponse *versionResponse = [CheckInAppVersionResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
//            self.trackViewUrl = versionResponse.urlLocation;
//            if ([versionResponse.app_version_status isEqualToString:@"1"]) {
//                //停用
//                [Util showAlertWithTitle:versionResponse.message message:nil completeBlock:^(NSInteger buttonIndex) {
//                    [self forceQuit];
//                }];
//            }	else if ([versionResponse.app_version_status isEqualToString:@"2"]) {
//                //提示更新
//                [Util showAlertWithTitle:versionResponse.message message:nil completeBlock:^(NSInteger buttonIndex) {
//                    [self upgardeWithIndex:buttonIndex];
//                } cancleButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//            }	else if ([versionResponse.app_version_status isEqualToString:@"3"]) {
//                //强制更新
//                [Util showAlertWithTitle:versionResponse.message message:nil completeBlock:^(NSInteger buttonIndex) {
//                    //更新
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.trackViewUrl]];
//                }];
//            }
//        }
//        @catch (NSException *exception) {
//            NSLog(@"XMLEXCEPTION %@",exception);
//        }
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//    }];
//    [sosOperation setHttpMethod:@"POST"];
//    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//    [sosOperation start];
//}

- (void)upgardeWithIndex:(NSInteger)index	{
    // 更新
    if(index == 1)	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.trackViewUrl]];
    // 取消
    else         [Util writeConfig:K_LATEST_VERSION setValue:self.latestVersion];
}

- (void)forceQuit	{
#if __has_include("SOSSDK.h")
    [SOSSDK sos_dismissOnstarModule];
#else
    abort();
#endif
}

#pragma mark - something
- (void)manageVersion		{
    NSString *currentVersion = APP_VERSION;
    if ([currentVersion isEqualToString:[Util readConfig:K_INSTALLED_VERSION]]) {
        return;
    }
    [Util writeConfig:K_PREVIOUS_VERSION setValue:([Util readConfig:K_INSTALLED_VERSION]?[Util readConfig:K_INSTALLED_VERSION]:@"")];
    if (![Util isNotEmptyString:[Util readConfig:K_PREVIOUS_VERSION]]) {
        if (![[Util readConfig:K_FIRST_TIME_LOAD] boolValue]) {
            [Util writeConfig:K_PREVIOUS_VERSION setValue:@"2.4.0"];
        }
    }
    [Util writeConfig:INTRODUCTION_FLAG setValue:INTRODUCTION_YES];
    [Util writeConfig:K_INSTALLED_VERSION setValue:currentVersion];
}
//#pragma mark - 检查预付费卡是否可用
//- (void)checkPrepaymentAvailable    {
//    NSString *url = [NSString stringWithFormat:(@"%@" MA92_API_Check_Prepayment), BASE_URL];
//    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        NSDictionary * dic = [Util dictionaryWithJsonString:responseStr];
//        NSString * flag =  [dic objectForKey:@"masterDataCode"];
//        if ([flag isEqualToString:@"1"]) {
//            //开
//            SOS_APP_DELEGATE.prepaymentAvailable = YES;
//        }
//
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//    }];
//    [sosOperation setHttpMethod:@"GET"];
//    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//    [sosOperation start];
//}
@end
