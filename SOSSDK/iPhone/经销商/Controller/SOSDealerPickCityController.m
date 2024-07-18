//
//  SOSDealerPickCityController.m
//  Onstar
//
//  Created by TaoLiang on 2018/1/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSDealerPickCityController.h"
#import "DealerCityTableV.h"
#import "DealerSubCitysTableV.h"


@interface SOSDealerPickCityController ()<ViewControllerChooseCityDelegate>
@property (strong, nonatomic) DealerCityTableV *leftTableView;
@property (weak, nonatomic) UILabel *rightLabel;
@end

@implementation SOSDealerPickCityController

- (void)initData {
    
}

- (void)initView {
    self.title = @"选择地区";
    UIView *currentCityContainerView = [UIView new];
    currentCityContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:currentCityContainerView];
    [currentCityContainerView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *leftLabel = [UILabel new];
    leftLabel.font = [UIFont systemFontOfSize:16];
    leftLabel.text = @"当前城市";
    [currentCityContainerView addSubview:leftLabel];
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(currentCityContainerView);
        make.left.equalTo(@15);
    }];

    UILabel *rightLabel = [UILabel new];
    rightLabel.font = [UIFont systemFontOfSize:16];
    [currentCityContainerView addSubview:rightLabel];
    [rightLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(currentCityContainerView);
        make.left.equalTo(leftLabel.mas_right).offset(50);
    }];
    rightLabel.text = _currentCity.city;
    _rightLabel = rightLabel;

    _leftTableView = [[DealerCityTableV alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH*.41, SCREEN_HEIGHT - STATUSBAR_HEIGHT - 44 - 50)];
    _leftTableView.delegateCity = self;
    [self.view addSubview:_leftTableView];
    [_leftTableView initData];
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self initView];
}

#pragma mark - ViewControllerChooseCityDelegate
- (void)didChooseCity:(SOSCityGeocodingInfo *)cityInfo {
    if (_pickedCity) {
        _pickedCity(cityInfo);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
