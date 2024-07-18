//
//  SOSRouteInfoView.m
//  Onstar
//
//  Created by Coir on 2019/4/16.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSRouteInfoView.h"

@interface SOSRouteInfoView ()

@property (weak, nonatomic) IBOutlet UIView *flagView;
@property (weak, nonatomic) IBOutlet UILabel *routeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *minusLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *minusUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeLengthLabel;
@property (weak, nonatomic) IBOutlet UIView *unReachableBGView;
@property (weak, nonatomic) IBOutlet UILabel *errorTextLabel;

@end

@implementation SOSRouteInfoView

- (void)setViewHilighted:(BOOL)viewHilighted	{
    _viewHilighted = viewHilighted;
    dispatch_async_on_main_queue(^{
        self.backgroundColor = viewHilighted ? [UIColor colorWithHexString:@"F8FAFF"] : [UIColor whiteColor];
        self.flagView.backgroundColor = [UIColor colorWithHexString:viewHilighted ? @"6896ED" : @"C3CEEC"];
        self.routeTitleLabel.textColor = self.flagView.backgroundColor;
        
        self.minusLabel.textColor = [UIColor colorWithHexString:viewHilighted ? @"304D8F" : @"A4A4A4"];
        self.hoursLabel.textColor = self.minusLabel.textColor;
        self.minusUnitLabel.textColor = self.minusLabel.textColor;
        self.hoursUnitLabel.textColor = self.minusLabel.textColor;
        
        self.routeLengthLabel.textColor = [UIColor colorWithHexString:viewHilighted ? @"828389" : @"CFCFCF"];
    });
}

- (IBAction)viewTapped {
    if (self.viewHilighted == YES || self.routeInfo == nil) 		return;
    __weak __typeof(self) weakSelf = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewTappedWithView:)]) {
        [self.delegate viewTappedWithView:weakSelf];
    }
}

- (void)setRouteInfo:(SOSRouteInfo *)routeInfo	{
    _routeInfo = routeInfo;
    dispatch_async_on_main_queue(^{
        if (routeInfo) {
            self.unReachableBGView.hidden = YES;
            if (routeInfo.routeTime > 60) {
                self.minusLabel.text = @(routeInfo.routeTime % 60).stringValue;
                self.hoursLabel.text = @(routeInfo.routeTime / 60).stringValue;
                self.minusUnitLabel.text = @"分钟";
                self.hoursUnitLabel.text = @"小时";
            }    else    {
                self.minusLabel.text = @(routeInfo.routeTime).stringValue;
                self.minusUnitLabel.text = @"分钟";
                self.hoursLabel.text = @"";
                self.hoursUnitLabel.text = @"";
            }
            if (routeInfo.routeLength > 1000) {
                self.routeLengthLabel.text = [NSString stringWithFormat:@"%.1f公里", routeInfo.routeLength / 1000.f];
            }    else    {
                self.routeLengthLabel.text = [NSString stringWithFormat:@"%@米", @(routeInfo.routeLength)];
            }
        }	else	{
            // 无法到达
            self.unReachableBGView.hidden = NO;
            self.viewHilighted = NO;
        }
    });
}

- (void)setTitle:(NSString *)title	{
    _title = title;
    dispatch_async_on_main_queue(^{
        self.routeTitleLabel.text = title;
        if (title.length == 0) {
            self.hidden = YES;
        }
    });
}

@end
