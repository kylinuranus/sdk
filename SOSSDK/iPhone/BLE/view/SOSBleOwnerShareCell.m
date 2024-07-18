//
//  SOSBleOwnerShareCell.m
//  Onstar
//
//  Created by onstar on 2018/7/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleOwnerShareCell.h"
#import "UIView+FDCollapsibleConstraints.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "SOSBleUtil.h"
#import "SOSBleCarInfoView.h"

////未过期的钥匙
//typedef NS_ENUM(NSUInteger, SOSBleAuthorStatus) {
//    SOSBleAuthorStatus_New,
//    SOSBleAuthorStatus_ACCEPTED,
//    SOSBleAuthorStatus_APPROVED,
//    SOSBleAuthorStatus_GRANTED,
//    SOSBleAuthorStatus_VALID,
//    SOSBleAuthorStatus_INUSE
//};


@interface SOSBleOwnerShareCell ()
@property (weak, nonatomic) IBOutlet UILabel *titlLable;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UIView *authorDateBgView;
@property (weak, nonatomic) IBOutlet UILabel *startYmdLabel;
@property (weak, nonatomic) IBOutlet UILabel *endYmdLabel;
@property (weak, nonatomic) IBOutlet UILabel *startHmLabel;
@property (weak, nonatomic) IBOutlet UILabel *endHmLabel;
@property (weak, nonatomic) IBOutlet UIButton *operationButton;

@property (weak, nonatomic) IBOutlet UIView *bleCarInfoContainerView;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (nonatomic, strong)   SOSBleCarInfoView *carInfoView;
@end

