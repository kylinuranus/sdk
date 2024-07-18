//
//  SOSVerifyPersionInfoView.m
//  Onstar
//
//  Created by Coir on 12/03/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSVerifyPersonInfoView.h"
#import <JhtMarquee/JhtHorizontalMarquee.h>

@interface SOSVerifyPersonInfoView ()
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@end

@implementation SOSVerifyPersonInfoView

- (void)awakeFromNib	{
    [super awakeFromNib];
}

- (void)setPageType:(SOSVerifyType)pageType		{
    _pageType = pageType;
    switch (pageType) {
        ///个人信息
        case SOSVerifyTypePersonInfo:	{
            JhtHorizontalMarquee *label = [[JhtHorizontalMarquee alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 20 - 40, 50) withSingleScrollDuration:5];
            label.text = [NSString stringWithFormat:@"%@          ",self.verifyTip];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor colorWithHexString:@"FDBC0C"];
            [label marqueeOfSettingWithState:MarqueeStart_H];
            [self insertSubview:label belowSubview:self.verifyButton];
            UIImageView *arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right_yellow"]];
            arrowImgView.frame = CGRectMake(SCREEN_WIDTH - arrowImgView.width - 10, (self.height - arrowImgView.height) / 2, arrowImgView.width, arrowImgView.height);
            [self insertSubview:arrowImgView belowSubview:self.verifyButton];
            break;
        }
        ///星用户信息
        case SOSVerifyTypeStarInfo:	{
            self.backgroundColor = [UIColor colorWithHexString:@"E8EBEE"];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 40, 60)];

            label.text = self.verifyTip;
            label.textColor = [UIColor colorWithHexString:@"3A7DD9"];
            label.numberOfLines = 2;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            [self addSubview:label];
            self.verifyButton.hidden = YES;
            break;
        }
        default:
            break;
    }
}

- (IBAction)verifyPersonInfo {
    if (self.verURI) {
        NSString *idpUserID = [[CustomerInfo sharedInstance].userBasicInfo.idpUserId md5String];
        if (idpUserID.length)     UserDefaults_Set_Object(@{idpUserID : @(NO)}, KShouldNoticeVerifyPersionInfo);
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:self.verURI];
        [self.nav pushViewController:vc animated:YES];
    }
    
}


@end
