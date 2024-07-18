//
//  SOSBleUserShareCell.m
//  Onstar
//
//  Created by onstar on 2018/7/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleUserShareCell.h"
#import "SOSBleUtil.h"
#import "UIView+FDCollapsibleConstraints.h"

@interface SOSBleUserShareCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *vinLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@property (weak, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (weak, nonatomic) IBOutlet UIButton *operatButton;
@property (weak, nonatomic) IBOutlet UIView *tempDateContentView;
@property (weak, nonatomic) IBOutlet UILabel *startYmdLabel;
@property (weak, nonatomic) IBOutlet UILabel *endYmdLabel;
@property (weak, nonatomic) IBOutlet UILabel *startHmLabel;
@property (weak, nonatomic) IBOutlet UILabel *endHmLabel;
@end

@implementation SOSBleUserShareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setAuthorEntity:(SOSAuthorDetail *)authorEntity {
    _authorEntity = authorEntity;
//    NSString *status = authorEntity.authorizationStatus;
    NSString *status = [SOSBleUtil realStatusWithAuthorEntity:authorEntity];
    BOOL temp = [authorEntity.authorizationType isEqualToString:@"TEMP"];
    NSDictionary *statusMsg = @{
                                @"ACCEPTED":@{
                                        @"statusTitle":@"已接受,等待车主确认",
                                        @"hideDateContent":@(!temp),
                                        @"hideButton":@(YES),
                                        @"hideDownloadImage":@(YES),
                                        @"hideStatusImage":@(YES),
                                        @"statusImageName":@"",
                                        @"buttonTitle":@"",
                                        @"SEL":@""
                                        },
                                @"APPROVED":@{//已批准 钥匙等待下载 未生效
                                        @"statusTitle":temp?@"临时共享未开始":@"永久共享未开始",
                                        @"hideDateContent":@(!temp),
                                        @"hideButton":@(NO),
                                        @"hideDownloadImage":@(YES),
                                        @"hideStatusImage":@(NO),
                                        @"statusImageName":@"icon_alert_orange_idle_25x25",//
                                        @"buttonTitle":@"下载钥匙",
                                        @"SEL":NSStringFromSelector(@selector(downloadKeyWithAuthorInfo:complete:))
                                        },
                                @"GRANTED":@{//已下载未生效 **********
                                        @"statusTitle":temp?@"临时共享未开始":@"永久共享未开始",
                                        @"hideDateContent":@(!temp),
                                        @"hideButton":@(YES),
                                        @"hideDownloadImage":@(NO),
                                        @"hideStatusImage":@(NO),
                                        @"statusImageName":@"icon_alert_orange_idle_25x25",
                                        @"buttonTitle":@"",
                                        @"SEL":@""
                                        },
                                @"VALID":@{//未下载  已生效
                                        @"statusTitle":temp?@"正在临时共享":@"正在永久共享",
                                        @"hideDateContent":@(!temp),
                                        @"hideButton":@(NO),
                                        @"hideDownloadImage":@(YES),
                                        @"hideStatusImage":@(NO),
                                        @"statusImageName":@"套餐_icon_nav_correct_idle",
                                        @"buttonTitle":@"获取并连接",
                                        @"SEL":NSStringFromSelector(@selector(downloadKeyThenToBlePageWithAuthorInfo:))
                                        },
                                @"INUSE":@{//已下载 已生效
                                        @"statusTitle":temp?@"正在临时共享":@"正在永久共享",
                                        @"hideDateContent":@(!temp),
                                        @"hideButton":@(NO),
                                        @"hideDownloadImage":@(NO),
                                        @"hideStatusImage":@(NO),
                                        @"statusImageName":@"套餐_icon_nav_correct_idle",
                                        @"buttonTitle":@"连接",
                                        @"SEL":NSStringFromSelector(@selector(routerToBlePage:))
                                        },
                           
                                };
    NSDictionary *statusDic = [statusMsg objectForKey:status];
    BOOL hideDateContent = [[statusDic objectForKey:@"hideDateContent"] boolValue];
    BOOL hideButton = [[statusDic objectForKey:@"hideButton"] boolValue];
    BOOL hideDownloadImage = [[statusDic objectForKey:@"hideDownloadImage"] boolValue];
    BOOL hideStatusImage = [[statusDic objectForKey:@"hideStatusImage"] boolValue];
    NSString *statusTitle = [statusDic objectForKey:@"statusTitle"];

    
    self.ownerLabel.text = authorEntity.userName?:@"";
    self.phoneLabel.text = authorEntity.mobilePhone?[SOSBleUtil formatPhone:authorEntity.mobilePhone]:@"";
    self.vinLabel.text =  [SOSBleUtil recodesign:authorEntity.vin];
    self.statusLabel.text = statusTitle;
    self.tempDateContentView.fd_collapsed = hideDateContent;
    self.operatButton.fd_collapsed = hideButton;
    self.downloadImageView.fd_collapsed = hideDownloadImage;
    self.statusImageView.fd_collapsed = hideStatusImage;
    
    if (!hideDateContent) {
        //起止时间
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[authorEntity.startTime doubleValue]/1000];
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[authorEntity.endTime doubleValue]/1000];
        NSArray *startTimeAry = [[startDate stringWithFormat:@"yyyy/MM/dd HH:mm"] componentsSeparatedByString:@" "];
        NSArray *endTimeAry = [[endDate stringWithFormat:@"yyyy/MM/dd HH:mm"] componentsSeparatedByString:@" "];
        
        self.startYmdLabel.text = startTimeAry.firstObject;
        self.startHmLabel.text = startTimeAry.lastObject;
        self.endYmdLabel.text = endTimeAry.firstObject;
        self.endHmLabel.text = endTimeAry.lastObject;
    }
    if (!hideButton) {
        NSString *buttonTitle = [statusDic objectForKey:@"buttonTitle"];
        NSString *sel = [statusDic objectForKey:@"SEL"];
        SEL selector = NSSelectorFromString(sel);
        [self.operatButton setTitle:buttonTitle forState:UIControlStateNormal];
        [self.operatButton setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            if ([self.viewController respondsToSelector:selector]) {
                [self.viewController performSelector:selector withObject:authorEntity];
            }
        }];
    }
    
    if (!hideStatusImage) {
        NSString *statusImageName = [statusDic objectForKey:@"statusImageName"];
        self.statusImageView.image = [UIImage imageNamed:statusImageName];
    }
    
}
- (IBAction)operationButtonTaped:(id)sender {
    !self.operationButtonTapBlock?:self.operationButtonTapBlock();
}

@end
