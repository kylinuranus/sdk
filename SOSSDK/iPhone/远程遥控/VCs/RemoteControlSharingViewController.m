//
//  RemoteControlSharingViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/5/16.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "RemoteControlSharingViewController.h"
#import "SharingItemTableViewCell.h"
@interface RemoteControlSharingViewController ()<UITableViewDelegate,UITableViewDataSource>		{
    NSMutableArray * authUsers;
}

@property (weak, nonatomic) IBOutlet UITableView *shareList;

@end

@implementation RemoteControlSharingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"远程遥控共享管理";
    UIBarButtonItem * customRightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"使用说明" style:UIBarButtonItemStylePlain target:self action:@selector(manual)];
    self.navigationItem.rightBarButtonItem = customRightBarItem;
    authUsers = [NSMutableArray array];
    self.backRecordFunctionID = Remotecontrol_carshare_back;
}

- (void)manual		{
    SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:REMOTE_SHARE_MANUAL];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)requestAuthUser        {
    [Util showLoadingView];
    [OthersUtil getCarsharingSuccessHandler:^(SOSRemoteControlShareUserList *res) {
        [authUsers removeAllObjects];
        [authUsers addObjectsFromArray:res.shareList];
        [Util hideLoadView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_shareList reloadData];
            if (authUsers.count>0) {
                [self showAuthNobodyPrompt:NO];
            }
            else
            {
                [self showAuthNobodyPrompt:YES];
            }
        });
    } failureHandler:^(NSString *responseStr, NNError *error) {
        [Util hideLoadView];
        [authUsers removeAllObjects];
        [_shareList reloadData];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
}

- (void)showAuthNobodyPrompt:(BOOL)show        {
    _authNobodyView.hidden = !show;
}

- (void)viewWillAppear:(BOOL)animated        {
    [super viewWillAppear:animated];
    [self requestAuthUser];
}

#pragma mark- tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section        {
    return authUsers.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 44.0f;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath        {
    
    static NSString *cellIndentifier = @"rscCell";
    SharingItemTableViewCell *cell = (SharingItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(cell == nil) {
        NSArray *nib = [[NSBundle SOSBundle] loadNibNamed:@"SharingItemTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    tableView.rowHeight = cell.frame.size.height;
    [cell configCell:[authUsers objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath        {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
