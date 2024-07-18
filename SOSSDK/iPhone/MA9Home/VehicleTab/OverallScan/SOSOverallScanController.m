//
//  SOSOverallScanController.m
//  Onstar
//
//  Created by TaoLiang on 2019/3/29.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOverallScanController.h"
#import "SOSQRManager.h"
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
#import "SOSBleUtil.h"
#endif
#import "SOSAYChargeManager.h"
#ifndef SOSSDK_SDK
#import "SOSMirrorManager.h"
#import "SOSBindingDeviceManager.h"
#import "SOSDRScanManager.h"
#import "SOSGroupTripInviteTool.h"
#endif
#import "SOSCardUtil.h"
#import "NSString+Category.h"

//#import "SOSOMScanManager.h"

@interface TorchButton : UIButton


@end

@implementation TorchButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        [self setTitle:@"轻触照亮" forState:UIControlStateNormal];
        [self setTitle:@"轻触关闭" forState:UIControlStateSelected];
        [self setImage:[UIImage imageNamed:@"icon_lamp_def_34x34"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"icon_lamp_open_34x34"] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Center image
    CGPoint center = self.imageView.center;
    center.x = self.frame.size.width/2;
    center.y = self.frame.size.height/2 - 10;
    self.imageView.center = center;
    
    //Center text
    [self.titleLabel sizeToFit];
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.imageView.bottom;
    newFrame.size.width = self.frame.size.width;
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end

@interface PromptView : UIView
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *label;


@end

@implementation PromptView

- (instancetype)initWithImageName:(NSString *)imageName text:(NSString *)text {
    if (self = [super initWithFrame:CGRectZero]) {
        _imageView = [UIImageView new];
        _imageView.image = [UIImage imageNamed:imageName];
        [self addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(self);
            make.top.equalTo(@8);
            make.size.equalTo(@60);
        }];
        _label = [UILabel new];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:12];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 0;
        _label.text = text;
        [self addSubview:_label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_imageView.mas_bottom);
            make.bottom.equalTo(@-8);
            make.left.right.equalTo(self);
        }];
    }
    return self;
}

@end

@interface SOSOverallScanController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIView *previewView;

@property (strong, nonatomic) UIView *scanView;

@end

@implementation SOSOverallScanController

- (void)initView {
    self.fd_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    _previewView = [UIView new];
    [self.view addSubview:_previewView];
    [_previewView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    
    UIView *blurView = [UIView new];
    [self.view addSubview:blurView];
    [blurView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurView addSubview:effectView];
    [effectView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(_previewView);
    }];
    
    
    UIView *fakeNav = [UIView new];
    [self.view addSubview:fakeNav];
    [fakeNav mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(@(STATUSBAR_HEIGHT));
        make.left.right.equalTo(self.view);
        make.height.equalTo(@44);
    }];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.tintColor = [UIColor whiteColor];
    [backBtn setImage:[UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateNormal];
    [backBtn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [fakeNav addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(fakeNav);
        make.left.equalTo(@8);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    titleLabel.text = @"扫一扫";
    [fakeNav addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.center.equalTo(fakeNav);
    }];
    
    UIButton *libraryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    libraryBtn.tintColor = UIColor.whiteColor;
    [libraryBtn setImage:[UIImage imageNamed:@"icon_team_picture_34x34"] forState:UIControlStateNormal];
    [libraryBtn addTarget:self action:@selector(chooseFromLibrary) forControlEvents:UIControlEventTouchUpInside];
    [fakeNav addSubview:libraryBtn];
    [libraryBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(@-8);
        make.centerY.equalTo(fakeNav);
    }];

    
    _scanView = [UIView new];
    _scanView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scanView];
    [_scanView mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(self.view).offset(-30);
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@200);
    }];
    
    
    UIImageView *scanBGView = [UIImageView new];
    scanBGView.image = [UIImage imageNamed:@"image_sweep_220x220"];
    [self.view addSubview:scanBGView];
    [scanBGView mas_makeConstraints:^(MASConstraintMaker *make){
        make.center.equalTo(_scanView);
        make.size.equalTo(@220);
    }];
    _scanBGView = scanBGView;
    
    TorchButton *torchButton = [TorchButton buttonWithType:UIButtonTypeCustom];
    [torchButton addTarget:self action:@selector(onTorch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:torchButton];
    [torchButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(scanBGView);
        make.bottom.equalTo(scanBGView).offset(-10);
        make.size.mas_equalTo(CGSizeMake(50, 55));
    }];
    
    
    UIImageView *scanLine = [UIImageView new];
    scanLine.image = [UIImage imageNamed:@"image_sweep_210x4"];
    [self.view addSubview:scanLine];
    [scanLine mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.centerX.equalTo(_scanView);
    }];
    //强制更新scanView的frame,保证maskLayer可以获得正确的frame进行遮罩
    [self.view layoutIfNeeded];
    
    [scanLine mas_updateConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(_scanView).offset(_scanView.height);
    }];
    
    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear animations:^{
        scanLine.hidden = NO;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        scanLine.hidden = YES;
    }];
    
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [bezierPath appendPath:[[UIBezierPath bezierPathWithRect:_scanView.frame] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    blurView.layer.mask = shapeLayer;
    
    if (self.class == SOSOverallScanController.class) {
        [self initBottomView];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startScan];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    //判断被push走
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self) {
        [self clearNavVCWithClassNameArray:@[self.className]];
    }
}

