//
//  SOSBaseSegmentViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseSegmentViewController.h"
//#import <Masonry.h>

@interface SOSBaseSegmentViewController ()
@property (strong, nonatomic) UIColor *navBarShadowColor;

@end

@implementation SOSBaseSegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"F3F5FE"];

    self.automaticallyAdjustsScrollViewInsets = NO;

    // 2 添加控制器的View
//    self.segmentVC.view.frame = self.view.bounds;
    
    [self.view addSubview:self.segmentVC.view];
    [self.segmentVC.view mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    self.segmentVC.contentView.showsHorizontalScrollIndicator = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _navBarShadowColor = [UIColor colorWithCGColor:self.navigationController.navigationBar.layer.shadowColor];
    self.navigationController.navigationBar.layer.shadowColor = [UIColor clearColor].CGColor;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.layer.shadowColor = _navBarShadowColor.CGColor;

}

- (void)setUpDefaultNavBackItem     {
    UIButton *backButton = [UIButton new];
    [backButton setImage:[UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateHighlighted];
    [backButton sizeToFit];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)setUpWithItems:(NSArray *)items childVCs:(NSArray *)vcArray		{
//    3 添加标题数组和控住器数组
    [self.segmentVC setUpWithItems:items childVCs:vcArray];
//    4  配置基本设置  可采用链式编程模式进行设置
    [self.segmentVC.segmentBar updateWithConfig:^(LLSegmentBarConfig *config) {
        config.sBBackColor = [UIColor whiteColor];
        config.itemNormalColor([UIColor colorWithHexString:@"4E5059"]).itemSelectColor([UIColor colorWithHexString:@"6896ED"]).indicatorColor([UIColor colorWithHexString:@"6896ED"]).itemFont([UIFont systemFontOfSize:16.f]).indicatorHeight(2).indicatorExtraW(5);
    }];
}

- (void)setUpWithSpecialItems:(NSArray *)items childVCs:(NSArray *)vcArray
{
    //    3 添加标题数组和控住器数组
    [self.segmentVC setUpWithItems:items childVCs:vcArray];
    //    4  配置基本设置  可采用链式编程模式进行设置
    [self.segmentVC.segmentBar updateWithConfig:^(LLSegmentBarConfig *config) {
        config.sBBackColor = [UIColor colorWithHexString:@"F3F5FE"];
        config.itemNormalColor([UIColor colorWithHexString:@"A4A4A4"]).itemSelectColor([UIColor colorWithHexString:@"F2D18D"]).indicatorColor([UIColor colorWithHexString:@"F2D18D"]).itemFont([UIFont fontWithName:@"PingFangSC-Regular" size:16.f]).indicatorHeight(2).indicatorExtraW(5);
    }];
}

- (int)selectedIndex	{
    return (int)self.segmentVC.segmentBar.selectIndex;
}

- (void)setSelectedIndex:(int)selectedIndex		{
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
