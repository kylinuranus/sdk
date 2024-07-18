//
//  SOSMyDonateVC.m
//  Onstar
//
//  Created by Coir on 2018/9/13.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSDonateProjectView.h"
#import "SOSDonateDataTool.h"
#import "NavigateShareTool.h"
#import "SOSDateFormatter.h"
#import "SOSMyDonateVC.h"
#import "LoadingView.h"

@interface SOSMyDonateVC ()	<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *navBGView;
@property (weak, nonatomic) IBOutlet UIButton *navBackButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *scrollBGImgView;
@property (weak, nonatomic) IBOutlet UIImageView *userLevelImgView;
@property (weak, nonatomic) IBOutlet UILabel *userLevelZeroNoticeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDonateEnergyLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalGainedNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainEnergyNumLabel;

@property (weak, nonatomic) IBOutlet UIView *activityContentView;
@property (weak, nonatomic) IBOutlet UILabel *activityTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityContentViewHeightGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBGViewTopGuide;
@property (strong, nonatomic) NSMutableArray <SOSDonateDataObj *> *dataArray;

@property (strong, nonatomic) SOSDonateUserInfo *userInfo;

@property (assign, nonatomic) uint requestCount;

@end

@implementation SOSMyDonateVC

- (void)viewDidLoad 	{
    [super viewDidLoad];
    [self configSelf];
}

- (void)configSelf        {
    self.backDaapFunctionID = MyDonate_Back;
    self.fd_prefersNavigationBarHidden = YES;
    self.navBGViewTopGuide.constant = SystemVersion >= 11.0 ? 0 : 20;
    [[self.bgScrollView rac_valuesAndChangesForKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> * _Nullable x) {
        float offsetY = self.bgScrollView.contentOffset.y;
        offsetY = offsetY >= 0 ? offsetY : 0;
        float maxValue = 200.f;
        dispatch_async(dispatch_get_main_queue(), ^{
            float FAlpha = (offsetY >= maxValue) ? 1 : (offsetY / maxValue);
            self.navBGView.backgroundColor = [UIColor colorWithWhite:1 alpha:FAlpha];
            self.titleLabel.textColor = [UIColor colorWithWhite:MAX(.2, 1 - FAlpha) alpha:1];
            if (FAlpha >= .6) {
                self.navBackButton.selected = YES;
                self.shareButton.selected = YES;
            }	else	{
                self.navBackButton.selected = NO;
                self.shareButton.selected = NO;
            }
        });
    }];
    [self requestInfo];
}

- (void)requestInfo		{
    self.requestCount = 0;
    self.dataArray = [NSMutableArray array];
    [[LoadingView sharedInstance] startIn:self.bgScrollView];
    
    [SOSDonateDataTool getDonateInfoSuccess:^(SOSNetworkOperation *operation, id responseObj) {
        NSDictionary *responseDic = (NSDictionary *)responseObj;
        if ([responseDic isKindOfClass:[NSDictionary class]] && responseDic.count) {
            self.userInfo = [SOSDonateUserInfo mj_objectWithKeyValues:responseDic];
            [self configUserInfoView];
            [self handleSuccessData];
            return;
        }
        [[LoadingView sharedInstance] stop];
        [Util toastWithMessage:@"获取用户信息失败"];
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
        [Util toastWithMessage:@"获取用户信息失败"];
    }];
    [SOSDonateDataTool getActivityListSuccess:^(SOSNetworkOperation *operation, id responseObj) {
        NSArray *responseArr = (NSArray *)responseObj;
        if ([responseArr isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dataDic in responseArr) {
                SOSDonateDataObj *obj = [SOSDonateDataObj mj_objectWithKeyValues:dataDic];
                obj.ID = @([dataDic[@"id"] longLongValue]).stringValue;
                [self.dataArray addObject:obj];
            }
            [self configUserActivityView];
            [self handleSuccessData];
            return;
        }
        [[LoadingView sharedInstance] stop];
        [Util toastWithMessage:@"获取活动信息失败"];
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
        [Util toastWithMessage:@"获取活动信息失败"];
    }];
}

