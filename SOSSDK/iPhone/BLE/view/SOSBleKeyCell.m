//
//  SOSBleKeyCell.m
//  Onstar
//
//  Created by onstar on 2018/7/19.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleKeyCell.h"
#import "SOSBleKeyView.h"
#import "BlueToothManager+SOSBleExtention.h"
#import <BlePatacSDK/DBManager.h>
#import <BlePatacSDK/BlueToothManager.h>
#import "SOSBleUtil.h"

@interface SOSBleKeyCell ()

@property (nonatomic, strong) SOSBleKeyView *bleKeyNoConnectView;
@property (nonatomic, strong) SOSBleKeyView *bleKeyConnectingView;
@property (nonatomic, strong) SOSBleKeyView *bleKeyConnectedView;

@property (nonatomic, strong) UIView *topContentView;
//@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIImageView *iconSignImageView;
@property (nonatomic, strong) UIImageView *transformImageView;

@property (nonatomic, strong) UIView *bottomContentView;

/**
 获取response后赋值
 */
@property (nonatomic, assign) RemoteControlStatus status;

@end


@implementation SOSBleKeyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initViews {
    [self setUpView];
}


- (void)setUpView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.titleLabel.text = @"蓝牙钥匙";
    self.iconSignImageView.image = [UIImage imageNamed:@"icon-ble"];
    self.transformImageView.image = [UIImage imageNamed:@"Icon／22x22／OnStar_icon_guide_common_22x22"];
}

- (void)refreshWithResp:(id)response {
    self.status = [self cellStatusWithRespose:response];
    BlueToothManager *manager = [BlueToothManager sharedInstance];
    if ([manager getCenterManagerState] == BlueToothStatePoweredOn) {//可用
        
        if ([manager isConnected]) {//已连接
            _bleKeyNoConnectView.hidden = YES;
            self.bleKeyConnectedView.hidden = NO;
            _bleKeyConnectingView.hidden = YES;
            NSString *vin = UserDefaults_Get_Object(bleConnectdbkey);
            self.infoLabel.hidden = NO;
            self.infoLabel.text = [[SOSBleUtil recodesign:vin] stringByReplacingOccurrencesOfString:@"VIN " withString:@""];
//            [self.bleKeyConnectedView changeStartStatus];
//            [self.bleKeyConnectedView changeStartStatus];
        }else
        if (manager.bleConnectStatus == SOSBleConnectStatusConnecting) {
            
            _bleKeyNoConnectView.hidden = YES;
            _bleKeyConnectedView.hidden = YES;
            self.bleKeyConnectingView.hidden = NO;
            //show 刷新中
            self.infoLabel.text = @"";
            self.infoLabel.hidden = YES;
            
            NSString *vin = [SOSBleUtil getFullVinWithBleName:manager.bleOperationVar.connectingBleModel.BleName];
            self.bleKeyConnectingView.ownerLabel.text =  [SOSBleUtil recodesign:vin];
            self.bleKeyConnectingView.vinLabel.text = @"蓝牙设备";
            self.bleKeyConnectingView.carImageView.fd_collapsed = YES;
            [self.bleKeyConnectingView.reConnectButton setTitle:@"正在连接中..." forState:UIControlStateNormal];
            self.bleKeyConnectingView.reConnectButton.layer.borderWidth = 0;
            self.bleKeyConnectingView.reConnectButton.enabled = NO;
            
        }
        else
        
        {
//            self.status = RemoteControlStatus_OperateSuccess;
            if (self.status == RemoteControlStatus_InitSuccess) {
                _bleKeyNoConnectView.hidden = YES;
                _bleKeyConnectedView.hidden = YES;
                self.bleKeyConnectingView.hidden = NO;
                //show 刷新中
                self.infoLabel.text = @"";
                self.infoLabel.hidden = YES;
                self.bleKeyConnectingView.vinLabel.text = @"";
                self.bleKeyConnectingView.ownerLabel.text = @"";
                [self.bleKeyConnectingView.reConnectButton setTitle:@"正在搜索车辆..." forState:UIControlStateNormal];
                self.bleKeyConnectingView.carImageView.fd_collapsed = NO;
                self.bleKeyConnectingView.reConnectButton.layer.borderWidth = 0;;
                self.bleKeyConnectingView.reConnectButton.enabled = NO;
            }else {
                //未连接(恢复连接or 未连接状态)
                if ([response isKindOfClass:[NSArray class]] && [(NSArray *)response count]) {
                    //匹配本地是否需要显示恢复连接卡片
                    BLEModel *bModel = [self filterDevices:response];
                    if (bModel) {
                        _bleKeyNoConnectView.hidden = YES;
                        _bleKeyConnectedView.hidden = YES;
                        self.bleKeyConnectingView.hidden = NO;
                        self.infoLabel.hidden = NO;
                        //恢复连接
                        self.infoLabel.text = @"搜寻其他车辆";
                        [self.bleKeyConnectingView.reConnectButton setTitle:@"恢复连接" forState:UIControlStateNormal];
                     self.bleKeyConnectingView.carImageView.fd_collapsed = YES;
                        self.bleKeyConnectingView.reConnectButton.layer.borderWidth = 0.5;
                        self.bleKeyConnectingView.reConnectButton.enabled = YES;
                        NSString *vin = [SOSBleUtil getFullVinWithBleName:bModel.BleName];
                        self.bleKeyConnectingView.ownerLabel.text =  [[SOSBleUtil recodesign:vin] stringByReplacingOccurrencesOfString:@"VIN " withString:@""];
                        self.bleKeyConnectingView.vinLabel.text = @"蓝牙设备";
                        [self.bleKeyConnectingView.reConnectButton setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
                            !self.reConnectBlock?:self.reConnectBlock(bModel);
                        }];
                        [self layoutIfNeeded];
                    }else {
                        [self showUnConnectStatus];
                    }
                }else {
                    //未连接状态
                    [self showUnConnectStatus];
                }
            }
        }
    }else {//不可用显示未连接状态
        [self showUnConnectStatus];
    }
}

