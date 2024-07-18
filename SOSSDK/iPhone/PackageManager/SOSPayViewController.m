//
//  SOSPayViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/7/4.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPayViewController.h"
#import "PackageUtil.h"
#import "SOSLoginUserDbService.h"
@interface SOSPayViewController ()
@property(nonatomic,strong)NSArray * channels;
//@property(nonatomic,strong)NSString * lastSelectChannel;
//@property(nonatomic,strong)NSIndexPath * selectChannelPath;
- (void)setPayPrice:(NSString *)price packageName:(NSString *)packageName payChannel:(NSInteger)channel;
@end

@implementation SOSPayViewController
- (instancetype)initWithPackage:(PackageInfos *)package
{
    self = [super init];
    if (self) {
        _package = package;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.4f;
    [self.view addSubview:_backgroundView];
    
    NSArray *nib = [[NSBundle SOSBundle] loadNibNamed:@"SurePayView"owner:self options:nil];
    _surePayView = [nib objectAtIndex:0];
    CGRect rect = _surePayView.frame;
    rect.origin.y = SCREEN_HEIGHT * 0.28;
    rect.size.width = SCREEN_WIDTH * 0.95;
    rect.origin.x = (SCREEN_WIDTH-rect.size.width)/2;
    _surePayView.frame = rect;
    _surePayView.layer.cornerRadius = 3.0;
    _surePayView.layer.masksToBounds = YES;
    _surePayView.surePayDelegate = self;
    [self.view addSubview:_surePayView];
    [self setPayPrice:_package.actualPrice packageName:_package.packageName payChannel:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    tap.numberOfTapsRequired = 1;
    [_backgroundView addGestureRecognizer:tap];
    
    [self setPayChannel:@"苹果支付"];
    [_surePayView channelLoadAlreadyState];
}
- (void)setPayChannel:(NSString *)channelName
{
    _surePayView.payWayLB.text = channelName;
}
- (void)setPayPrice:(NSString *)price packageName:(NSString *)packageName payChannel:(NSInteger)channel
{
    _surePayView.priceLB.text = [price doubleValue] == 0 ? @"￥ 0" : [NSString stringWithFormat:@"￥ %.2f",[price doubleValue]];
    _surePayView.NameLB.text = packageName;
    _surePayView.payWayLB.text = nil;
}

#pragma mark ---delegate
- (void)backFromSurePayVC
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)surePay
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    if (_payDelegate && [_payDelegate respondsToSelector:@selector(payClick:)]) {
        //        [_payDelegate payClick:[self channelStringToEnum:_lastSelectChannel]];
        [_payDelegate payClick:PayChannelVoid];
        if ([_package.packageType isEqualToString:@"CORE"]) {
            [SOSDaapManager sendActionInfo:servicepackage_purchase_confirm_iap];
            
        }else{
            [SOSDaapManager sendActionInfo:Datapackage_purchase_confirm];
        }
    }
}
- (void)selectPayWay_surePayDelegate
{
    //    [self pushToChannelSelect];
}

#pragma mark ---
- (void)tapGestureRecognizer:(UITapGestureRecognizer *)recognizer{
    if ([_package.packageType isEqualToString:@"CORE"]) {
        [SOSDaapManager sendActionInfo:servicepackage_purchase_confirm_close];

    }else{
        [SOSDaapManager sendActionInfo:Datapackage_purchase_close];
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

