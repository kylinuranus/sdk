//
//  SOSBleQRViewController.m
//  Onstar
//
//  Created by onstar on 2018/7/26.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleQRViewController.h"
#import "SOSBleUtil.h"

@interface SOSBleQRViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet UILabel *vinLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation SOSBleQRViewController
{
    NSInteger time;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"永久共享";
//    NSDictionary *params = [SOSBleUtil getUrlParamsWithUrl:[NSURL URLWithString:_qrUrl]];
    NSString *vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin?:@"";
    
    self.vinLabel.text = [SOSBleUtil recodesign:vin];
    [self refreshQrImage];
    //每隔1秒执行一次
    //这里要加takeUntil条件限制一下否则当控制器pop后依旧会执行
    [[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        time--;
        if (time > 60) {
            _timeLabel.text = [NSString stringWithFormat:@"%d分钟后刷新",time/60+1];
        }else if (time <= 0) {
            [self refreshQrImage];
        }else {
            _timeLabel.text = [NSString stringWithFormat:@"%dS后刷新",time%60];
        }
    }];
    
   
}

- (void)refreshQrImage
{
    time = 300;
    self.activityView.hidden = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), (^{
        NSTimeInterval now = [NSDate date].timeIntervalSince1970*1000;
        NSString *params = [self.qrUrl componentsSeparatedByString:@"?"].lastObject;
        NSString *url = [NSString stringWithFormat:@"%@&time=%.0f",params,now];
        UIImage *qrImage = [SOSBleUtil creatCIQRCodeImageWithUrl:url centerImage: [UIImage imageNamed:@"pic_IMG_60x60"]];
        dispatch_async_on_main_queue(^{
            self.activityView.hidden = YES;
            self.qrImageView.image = qrImage;
        });
    }));
    
}

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
