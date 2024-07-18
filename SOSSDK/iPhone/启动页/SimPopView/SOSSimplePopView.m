//
//  SOSYearReportView.m
//  Onstar
//
//  Created by WQ on 2019/1/9.
//  Copyright © 2019年 Shanghai Onstar. All rights reserved.
//

#import "SOSSimplePopView.h"
#import "UIImageView+WebCache.h"

@interface SOSSimplePopView (){
    NSDictionary * configDic;
}
@end

@implementation SOSSimplePopView

+(SOSSimplePopView*)instanceView
{
    NSLog(@"instanceView");
    NSArray *arr = [[NSBundle SOSBundle] loadNibNamed:@"SOSSimplePopView" owner:self options:nil];
    return arr[0];
}
///[{"description":"车联行业报告","popupCode":"AUTO_INDUSTRY_REPORT","popupContent":"neirong","popupImg":"https://m-idt6.onstar.com.cn/emip/idt6/yearreport/yaerReport2019.png","reportUrl":"http://www.baidu.com"}]
-(void)configWithDic:(NSDictionary *)model{
    if (model) {
        configDic = model.copy;
        [self.displayImage sd_setImageWithURL:[configDic objectForKey:@"popupImg"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"sos_%@",[configDic objectForKey:@"popupCode"]]]];
    }
    
    [self.displayImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked)]];
}


- (void)imageClicked {
    [self removeFromSuperview];
    NSString * content = [configDic objectForKey:@"reportUrl"];
    if (content) {
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:content];
        [(UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
        if (_clickFunctionID) {
            [SOSDaapManager sendActionInfo:_clickFunctionID];
        }
    }
}
- (IBAction)closeOnPress:(UIButton *)sender {
    [self removeFromSuperview];
    if (_closeFunctionID) {
        [SOSDaapManager sendActionInfo:_closeFunctionID];
    }
    if (self.dismissComplete) {
        self.dismissComplete();
    }
}

@end
