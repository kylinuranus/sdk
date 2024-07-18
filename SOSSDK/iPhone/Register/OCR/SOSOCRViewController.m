//
//  SOSOCRViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/10/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSOCRViewController.h"
#import "SOSSegmentView.h"
#import "SOSVinViewController.h"
#import <ISOpenSDKFoundation/ISOpenSDKFoundation.h>
#import <ISIDReaderPreviewSDK/ISIDReaderPreviewSDK.h>
#import "SOSScanIDCardViewController.h"
@interface SOSOCRViewController ()<ISOpenSDKCameraViewControllerDelegate>
{
    
    
}
@property (nonatomic,strong) SOSSegmentView *titleView;
@property (nonatomic,strong) SOSVinViewController *  scanVINController ;
@property (nonatomic,strong) SOSScanIDCardViewController * scanIDCardController;

@end

@implementation SOSOCRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    self.fd_prefersNavigationBarHidden = YES;
    if (self.currentType == ScanALLType) {
        [self scanAllType];
    }
    else
    {
        if (self.currentType == ScanIDCard) {
            [self justScanIDCard];
        }
        else
        {
          [self justScanVIN];  
        }
    }
    [self setupUI];
    [self setNeedsStatusBarAppearanceUpdate];
}
- (SOSVinViewController *)scanVINController
{
    SOSWeakSelf(weakSelf);
    if (!_scanVINController) {
        _scanVINController = [[SOSVinViewController alloc] initWithAuthorizationCode:IDCardAppKey];
        [_scanVINController setScanVinBlock:^(SOSScanResult * result){
            if (weakSelf.scanBlock) {
                weakSelf.scanBlock(result);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }return _scanVINController;
}

- (SOSScanIDCardViewController *)scanIDCardController
{
    SOSWeakSelf(weakSelf);
    if (!_scanIDCardController) {
        _scanIDCardController = [[SOSScanIDCardViewController alloc] init];
        _scanIDCardController.avaudioScanIDCardFront = self.scanIDCardFront;
        [_scanIDCardController setScanIDCardBlock:^(SOSScanResult * result){
            if (weakSelf.scanBlock) {
                weakSelf.scanBlock(result);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _scanIDCardController;
}
//扫vin&身份证
- (void)scanAllType
{
    [self.titleView setTitle:@[@"车辆识别码",@"身份证"]];
    [self.titleView setupViewControllerWithFatherVC:self childVC:@[self.scanVINController,self.scanIDCardController]];
    [self.view addSubview:self.titleView];

}
//扫vin
- (void)justScanVIN
{
    
    [self addChildViewController:self.scanVINController];
    [self willMoveToParentViewController:self.scanVINController];
    [self.view addSubview:self.scanVINController.view];
    
}
//扫id
- (void)justScanIDCard
{
    
    [self addChildViewController:self.scanIDCardController];
    [self willMoveToParentViewController:self.scanIDCardController];
    [self.view addSubview:self.scanIDCardController.view];
}
- (void)setupUI
{
    //返回按钮
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _backBtn.frame = CGRectMake(self.view.frame.size.width -60, 40, 30, 30);
    [backBtn setImage:[UIImage imageNamed:@"ImageResource.bundle/back_btn"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    backBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    [self.view addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view.mas_trailing).offset(-30);
        make.top.equalTo(@60);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    //title
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectNull];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    if (self.currentType == ScanALLType) {
        titleLabel.text = @"扫描车辆识别码/身份证";
    }
    else
    {
        if (self.currentType == ScanIDCard) {
            titleLabel.text = @"扫描身份证";
        }
        else
        {
            titleLabel.text = @"扫描车辆识别码";
        }
    }

    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    titleLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self.view addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(self.view.width - 130);
        make.top.equalTo(self.view.mas_top).offset(self.view.height/2);
        make.width.equalTo(@200);
        make.height.equalTo(@30);
    }];

}
- (void)backBtnClick {
    if (self.backFunctionID) {
        [SOSDaapManager sendActionInfo:self.backFunctionID];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)cameraViewController:(UIViewController *)viewController didFinishRecognizeCard:(NSDictionary *)resultInfo cardSDKType:(ISOpenPreviewSDKType)sdkType;//相机模块识别结果回调
{
    
}
- (void)cameraViewController:(UIViewController *)viewController didClickCancelButton:(id)sender;//相机模块返回按钮点击回调
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (SOSSegmentView *)titleView{
    if (!_titleView) {
        _titleView = [[SOSSegmentView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }
    return _titleView;
}
//- (void)viewWillAppear:(BOOL)animated
//{
//    [UIApplication sharedApplication].statusBarHidden = YES;
//}
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [UIApplication sharedApplication].statusBarHidden = NO;
//}
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