- (RemoteControlStatus)cellStatusWithRespose:(id)response {
    
    RemoteControlStatus status;
    if (response == nil) {
        //读取中
        status = RemoteControlStatus_Void;
    }else if ([response isKindOfClass:[NSNumber class]]) {
        if ([response boolValue] == YES) {
            //读取中
            status = RemoteControlStatus_InitSuccess;
        }else {
            //加载失败
            status = RemoteControlStatus_OperateFail;
        }
    }else if (response) {
        status = RemoteControlStatus_OperateSuccess;
    }else {
        //加载失败
        status = RemoteControlStatus_OperateFail;
    }
    return status;
}


#pragma mark setter
- (void)setStatus:(RemoteControlStatus)status {
    _status = status;
//    [self configCellWithChangeStatus:status];
}


- (void)configCellWithChangeStatus:(RemoteControlStatus)status
{
    switch (status) {
        case RemoteControlStatus_InitSuccess:
        {
            dispatch_async_on_main_queue(^{
                self.transformImageView.image = [UIImage imageNamed:@"transformrotation"];
                [SOSUtilConfig transformRotationWithView:self.transformImageView];
            });
        }
            break;
        case RemoteControlStatus_OperateSuccess:
        {
            dispatch_async_on_main_queue(^{
                [SOSUtilConfig transformIdentityStatusWithView:self.transformImageView];
                self.transformImageView.image = [UIImage imageNamed:@"icon_arrow_right_passion_blue_idle"];
                [SOSUtilConfig transformIdentityStatusWithView:self.transformImageView];

            });
        }
            break;
        case RemoteControlStatus_OperateFail:
        {
            dispatch_async_on_main_queue(^{
                [SOSUtilConfig transformIdentityStatusWithView:self.transformImageView];
                self.transformImageView.image = [UIImage imageNamed:@"icon_alert_red_idle"];
                [SOSUtilConfig transformIdentityStatusWithView:self.transformImageView];
            });
        }
            break;
        default:
            break;
    }
}



- (void)showUnConnectStatus {
    self.bleKeyNoConnectView.hidden = NO;
    _bleKeyConnectedView.hidden = YES;
    _bleKeyConnectingView.hidden = YES;
    self.infoLabel.text = @"";
    self.infoLabel.hidden = YES;
}


