//
//  SOSTanViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/3/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSTanViewController.h"
#import "SOSRemindTableViewCell.h"
#import "SOSCardUtil.h"

@interface SOSTanViewController ()
@property(nonatomic, strong) NSArray *titleArray;
@end

@implementation SOSTanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _titleArray = @[@"短信提醒",
                    @"手机应用推送提醒",
                    @"电话提醒"];
    self.title = @"车辆报警提示设置";
    self.table.tableFooterView = [UIView new];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    switch (self.validity) {
        case Gen10TrafficOver:
            self.tipLb.text = @"抱歉，您的数据流量包可能已到期或已耗尽，请进入“互联套餐”页面购买流量包以便继续使用本服务";
            break;
        case gen9ServiceOver:
            self.tipLb.text = @"抱歉，您的安吉星套餐已过期，无法使用本服务，请进入“安吉星套餐”页面续约";
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    SOSRemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle SOSBundle] loadNibNamed:@"SOSRemindTableViewCell" owner:self options:nil][0];
    }
    cell.titleName.text = _titleArray[indexPath.row];
    [cell.switchbtn setEnabled:NO];
    [cell.switchbtn setOn:NO];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (IBAction)pushBuy:(id)sender {
    AppDelegate_iPhone *appdelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    [appdelegate hideMainLeftMenu];
    [SOSCardUtil routerToBuyOnstarPackage:PackageType_Core];

}

@end
