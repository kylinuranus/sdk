//
//  FIrstVC.m
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "LBSConsigneeVC.h"
#import "LBSConsigneeCell.h"
#import "LBSConsigneeHeaderView.h"
#import "LBSConfirmOrderVC.h"
#import "NSString+Category.h"
#import "PurchaseModel.h"

@interface LBSConsigneeVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <PackageInfos *>*dataArray;
@property (nonatomic, strong) NSMutableArray *cellArray;
@property (nonatomic, strong) UIButton *footSaveBtn;

@end

@implementation LBSConsigneeVC

#pragma mark - 系统的
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNaviView];
    [self setupCellArray];
    [self setupLayoutView];
    [self setupDataArray];
    [self setupFootSaveBtnState];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (self.pushType == SOSPushTypeNone) {
        self.fd_interactivePopDisabled = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.fd_interactivePopDisabled = NO;
}
#pragma mark - Delegate
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell <BaseTableViewCellProtocol>*cell = self.cellArray[indexPath.row];
    [cell configModel:self.dataArray[indexPath.row]];
    return cell;
}

#pragma mark - Private
- (void)setupLayoutView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    LBSConsigneeHeaderView *headView = [[LBSConsigneeHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 184)];
    self.tableView.tableHeaderView = headView;
    
    [self.view addSubview:self.footSaveBtn];
    [self.footSaveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(190, 37));
        make.bottom.mas_equalTo(-40);
    }];
}
- (void)setupNaviView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"收货人信息";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    [self setLeftBackBtnCallBack:^{
        @strongify(self);
        [self backBtnClick];
    }];
    if (self.pushType == SOSPushTypeNone) {
        self.fd_interactivePopDisabled = YES;
    }
}
- (void)setupDataArray {
    PackageInfos *model0 = [[PackageInfos alloc] init];
    model0.name = @"姓      名";
    model0.placeholder = @"请输入你的姓名";
    [self.dataArray addObject:model0];
    
    PackageInfos *model1 = [[PackageInfos alloc] init];
    model1.name = @"电      话";
    model1.placeholder = @"请输入你的电话";
    [self.dataArray addObject:model1];
    
    PackageInfos *model2 = [[PackageInfos alloc] init];
    model2.name = @"详细地址";
    model2.placeholder = @"请输入你的详细地址";
    [self.dataArray addObject:model2];
    [self.tableView reloadData];
}
- (void)setupCellArray {
    PackageInfos *package = [PurchaseModel sharedInstance].selectPackageInfo;
    __weak typeof(self) _self = self;
    LBSConsigneeCell *nameCell = [[LBSConsigneeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell0"];
    nameCell.tag = 1;
//    nameCell.textField.text = package.deliveryName;
    [nameCell setShowText:package.deliveryName];
    nameCell.changeTextFieldBlock = ^(NSString *textFieldString) {
        __strong typeof(_self) self = _self;
        package.deliveryName = textFieldString;
        [self setupFootSaveBtnState];
    };
    LBSConsigneeCell *phoneCell = [[LBSConsigneeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell0"];
    phoneCell.tag = 2;
    phoneCell.textField.keyboardType = UIKeyboardTypeNumberPad;
//    phoneCell.textField.text = package.deliveryPhone;
    [phoneCell setShowText:package.deliveryPhone];
    phoneCell.changeTextFieldBlock = ^(NSString *textFieldString) {
        __strong typeof(_self) self = _self;
        package.deliveryPhone = textFieldString;
        [self setupFootSaveBtnState];
    };
    LBSConsigneeCell *addressCell = [[LBSConsigneeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell0"];
    addressCell.tag = 3;
//    addressCell.textField.text =
    [addressCell setShowText:package.deliveryAddr];
    addressCell.changeTextFieldBlock = ^(NSString *textFieldString) {
        __strong typeof(_self) self = _self;
        package.deliveryAddr = textFieldString;
        [self setupFootSaveBtnState];
    };
    [self.cellArray addObject:nameCell];
    [self.cellArray addObject:phoneCell];
    [self.cellArray addObject:addressCell];
}
- (void)setupFootSaveBtnState {
    PackageInfos *package = [PurchaseModel sharedInstance].selectPackageInfo;
    if (![NSString isBlankString:package.deliveryName] && ![NSString isBlankString:package.deliveryPhone] && ![NSString isBlankString:package.deliveryAddr]) {
        self.footSaveBtn.backgroundColor = UIColorHex(0x6896ED);
        self.footSaveBtn.userInteractionEnabled = YES;
    }else {
        self.footSaveBtn.backgroundColor = UIColorHex(0xC3CEEC);
        self.footSaveBtn.userInteractionEnabled = NO;
    }
}
#pragma mark 保存
- (void)footSaveBtnClick:(UIButton *)button {
    [self.view endEditing:YES];
    PackageInfos *package = [PurchaseModel sharedInstance].selectPackageInfo;
    if (package.deliveryPhone.length == 11) {
        if (self.pushType == SOSPushTypeNone) {
            LBSConfirmOrderVC *vc = [[LBSConfirmOrderVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (self.pushType == SOSPushTypeConfirmOrder) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else { // 提示用户输入手机号码为11位
        [Util toastWithMessage:@"请输入合法的手机号"];
    }
}
#pragma mark 返回事件
- (void)backBtnClick {
    if (self.pushType == SOSPushTypeNone) {
        PackageInfos *package = [PurchaseModel sharedInstance].selectPackageInfo;
        package.deliveryName = @"";
        package.deliveryPhone = @"";
        package.deliveryAddr = @"";
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 44;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}
- (NSMutableArray *)cellArray {
    if (!_cellArray) {
        _cellArray = [NSMutableArray array];
    }
    return _cellArray;
}
- (NSMutableArray<PackageInfos *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (UIButton *)footSaveBtn {
    if (!_footSaveBtn) {
        _footSaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _footSaveBtn.backgroundColor = UIColorHex(0xC3CEEC);
        _footSaveBtn.userInteractionEnabled = NO;
        //_footSaveBtn.backgroundColor = UIColorHex(0x6896ED);
        _footSaveBtn.layer.cornerRadius = 4.0;
        _footSaveBtn.layer.masksToBounds = YES;
        [_footSaveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_footSaveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _footSaveBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 16];
        [_footSaveBtn addTarget:self action:@selector(footSaveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footSaveBtn;
}
@end
