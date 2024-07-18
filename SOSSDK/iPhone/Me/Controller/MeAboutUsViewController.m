//
//  MeAboutUsViewController.m
//  Onstar
//
//  Created by Apple on 16/7/12.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "MeAboutUsViewController.h"
#import "SOSWebViewController.h"
#import "SOSCheckRoleUtil.h"
#import "VersionManager.h"
#import "SOSAgreement.h"
#import "SOSAgreementAlertView.h"
#import "SOSAboutAgreementView.h"

#ifndef SOSSDK_SDK
    #if DEBUG || TEST
        #import "RemoteConsole.h"
    #endif
#endif
@interface MeAboutUsViewController (){
    UIImageView * logoV;
    UILabel *infoLb;
    UILabel *releaseTimeLabel;
    UIView  *baseView;
}

@property (weak, nonatomic) IBOutlet UILabel *copyrightLB;

@property (weak, nonatomic) IBOutlet UILabel *buildInfoLabel;
@property (strong, nonatomic) NSMutableArray<SOSAgreement *> *agreements;
@property (weak, nonatomic) IBOutlet SOSAboutAgreementView *agreementView;

@end

@implementation MeAboutUsViewController

#ifndef SOSSDK_SDK
#if DEBUG || TEST
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        if ([RemoteConsole shared].serverIsOpen) {
            [Util showAlertWithTitle:@"支持远程log且服务已开启" message:@"请确保手机连接Wifi23333333" completeBlock:nil];
        }else {
            [Util showAlertWithTitle:@"支持远程log但服务未开启" message:@"请重启APP再试" completeBlock:nil];

        }
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}
#endif
#endif
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关于安吉星";
//    self.infoLb.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"OnStar_Mobile_Application", nil),SOSSDK_ONSTAR_VERSION];
    
    self.copyrightLB.text = @"上海安吉星信息服务有限公司 版权所有©2009-2019";
    self.copyrightLB.adjustsFontSizeToFitWidth = YES;
    
    NSString *build = [UIApplication sharedApplication].appBuildVersion;
#if DEBUG || TEST
        self.buildInfoLabel.text = build;
#else
        self.buildInfoLabel.hidden = YES;