@implementation SOSBleOwnerShareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _carInfoView = [SOSBleCarInfoView viewFromXib];
    [self.bleCarInfoContainerView addSubview:_carInfoView];
    [_carInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bleCarInfoContainerView);
    }];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAuthorEntity:(SOSAuthorDetail *)authorEntity ownerSharePage:(BOOL)ownerStatus
{
    NSString *status = authorEntity.authorizationStatus;
    BOOL validStatus = [SOSBleUtil authorValid:status];//有效状态 //历史记录状态
    
    
    
    BOOL tempStatus = [authorEntity.authorizationType isEqualToString:@"TEMP"];
    NSDictionary *statusMsg = @{
                                @"NEW":@{
                                        @"subTitle":@"待接受,请在30min内完成共享授权",
                                        @"hideCarInfo":@(ownerStatus),
                                        @"hideTitleLabel":@(!ownerStatus),
                                        @"hideDate":@(validStatus),
                                        @"hideDateContent":@(!tempStatus),
                                        @"hideButton":@(tempStatus),
                                        @"buttonTitle":@"出示二维码",
                                        @"SEL":NSStringFromSelector(@selector(showQrPageWithAuthorInfo:))
                                        },
                                @"ACCEPTED":@{
                                        @"subTitle":@"已接受,请在30min内确认共享授权",
                                        @"hideCarInfo":@(ownerStatus),
                                         @"hideTitleLabel":@(!ownerStatus),
                                        @"hideDate":@(validStatus),
                                        @"hideDateContent":@(!tempStatus),
                                        @"hideButton":@(NO),
                                        @"buttonTitle":@"确认授权",
                                        @"SEL":NSStringFromSelector(@selector(ownerAcceptShareWithAuthorInfo:))
                                        },
                                @"APPROVED":@{
                                        @"subTitle":@"共享授权时段未到",//已批准
                                        @"hideCarInfo":@(ownerStatus),
                                         @"hideTitleLabel":@(!ownerStatus),
                                        @"hideDate":@(validStatus),
                                        @"hideDateContent":@(!tempStatus),
                                        @"hideButton":@(true),
                                        @"buttonTitle":@"",
                                        },
                                @"GRANTED":@{
                                        @"subTitle":@"钥匙已下载，待时间生效",///
                                        @"hideCarInfo":@(ownerStatus),
                                         @"hideTitleLabel":@(!ownerStatus),
                                        @"hideDate":@(validStatus),
                                        @"hideDateContent":@(!tempStatus),
                                        @"hideButton":@(true),
                                        @"buttonTitle":@"",
                                        },
                                @"VALID":@{
                                        @"subTitle":@"共享授权时段已到,钥匙未下载",
                                        @"hideCarInfo":@(ownerStatus),
                                         @"hideTitleLabel":@(!ownerStatus),
                                        @"hideDate":@(validStatus),
                                        @"hideDateContent":@(!tempStatus),
                                        @"hideButton":@(true),
                                        @"buttonTitle":@"",
                                        },
                                @"INUSE":@{
                                        @"subTitle":@"使用中",
                                        @"hideCarInfo":@(ownerStatus),
                                         @"hideTitleLabel":@(!ownerStatus),
                                        @"hideDate":@(validStatus),
                                        @"hideDateContent":@(!tempStatus),
                                        @"hideButton":@(true),
                                        @"buttonTitle":@"",
                                        },
                                @"CLOSED":@{
                                        @"subTitle":@"共享授权已关闭",
                                        @"hideCarInfo":@(ownerStatus),
                                         @"hideTitleLabel":@(!ownerStatus),
                                        @"hideDate":@(validStatus),
                                        @"hideDateContent":@(!tempStatus),
                                        @"hideButton":@(true),
                                        @"buttonTitle":@"",
                                        },
                                @"EXPIRED":@{
                                        @"subTitle":@"共享授权已过期",
                                        @"hideCarInfo":@(ownerStatus),
                                         @"hideTitleLabel":@(!ownerStatus),
                                        @"hideDate":@(validStatus),
                                        @"hideDateContent":@(!tempStatus),
                                        @"hideButton":@(true),
                                        @"buttonTitle":@"",
                                        },
                                @"INVALID":@{
                                        @"subTitle":@"共享授权已失效",
                                        @"hideCarInfo":@(ownerStatus),
                                         @"hideTitleLabel":@(!ownerStatus),
                                        @"hideDate":@(validStatus),
                                        @"hideDateContent":@(!tempStatus),
                                        @"hideButton":@(true),
                                        @"buttonTitle":@"",
                                        },
                                @"CANCELLED":@{
                                        @"subTitle":@"共享授权已放弃",
                                        @"hideCarInfo":@(ownerStatus),
                                         @"hideTitleLabel":@(!ownerStatus),
                                        @"hideDate":@(validStatus),
                                        @"hideDateContent":@(!tempStatus),
                                        @"hideButton":@(true),
                                        @"buttonTitle":@"",
                                        }
                                };
    NSDictionary *statusDic = [statusMsg objectForKey:status];
    
    self.subTitleLabel.text = [statusDic objectForKey:@"subTitle"];
    BOOL hideCarInfo = [[statusDic objectForKey:@"hideCarInfo"] boolValue];
    BOOL hideDate = [[statusDic objectForKey:@"hideDate"] boolValue];
    BOOL hideDateContent = [[statusDic objectForKey:@"hideDateContent"] boolValue];
    BOOL hideButton = [[statusDic objectForKey:@"hideButton"] boolValue];
    BOOL hideTitleLabel = [[statusDic objectForKey:@"hideTitleLabel"] boolValue];

    NSString *buttonTitle = [statusDic objectForKey:@"buttonTitle"];
    self.titlLable.fd_collapsed = hideTitleLabel;
    self.phoneLabel.fd_collapsed = hideTitleLabel;
    self.operationButton.fd_collapsed = hideButton;
    self.operationButton.hidden = hideButton;//不写有跟线,莫名其妙
    self.bleCarInfoContainerView.fd_collapsed = hideCarInfo;
    self.authorDateBgView.fd_collapsed = hideDateContent;
    self.createDateLabel.fd_collapsed = hideDate;

    BOOL valid = [SOSBleUtil authorValid:authorEntity.authorizationStatus];
    BOOL acceptUser = authorEntity.userId.isNotBlank && authorEntity.mobilePhone.isNotBlank;
    self.actionButton.hidden = !acceptUser && !valid;
    if (!hideTitleLabel) {
        self.titlLable.text = [self contentTitleWithAuthorEntity:authorEntity];
        self.phoneLabel.text = authorEntity.mobilePhone?[SOSBleUtil formatPhone:authorEntity.mobilePhone]:@"";
    }
    
    if (!hideCarInfo) {
        if (authorEntity.vin.isNotBlank) {
//            NSString *vinLastSix = [authorEntity.vin substringFromIndex:authorEntity.vin.length-6];
//            self.carInfoView.vinLabel.text = [NSString stringWithFormat:@"VIN SGM******%@",vinLastSix];
            self.carInfoView.vinLabel.text = [SOSBleUtil recodesign:authorEntity.vin];
        }else {
            self.carInfoView.vinLabel.text = @"";
        }
        //username mobilephone
        self.carInfoView.carTypeLabel.text = [NSString stringWithFormat:@"%@ %@",[self contentTitleWithAuthorEntity:authorEntity],[SOSBleUtil formatPhone:authorEntity.mobilePhone]?:@""];
    }
    if (!hideDate) {
        NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:[authorEntity.createTime doubleValue]/1000];
        self.createDateLabel.text = [createDate stringWithFormat:@"yyyy年MM月dd日 HH:mm"];
    }
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
        NSString *sel = [statusDic objectForKey:@"SEL"];
        SEL selector = NSSelectorFromString(sel);
        [self.operationButton setTitle:buttonTitle forState:UIControlStateNormal];
        [self.operationButton setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            if ([self.viewController respondsToSelector:selector]) {
                [self.viewController performSelector:selector withObject:authorEntity];
            }
        }];
    }else {
        [self.operationButton removeAllTargets];
    }
    
}


- (NSInteger)mapingStatus:(NSString *)status
{
    NSArray * statuss = @[@"NEW",@"ACCEPTED",@"APPROVED",@"GRANTED"];
    return [statuss indexOfObject:status];
}


- (IBAction)moreButtonTaped:(id)sender {
    !self.operationButtonTapBlock?:self.operationButtonTapBlock();
}

- (NSString *)contentTitleWithAuthorEntity:(SOSAuthorDetail *)authorEntity {
    if (authorEntity.userId.isNotBlank) {
        
        NSString *userName = [self displayUserName:authorEntity.userName.isNotBlank?authorEntity.userName:authorEntity.userId];
        return userName;
        
    }else {
        return @"新共享";
    }
    return @"";
}

- (NSString *)displayUserName:(NSString *)userName {
    NSInteger sum = 0;
    NSInteger to = 0;
    for (int i=0; i<userName.length; i++) {
        unichar strChar = [userName characterAtIndex:i];
        if (strChar < 256) {
            sum+=1;
        }else {
            sum+=2;
        }
        if (sum>8) {
            to = i;
            break;
        }
    }
    if (sum<=8) {
        return userName;
    }
    userName = [userName substringToIndex:to];
    return [NSString stringWithFormat:@"%@...",userName];
}

@end