- (BLEModel *)filterDevices:(NSArray *)devices {
//    return devices.firstObject;
    //取本地上次连接的车
    NSString *vin = UserDefaults_Get_Object(bleConnectdbkey);
    if (!vin.isNotBlank) {
        return nil;
    }
    BOOL lastConnectNearBy = NO;
    NSMutableArray *nearbyBleSet = @[].mutableCopy;
    for (BLEModel *bleModel in devices) {
        NSArray<Keyinfo *> *keys = [[DBManager sharedInstance] GetSomeKeyInDB:INT_MAX];
        NSString *vinLastSix = [bleModel.BleName stringByReplacingOccurrencesOfString:@"SGM " withString:@""];
        for (Keyinfo *keyInfo in keys) {
            if ([keyInfo.vin hasSuffix:vinLastSix]) {
                [nearbyBleSet addObject:bleModel];
            }
        }
        //搜寻上次连接的车在不在
        if ([vin  hasSuffix:vinLastSix]) {
            lastConnectNearBy = YES;
        }
    }
    //有且仅有一对  且是上次连接的车
    if (lastConnectNearBy&&(nearbyBleSet.count==1)) {
        return nearbyBleSet.firstObject;
    }
    return nil;
}


#pragma mark getter

- (SOSBleKeyView *)bleKeyNoConnectView {
    if (!_bleKeyNoConnectView) {
        _bleKeyNoConnectView = [[NSBundle SOSBundle] loadNibNamed:SOSBleKeyView.className owner:nil options:nil][0];
        [self.bottomContentView addSubview:_bleKeyNoConnectView];
        [_bleKeyNoConnectView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.bottomContentView);
        }];
    }
    return _bleKeyNoConnectView;
}

- (SOSBleKeyView *)bleKeyConnectingView {
    if (!_bleKeyConnectingView) {
        _bleKeyConnectingView = [[NSBundle SOSBundle] loadNibNamed:SOSBleKeyView.className owner:nil options:nil][1];
        [self.bottomContentView addSubview:_bleKeyConnectingView];
        [_bleKeyConnectingView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.bottomContentView);
        }];
    }
    return _bleKeyConnectingView;
}

- (SOSBleKeyView *)bleKeyConnectedView {
    if (!_bleKeyConnectedView) {
        _bleKeyConnectedView = [[NSBundle SOSBundle] loadNibNamed:SOSBleKeyView.className owner:nil options:nil][2];
        [self.bottomContentView addSubview:_bleKeyConnectedView];
//        _bleKeyConnectedView.operationBlock = self.operationBlock;
        [_bleKeyConnectedView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.bottomContentView);
        }];
    }
    return _bleKeyConnectedView;
}

- (UIView *)topContentView {
    if (!_topContentView) {
        _topContentView = [UIView new];
        [self.contentView addSubview:_topContentView];
        [_topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.left.mas_equalTo(self.contentView);
            make.height.mas_equalTo(50);
        }];
    }
    return _topContentView;
}

//- (UILabel *)titleLabel {
//    if (!_titleLabel) {
//        _titleLabel = [UILabel new];
//        [self.topContentView addSubview:_titleLabel];
//        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(self.iconSignImageView.mas_right).mas_offset(8);
//            make.centerY.mas_equalTo(self.topContentView);
//        }];
//    }
//    return _titleLabel;
//}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [UILabel new];
        [self.topContentView addSubview:_infoLabel];
        [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.transformImageView.mas_left).mas_offset(-8);
            make.centerY.mas_equalTo(self.topContentView);
        }];
        _infoLabel.textColor = UIColorHex(#828389);
    }
    return _infoLabel;
}

- (UIImageView *)iconSignImageView {
    if (!_iconSignImageView) {
        _iconSignImageView = [UIImageView new];
        [self.topContentView addSubview:_iconSignImageView];
        [_iconSignImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.centerY.mas_equalTo(self.topContentView);
        }];
    }
    return _iconSignImageView;
}

- (UIImageView *)transformImageView {
    if (!_transformImageView) {
        _transformImageView = [UIImageView new];
        [self.topContentView addSubview:_transformImageView];
        [_transformImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.topContentView);
            make.right.mas_equalTo(self.topContentView).mas_offset(-16);
        }];
    }
    return _transformImageView;
}

- (UIView *)bottomContentView {
    if (!_bottomContentView) {
        _bottomContentView = [UIView new];
        [self.contentView addSubview:_bottomContentView];
        [_bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.topContentView.mas_bottom);
        }];
    }
    return _bottomContentView;
}



@end