#endif
    _agreements = @[].mutableCopy;
    NSArray<NSString *> *types = @[agreementName(ONSTAR_TC), agreementName(ONSTAR_PS), agreementName(SGM_TC), agreementName(SGM_PS)];
    [self requestAgreements:types];
    
    [self initBaseView];
    
}
-(void)initBaseView{
    baseView = [[UIView alloc] init];
    baseView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    baseView.layer.cornerRadius = 4;
    baseView.layer.shadowColor = [UIColor colorWithRed:101/255.0 green:112/255.0 blue:181/255.0 alpha:0.2].CGColor;
    baseView.layer.shadowOffset = CGSizeMake(0,3);
    baseView.layer.shadowOpacity = 1;
    baseView.layer.shadowRadius = 8;
    [self.view addSubview:baseView];
    
    [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
        make.top.mas_equalTo(30);
        make.bottom.mas_equalTo(_copyrightLB.mas_top).mas_offset(-69);
    }];
    
    //icon
    logoV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AboutUs_logo"]];
    [baseView addSubview:logoV];
    
    
    infoLb = [[UILabel alloc] init];
    infoLb.numberOfLines = 0;
    infoLb.textAlignment = NSTextAlignmentCenter;
    [baseView addSubview:infoLb];
    
    if ([VersionManager sharedInstance].checkVersionResp) {
        if (![VersionManager sharedInstance].checkVersionResp.update) {
            //已是最新
            [self defaultVersionDescription];
            [self addReleaseTime:[VersionManager sharedInstance].checkVersionResp.releaseDate];
            [self adjustAlreadyLatest];
        }else{
            //有更新
            [self defaultVersionDescription];
            [self addReleaseTime:[VersionManager sharedInstance].checkVersionResp.releaseDate];
            [self addReleaseDescription:[VersionManager sharedInstance].checkVersionResp.updateNote];
        }
    }else{
        [self defaultVersionDescription];
    }
    
}
-(void)defaultVersionDescription{
    //logo
    [logoV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(baseView.mas_centerY).mas_offset(-120);
        make.centerX.mas_equalTo(baseView);
    }];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"当前版本 v%@",APP_VERSION] attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:78/255.0 green:80/255.0 blue:89/255.0 alpha:1.0]}];
    infoLb.attributedText = string;
   //当前版本
    [infoLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoV.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(baseView);
    }];
    
}
-(void)addReleaseTime:(NSString *)releaseDate{
    releaseTimeLabel = [[UILabel alloc] init];
    releaseTimeLabel.numberOfLines = 0;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[@"更新于" stringByAppendingString:releaseDate]attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFang-SC-Medium" size: 11],NSForegroundColorAttributeName: [UIColor colorWithRed:130/255.0 green:131/255.0 blue:137/255.0 alpha:1.0]}];
    
    releaseTimeLabel.attributedText = string;
    releaseTimeLabel.textAlignment = NSTextAlignmentCenter;
    [baseView addSubview:releaseTimeLabel];
    [releaseTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(baseView);
        make.top.mas_equalTo(infoLb.mas_bottom).mas_offset(10);
    }];
}
-(void)addReleaseDescription:(NSString *)updateDesc{
    //NEW icon
    UIView *view = [[UIView alloc] init];
    // gradient
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,38,19);
    gl.startPoint = CGPointMake(0.5, 0);
    gl.endPoint = CGPointMake(0.5, 1);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:170/255.0 green:219/255.0 blue:135/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:97/255.0 green:159/255.0 blue:58/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    view.layer.cornerRadius = 2;
    [view.layer addSublayer:gl];
    [baseView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(baseView.mas_centerY).mas_offset(44);
        make.centerX.mas_equalTo(baseView.mas_centerX).mas_offset(-40);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(19);
    }];
    
    UILabel *newLB = [[UILabel alloc] init];
    newLB.numberOfLines = 0;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"NEW"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];
    
    newLB.attributedText = string;
    newLB.textAlignment = NSTextAlignmentCenter;
    [view addSubview:newLB];
    [newLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(view);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(169,336,84,24);
    label.numberOfLines = 0;
    [baseView addSubview:label];
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithString:[@"新版本 v" stringByAppendingString:[VersionManager sharedInstance].checkVersionResp.version]attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 17],NSForegroundColorAttributeName: [UIColor colorWithRed:48/255.0 green:77/255.0 blue:143/255.0 alpha:1.0]}];
    label.attributedText = newString;
    label.textAlignment = NSTextAlignmentCenter;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view.mas_right).mas_offset(10);
        make.centerY.mas_equalTo(view);
    }];
    
    SOSUpgradeDetailView * te = [[SOSUpgradeDetailView alloc] init];
    [te addDetailTips:[updateDesc componentsSeparatedByString:@"|"] leftOffset:0];
    [baseView addSubview:te];
    [te mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view).mas_offset(20);
        make.leading.mas_equalTo(view.mas_leading).mas_offset(-20);
        make.trailing.mas_equalTo(-20);
        make.bottom.mas_equalTo(baseView.mas_bottom).mas_offset(-30);
    }];
}
-(void)adjustAlreadyLatest{
    [logoV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(baseView.mas_centerY).mas_offset(-44);
    }];

    [infoLb mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoV.mas_bottom).mas_offset(80);
    }];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[@"当前已是最新版本 v" stringByAppendingString:[VersionManager sharedInstance].checkVersionResp.version]attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 17],NSForegroundColorAttributeName: [UIColor colorWithRed:48/255.0 green:77/255.0 blue:143/255.0 alpha:1.0]}];
    infoLb.attributedText = string;
}
#pragma mark - http request
/**
 获取协议
 
 @param types 协议s
 */
- (void)requestAgreements:(NSArray<NSString *> *)types {
    [SOSAgreement requestAgreementsWithTypes:types success:^(NSDictionary *response) {
        if (response.allKeys.count != types.count) {
            return;
        }
        [types enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([response.allKeys containsObject:obj]) {
                SOSAgreement *model = [SOSAgreement mj_objectWithKeyValues:response[obj]];
                [_agreements addObject:model];
            }
        }];
        _agreementView.agreements = _agreements;
        __weak __typeof(self)weakSelf = self;
        _agreementView.tapAgreement = ^(NSInteger line, NSInteger index) {
            SOSAgreement *agreement = weakSelf.agreements[line * 2 + index];
            SOSAgreementAlertView *view = [[SOSAgreementAlertView alloc] initWithAlertViewStyle:SOSAgreementAlertViewStyleSignUp];
            view.agreements = @[agreement];
            [view show];
        };


    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:@"获取协议内容失败"];
    }];
}


@end
