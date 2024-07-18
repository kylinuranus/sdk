//
//  SOSOilGanSelectVC.m
//  Onstar
//
//  Created by Coir on 2019/9/1.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "LLSegmentBarVC.h"
#import "SOSOilGanSelectVC.h"
#import "SOSOilGanSelectChildVC.h"
#import "SOSThirdPartyWebVC.h"

@interface SOSOilGanSelectVC ()

@property (nonatomic, assign) int selectedIndex;
@property (nonatomic,weak) LLSegmentBarVC * segmentVC;

@property (weak, nonatomic) IBOutlet UIView *segVCBGView;
@property (nonatomic, strong) NSMutableArray *childVCArray;

@end

@implementation SOSOilGanSelectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.segVCBGView addSubview:self.segmentVC.view];
    self.segmentVC.segmentBar.layer.shadowColor = [UIColor colorWithHexString:@"F3F3F4"].CGColor;
    self.segmentVC.segmentBar.layer.shadowOffset = CGSizeMake(0, 1);
    self.segmentVC.segmentBar.layer.shadowRadius = 1;
    self.segmentVC.segmentBar.layer.shadowOpacity = 1;
    [self.segmentVC.view mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.segVCBGView);
    }];
    self.segmentVC.contentView.showsHorizontalScrollIndicator = NO;
}

- (void)setUpWithItems:(NSArray *)items childVCs:(NSArray *)vcArray        {
    //    3 添加标题数组和控住器数组
    [self.segmentVC setUpWithItems:items childVCs:vcArray];
    //    4  配置基本设置  可采用链式编程模式进行设置
    [self.segmentVC.segmentBar updateWithConfig:^(LLSegmentBarConfig *config) {
        config.sBBackColor = [UIColor whiteColor];
        config.itemNormalColor([UIColor colorWithHexString:@"4E5059"]).itemSelectColor([UIColor colorWithHexString:@"6896ED"]).indicatorColor([UIColor colorWithHexString:@"6896ED"]).itemFont([UIFont systemFontOfSize:16.f]).indicatorHeight(2).indicatorExtraW(5).barButtonGap(20);
    }];
}

- (int)selectedIndex    {
    return (int)self.segmentVC.segmentBar.selectIndex;
}

- (void)setSelectedIndex:(int)selectedIndex        {
    self.segmentVC.segmentBar.selectIndex = selectedIndex;
}

// lazy init
- (LLSegmentBarVC *)segmentVC{
    if (!_segmentVC) {
        LLSegmentBarVC *vc = [[LLSegmentBarVC alloc]init];
        // 添加到到控制器
        [self addChildViewController:vc];
        _segmentVC = vc;
    }
    return _segmentVC;
}

- (void)setOilInfoArray:(NSArray<SOSOilStation *> *)oilInfoArray    {
    _oilInfoArray = [oilInfoArray copy];
    NSMutableArray *titleArray = [NSMutableArray array];
    self.childVCArray = [NSMutableArray array];
    for (int i = 0; i < oilInfoArray.count; i++) {
        SOSOilStation *station = oilInfoArray[i];
        [titleArray addObject:station.oilName];
        
        SOSOilGanSelectChildVC *childVC = [[SOSOilGanSelectChildVC alloc] initWithNibName:@"SOSOilGanSelectChildVC" bundle:[NSBundle SOSBundle]];
        childVC.stationOilInfo = station;
        [self.childVCArray addObject:childVC];
    }
    [self setUpWithItems:titleArray childVCs:self.childVCArray];
}

- (IBAction)ensureButtonTapped {
    if (self.oilInfoArray.count>0 && self.childVCArray.count>0) {
        SOSOilStation *station = self.oilInfoArray[self.selectedIndex];
        SOSOilGanSelectChildVC *selectedVC = self.childVCArray[self.selectedIndex];
        NSString *selectGun = selectedVC.selectedGunNo;
        if (selectGun.length == 0) {
            [Util toastWithMessage:@"请选择油枪"];
            return;
        }
        NSString *url = [NSString stringWithFormat:SOSGoToPayOil_H5_URL, [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber, station.gasId, selectGun];
        
        SOSThirdPartyWebVC *webVC = [[SOSThirdPartyWebVC alloc] initWithUrl:url];
        [self.navigationController pushViewController:webVC animated:YES];
    }
    
//    SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
//    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)dismissSelf {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
