//
//  SliderBar.m
//  Onstar
//
//  Created by Joshua on 15-4-8.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "SliderBar.h"

@implementation SliderBar     {
    CaclulateDateModel * caclulateModel;
}

- (IBAction)selectDidChange:(UISlider *)sender     {
    caclulateModel.caclulateDateCount = [NSString stringWithFormat:@"%d",(int)sender.value];
    
    if([caclulateModel.caclulateDateTitle isEqualToString:@"收发电子邮件"])
    {
        if (caclulateModel.caclulateDateCount.intValue % 20 > 0) {
            sender.value = ((int)caclulateModel.caclulateDateCount.integerValue/20  + 1) * 20;
            caclulateModel.caclulateDateCount = [NSString stringWithFormat:@"%d",(int)sender.value];
        }
        self.valueLabel.text = [NSString stringWithFormat:@"%@%@",caclulateModel.caclulateDateCount,caclulateModel.caclulateDateUnit] ;
    }
    else
    {
        self.valueLabel.text = [NSString stringWithFormat:@"%@%@",caclulateModel.caclulateDateCount,caclulateModel.caclulateDateUnit];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self.target respondsToSelector:@selector(caclulateDate)]) {
        [self.target performSelector:@selector(caclulateDate)];
    }
#pragma clang diagnostic pop
}

- (void)reloadWithCaclulateDateModel:(CaclulateDateModel *) model     {
    self.subTitleLabel.hidden = YES;
    caclulateModel = model;

    if ([caclulateModel.caclulateDateTitle isEqualToString:@"设备数"]) {
        self.slider.maximumValue = 10;
    }
    else if([caclulateModel.caclulateDateTitle isEqualToString:@"视频"])
    {
        self.slider.maximumValue = 10;
    }
    else if([caclulateModel.caclulateDateTitle isEqualToString:@"音乐"])
    {
        self.slider.maximumValue = 20;
    }
    else if([caclulateModel.caclulateDateTitle isEqualToString:@"收发电子邮件"])
    {
        //0 - 200 封/天;   每格20封
        self.slider.maximumValue = 200;
    }
    else if([caclulateModel.caclulateDateTitle isEqualToString:@"下载应用"])
    {
        self.slider.maximumValue = 20;
    }
    else
    {
        self.slider.maximumValue = 24;
    }

    self.titleLabel.text = caclulateModel.caclulateDateTitle;
    self.subTitleLabel.text = caclulateModel.caclulateDateSmailTitle;
//    self.unitLabel.text = caclulateModel.caclulateDateUnit;

    if([caclulateModel.caclulateDateTitle isEqualToString:@"收发电子邮件"])
    {
        int xiaoshu = 0;
        if (caclulateModel.caclulateDateCount.intValue % 20 > 0) {
            xiaoshu = 1;
        }
        self.valueLabel.text = [NSString stringWithFormat:@"%d%@",((int)caclulateModel.caclulateDateCount.integerValue/20  + xiaoshu) * 20,caclulateModel.caclulateDateUnit];
    }
    else
    {
        self.valueLabel.text = [NSString stringWithFormat:@"%@%@",caclulateModel.caclulateDateCount,caclulateModel.caclulateDateUnit];
    }
    
    self.slider.value = caclulateModel.caclulateDateCount.floatValue;
}

@end
