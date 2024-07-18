//
//  SOSInfoFlowSettingViewController.m
//  Onstar
//
//  Created by Onstar on 2019/1/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlowSettingViewController.h"
#import "UITableView+Category.h"
#import "SOSInfoFlowSettingCell.h"
#import "SOSInfoFlowNetworkEngine.h"
#import "LoadingView.h"

@interface SOSInfoFlowSettingViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray<SOSInfoFlowSetting *> *infoFlowSettings;

@end

@implementation SOSInfoFlowSettingViewController

- (void)initData{
    _infoFlowSettings = @[];
}

- (void)initView{
    self.title = @"首页消息卡片设置";
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 90.f;
    _tableView.backgroundColor = [SOSUtil onstarLightGray];
    [_tableView registerClass:SOSInfoFlowSettingCell.class];
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];


}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self requestInfoFlowSettings];
}


#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _infoFlowSettings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSInfoFlowSetting *setting = _infoFlowSettings[indexPath.row];
    SOSInfoFlowSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:SOSInfoFlowSettingCell.className];
    cell.setting = setting;
    __weak __typeof(self)weakSelf = self;
    cell.trigger = ^void(BOOL isOn) {
        setting.status = isOn ? @"ON" : @"OFF";
        [SOSInfoFlowNetworkEngine triggerInfoFlowSetting:setting completionBlock:^(id data) {

        } errorBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util showErrorHUDWithStatus:@"切换失败，请重试"];
            setting.status = isOn ? @"OFF" : @"ON";
            [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        }];
    };
    return cell;
}


#pragma mark - table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return UIView.new;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - http request
- (void)requestInfoFlowSettings {
    [[LoadingView sharedInstance] startIn:self.view];
    [SOSInfoFlowNetworkEngine requestInfoFlowSettingsWithCompletionBlock:^(NSArray *infoFlows) {
        [Util hideLoadView];
        _infoFlowSettings = infoFlows;
        [_tableView reloadData];
        
    } errorBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:@"获取失败" message:nil completeBlock:^(NSInteger buttonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    }];

}

@end
