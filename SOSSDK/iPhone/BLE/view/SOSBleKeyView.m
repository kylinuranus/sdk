//
//  SOSBleKeyView.m
//  Onstar
//
//  Created by onstar on 2018/7/19.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleKeyView.h"
#import <BlePatacSDK/BlueToothManager.h>
#import "BlueToothManager+SOSBleExtention.h"

@implementation SOSBleKeyView

- (IBAction)operationButtonTaped:(UIButton *)sender {
    if ([BlueToothManager sharedInstance].bleOperationVar.operating) {
        [Util toastWithMessage:@"您的操作太频繁"];
        return;
    }
    
//    !self.operationBlock?:self.operationBlock(sender);
    int funcid = sender.tag;
     [BlueToothManager bleSendOperation:funcid];
    if (sender.tag == 8) {
        sender.selected = !sender.selected;
        
        funcid = 0x13;
        if (sender.selected) {
            funcid = 0x0D;
            [[BlueToothManager sharedInstance].bleOperationVar startTimer];
            
        }else {
            [[BlueToothManager sharedInstance].bleOperationVar stopTiming];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadBleCard" object:@YES];
            
        }
    }else {
        [BlueToothManager sharedInstance].bleOperationVar.operating = YES;
    }
    
    
    [[BlueToothManager sharedInstance] SendCommand:funcid result:^(SendState state) {
        
        if (state ==SendSucessful ) {
            
            
        }else {
             NSString *operationName = [self operationNameWithCode:funcid];
            [Util toastWithMessage:[NSString stringWithFormat:@"%@操作失败,请稍后重试",operationName]];
            [BlueToothManager sharedInstance].bleOperationVar.operating = NO;
        }
    }];
}

- (NSString *)operationNameWithCode:(int)code {
    NSString *operationName = @"";
    if(code == 3 )
    {
        operationName = @"车门解锁";
        
        
    }else if(code == 0x0D)
    {
        
        operationName = @"允许启动";
    }
    
    else if(code == 4)
    {
        operationName = @"打开后备箱";
    }
    
    if(code == 1 )
    {
        operationName = @"车门上锁";
    }
    
    
    if(code == 0x13 )
    {
        operationName = @"关闭允许启动";
    }
    return operationName;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOSBleTimerNotificationName object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self changeStartStatus];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"reloadBleCard" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        //刷新cell
//        dispatch_async_on_main_queue(^{
//           [self changeStartStatus];
//        });
        BOOL status = [x.object boolValue];
        if (status) {
            self.startButton.selected = NO;
        }else {
            self.startButton.selected = YES;
        }
        self.titleLabel.text = @"允许启动";
    }];
    
}

- (void)changeStartStatus {
    dispatch_async_on_main_queue(^{
        int time = [BlueToothManager sharedInstance].bleOperationVar.seconds;
        NSLog(@"time == %d",time);
        NSString *timeText = @"10:00";
        if (time>0 && [BlueToothManager sharedInstance].bleOperationVar -> _timer) {
            //        &&time<60) {
            //        timeText = [NSString stringWithFormat:@"%2ld秒",(long)time];
            //    }else if (time>60) {
            timeText = [NSString stringWithFormat:@"%02d:%02d",time/60, time%60];
        }else if (time <= 0) {
            self.titleLabel.text = @"允许启动";
            self.startButton.selected = NO;
            return;
        }
        self.startButton.selected = YES;
        self.titleLabel.text = [NSString stringWithFormat:@"允许启动\n%@",timeText];
        NSLog(@"BLEBLEBLEXXXXXXXX");
    });
    
}




@end