- (void)startScan {
    if ([[SOSQRManager shareInstance] checkAuthStatus]) {
        if ([_delegate respondsToSelector:@selector(overallScanWillStartScan:)]) {
            [_delegate overallScanWillStartScan:self];
        }
        [[SOSQRManager shareInstance] startScanningQRCodeWithInView:_previewView scanView:_scanView resultCallback:^(NSArray *results) {
            NSLog(@"scan result = %@", results);
            if (results.count <= 0) {
                return;
            }
            //如果有delegate，则不走内部跳转逻辑了
            if ([_delegate respondsToSelector:@selector(overallScan:didFetchResults:)]) {
                [_delegate overallScan:self didFetchResults:results];
            }else {
                [self onFetchResults:results];
            }
            [[SOSQRManager shareInstance] stopScanner];
            if ([_delegate respondsToSelector:@selector(overallScanDidEndScan:)]) {
                [_delegate overallScanDidEndScan:self];
            }
        }];
    }else {
        if ([_delegate respondsToSelector:@selector(overallScanDidNotAuthorized:)]) {
            [_delegate overallScanDidNotAuthorized:self];
        }
    }
    
}
#pragma mark - private
- (void)chooseFromLibrary {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)onTorch:(TorchButton *)button {
    if (button.isSelected) {
        [[SOSQRManager shareInstance] closeFlash];
        button.selected = NO;
    }else {
        [[SOSQRManager shareInstance] openFlash];
        button.selected = YES;
    }
}