- (void)handleSuccessData	{
    self.requestCount++;
    if (self.requestCount >= 2) {
        [[LoadingView sharedInstance] stop];
        self.requestCount = 0;
    }
}

#pragma mark - button Action
- (IBAction)back {
    [SOSDaapManager sendActionInfo:MyDonate_Back];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareButtonTapped {
    [SOSDaapManager sendActionInfo:MyDonate_Share];
    self.scrollBGImgView.hidden = NO;
    UIGraphicsBeginImageContextWithOptions(self.bgScrollView.contentSize, NO, 0.0);
    [self.bgScrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *shareImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[NavigateShareTool sharedInstance] shareWithImg:shareImg andFunIDArray:@[MyDonate_Share_WeChatFriends, MyDonate_Share_WeChatMoment, MyDonate_Share_ShareCancel]];
    self.scrollBGImgView.hidden = YES;
}

- (void)configUserInfoView	{
    if (self.userInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            int userLevel = [self getUserLevelWithDonationIntegral];
            if (userLevel) {
                self.userLevelZeroNoticeLabel.hidden = YES;
                self.userLevelImgView.hidden = NO;
                self.userLevelImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"my_achievement_icon_star_medal_%@", @(userLevel)]];
            }	else	{
                self.userLevelZeroNoticeLabel.hidden = NO;
                self.userLevelImgView.hidden = YES;
            }
            self.totalDonateEnergyLabel.text = [NSString stringWithFormat:@"累计捐赠星能量 %@", self.userInfo.donationIntegral ? self.userInfo.donationIntegral : @"0"];
            self.totalGainedNumLabel.text = self.userInfo.earnIntegral ? self.userInfo.earnIntegral : @"0";
            self.remainEnergyNumLabel.text = self.userInfo.remainingIntegral ? self.userInfo.remainingIntegral : @"0";
        });
    }
}

- (int)getUserLevelWithDonationIntegral	{
    int donationIntegral = self.userInfo.donationIntegral.intValue;
    if (donationIntegral < 200) 									return 0;
    else if (donationIntegral >= 200 && donationIntegral < 600)		return 1;
    else if (donationIntegral >= 600 && donationIntegral < 1000)	return 2;
    else if (donationIntegral >= 1000)								return 3;
    
    return 0;
}

- (void)configUserActivityView	{
    dispatch_async(dispatch_get_main_queue(), ^{
        float topHeight = 0.f;
        if (self.dataArray.count) {
            SOSDonateDataObj *firstObj = self.dataArray[0];
//            NSString *startDate = [[SOSDateFormatter sharedInstance] simpleDateStringFromTimeStamp:firstObj.startDate.longLongValue / 1000];
//            NSString *endDate = [[SOSDateFormatter sharedInstance] simpleDateStringFromTimeStamp:firstObj.endDate.longLongValue / 1000];
//            NSString *ActivityTitle = [NSString stringWithFormat:@"%@ (%@ - %@)", firstObj.projectName, startDate, endDate];
            NSString *ActivityTitle = firstObj.projectName;
            self.activityTitleLabel.text = ActivityTitle;
            self.activityTitleLabel.hidden = NO;
            for (SOSDonateDataObj *obj in self.dataArray) {
                SOSDonateProjectView *view = [[NSBundle SOSBundle] loadNibNamed:@"SOSDonateProjectView" owner:self options:nil][0];
                [view configViewWithTiele:obj.eventName ImgURL:obj.imageUrl AndActivityID:obj.ID];
                view.frame = CGRectMake(0, topHeight, SCREEN_WIDTH - 60, (SCREEN_WIDTH - 60.f) * 367.f / 650.f);
                [self.activityContentView addSubview:view];
                topHeight += view.height;
            }
            self.activityContentViewHeightGuide.constant = topHeight;
        }    else    {
            self.activityTitleLabel.hidden = YES;
            self.activityContentViewHeightGuide.constant = 0;
        }
        [self.view layoutIfNeeded];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
