//
//  TermsViewController.m
//  Onstar
//
//  Created by Vicky on 14-1-17.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import "SOSTermsViewController.h"
#import "Util.h"
#import "CustomerInfo.h"
#import "AppPreferences.h"
#import "ContentUtil.h"
#import "SOSWebView.h"
#import "NSString+JWT.h"
#import "SOSAgreement.h"
#import "MePersonalInfoViewCell.h"
#import "LoadingView.h"
#import "SOSTermsDetailViewController.h"

@interface SOSTermsViewController ()<UITableViewDelegate,UITableViewDataSource>{
}
@property (strong, nonatomic) NSMutableArray<SOSAgreement *> *agreements;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation SOSTermsViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupTableView];
    
    self.title = @"协议条款";
    [self getProtocolRequest];
    
}
- (void)setupTableView      {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.rowHeight = 54;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MePersonalInfoViewCell class]) bundle:nil] forCellReuseIdentifier:@"cellID"];
    
}
- (void)getProtocolRequest{
    _agreements = @[].mutableCopy;
    NSArray<NSString *> *types = @[agreementName(ONSTAR_TC), agreementName(ONSTAR_PS), agreementName(SGM_TC), agreementName(SGM_PS)];
    [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];

    [SOSAgreement requestAgreementsWithTypes:types success:^(NSDictionary *response) {
        if (response.allKeys.count != types.count) {
            return;
        }
        [types enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([response.allKeys containsObject:obj]) {
                SOSAgreement *model = [SOSAgreement mj_objectWithKeyValues:response[obj]];
                [_agreements addObject:model];
            }
        }];
        __weak __typeof(self)weakSelf = self;
        [weakSelf.tableView reloadData];
        [[LoadingView sharedInstance] stop];
    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
        [Util toastWithMessage:@"获取协议内容失败"];
        __weak __typeof(self)weakSelf = self;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MePersonalInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    cell.leftLabelWidthConstraint.constant = 200.0f;
    cell.leftLabel.textColor = [UIColor blackColor];
    cell.leftLabel.text = [_agreements objectAtIndex:indexPath.section*2+indexPath.row].docTitle;
    cell.rightLabel.hidden = YES;
    cell.arrowImgV.hidden = NO;
    cell.photoBtn.hidden = YES;
    cell.bottomLineView.hidden = NO;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SOSTermsDetailViewController * con = [[SOSTermsDetailViewController alloc] init];
    con.agreement = [_agreements objectAtIndex:indexPath.section*2+indexPath.row];
    [self.navigationController pushViewController:con animated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView    {
    return _agreements.count%2 ==0?_agreements.count/2:_agreements.count/2+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section    {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section    {
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath    {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section     {

    if (_agreements.count%2==0) {
        return 2;
    }else{
        if (section == (_agreements.count-1)/2) {
            return 1;
        }else{
            return 2;
        }
    }
    
}

@end