- (void)onFetchResults:(NSArray *)results {
    if (![results.firstObject isKindOfClass:NSString.class]) {
        return;
    }
    NSString *code = results.firstObject;
    //    if ([code.lowercaseString hasPrefix:@"ay".lowercaseString] || [self deptNumInputShouldNumber:code.lowercaseString]) {
    //        if ([Util vehicleIsBEV] || [Util vehicleIsPHEV]) {
    //            [SOSAYChargeManager enterAYChargeVCIsFromCarLife:YES code:code];
    //        }else {
    //            [Util showAlertWithTitle:@"不支持非新能源车" message:nil completeBlock:^(NSInteger buttonIndex) {
    //                [[SOSQRManager shareInstance] resumeScan];
    //            }];
    //
    //        }
    //    }else
    if ([code.lowercaseString containsString:@"uuid=ble".lowercaseString]) {
        [SOSDaapManager sendActionInfo:GlobalQRScanning_BluetoothKey];
        [self.navigationController popViewControllerAnimated:NO];
        __weak __typeof(self)weakSelf = self;
        [SOSCardUtil routerToUserReceiveBlePageBlock:^{
            NSMutableArray<__kindof UIViewController *> *vcs = weakSelf.navigationController.viewControllers.mutableCopy;
            [vcs removeObject:weakSelf];
            weakSelf.navigationController.viewControllers = vcs.copy;
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
            [SOSBleUtil showReceiveAlertControllerWithUrl:code];
#endif
        }];
    }else if ([code.lowercaseString containsString:@"mqr?tempid".lowercaseString]) {
#ifndef SOSSDK_SDK
        [SOSDaapManager sendActionInfo:GlobalQRScanning_SRVM];
        [[SOSMirrorManager shareInstance] startRVMirrorWithQRCode:code fail:^(NSString *errMsg) {
            [[SOSQRManager shareInstance] resumeScan];
        }];
    }else if ([code.lowercaseString containsString:@"om=".lowercaseString]) {
        NSString *omID = [SOSOTempidModel getImid:code];
        if ([NSString isBlankString:omID]) {
            return;
        }
        [SOSOMScanManager requestOMBindToken:omID failCallBlock:nil];
    }else if ([code.lowercaseString containsString:@"sd?dc".lowercaseString]) {
        NSString *encryptedStr = [SOSDRIMEIModel getImid:code];
        if ([NSString isBlankString:encryptedStr]) {
            return;
        }
        [SOSDRScanManager requestValidityDevicesCheckEncryptedStr:encryptedStr failCallBlock:nil];
    }else if ([code.lowercaseString containsString:@"SOSGroupTrip".lowercaseString]) {
        NSDictionary *param = [Util parseURLParam:code];
        NSString *teamId = param[@"teamId"] ? : @"";
        [SOSGroupTripInviteTool tryJoinTeam:teamId result:^(BOOL success) {
            if (!success) {
                [SOSQRManager.shareInstance resumeScan];
            }
        }];
#endif

    }
    else {
        [Util showAlertWithTitle:@"二维码识别失败，请重新扫描" message:nil completeBlock:^(NSInteger buttonIndex) {
            [[SOSQRManager shareInstance] resumeScan];
        }];
    }
}

- (BOOL)deptNumInputShouldNumber:(NSString *)str {
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}


- (void)popViewControllerAnimated {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)initBottomView {
    UIView *bottomContainerView = [UIView new];
    bottomContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:.45];
    [self.view addSubview:bottomContainerView];
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UILabel *bottomLabel = [UILabel new];
    bottomLabel.text = @"* 暂不支持智能电视登录，敬请期待";
    bottomLabel.textColor = [UIColor colorWithHexString:@"#9BA0AA"];
    bottomLabel.font = [UIFont systemFontOfSize:12];
    [bottomContainerView addSubview:bottomLabel];
    [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(bottomContainerView);
        make.bottom.equalTo(self.view.sos_bottom).offset(IS_IPHONE_XSeries?0:-14);
    }];
    
    UIView *promptsContainerView = [UIView new];
    [bottomContainerView addSubview:promptsContainerView];
    [promptsContainerView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.right.equalTo(bottomContainerView);
        make.bottom.equalTo(bottomLabel.mas_top).offset(-26);
        //        make.height.equalTo(@100);
    }];
    
    NSArray *imageNames = @[@"icon_mirror_pop", @"icon_bluetooth_pop"];
    NSArray *texts = @[@"智能后视镜注册", @"蓝牙钥匙共享"];
    //    NSArray *imageNames = @[@"icon_mirror_pop", @"icon_sweep_pop", @"icon_bluetooth_pop"];
    //    NSArray *texts = @[@"智能后视镜注册", @"安悦充电付费", @"蓝牙钥匙共享"];
    NSMutableArray *promptViews = @[].mutableCopy;
    [imageNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PromptView *view = [[PromptView alloc] initWithImageName:obj text:texts[idx]];
        [promptsContainerView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.bottom.equalTo(promptsContainerView);
        }];
        [promptViews addObject:view];
    }];
    
    [promptViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:60 leadSpacing:80 tailSpacing:80];
    
    UILabel *label = [UILabel new];
    label.text = @"支持功能";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(bottomContainerView.mas_top).offset(-12);
        make.centerX.equalTo(self.view);
    }];
    
}


#pragma mark - image pick delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSArray<NSString *> *arr = [SOSQRManager.shareInstance detectorQRCodeWithQRCodeImage:image];
        if (arr.count <= 0) {
            [Util showAlertWithTitle:@"无法识别图片中的二维码" message:nil completeBlock:nil];
            return;
        }
        
        [self onFetchResults:arr];
    }];
    

}
@end
