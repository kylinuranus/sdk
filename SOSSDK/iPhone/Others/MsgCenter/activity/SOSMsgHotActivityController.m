//
//  SOSMsgHotActivityController.m
//  Onstar
//
//  Created by WQ on 2018/5/22.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMsgHotActivityController.h"
#import "SOSMsgHotActivityView.h"

@interface SOSMsgHotActivityController ()

@end

@implementation SOSMsgHotActivityController
{
    NSMutableArray *originDatas;   //当前页面总数据，保存所有未排序的数据
    NSMutableArray *totals;        //当前页面总数据
    NSMutableArray *currents;      //当前请求的数据，根据上拉或下拉加入totals的头或尾
    SOSMsgHotActivityView *view;
    BOOL showLoading;             //是否显示loading页面
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isPush) {  //推送进入本页，直接跳h5
        _isPush = NO;
        if (_pushUrl.length > 5) {
            [self goH5];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    showLoading = _isPush ? NO:YES;   //如果是推送进本页，不显示loading页
    totals = [NSMutableArray array];
    currents = [NSMutableArray array];
    originDatas = [NSMutableArray array];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"热门活动";
    self.backDaapFunctionID = My_massage_activity_back;
    view = [SOSMsgHotActivityView instanceView];
    view.frame = self.view.frame;
    view.unreadNum = _unreadNum;
    view.totalNum = _totalNum;
    view.parent = self;
    [self.view addSubview:view];
    [self go:NO pageNO:1];
}


- (void)go:(BOOL)isDragDown pageNO:(NSInteger)num
{
    if (showLoading) {
        [Util showLoadingView];
    }
    NSString *url = [Util getConfigureURL];
    NSString *user_id = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    url = [url stringByAppendingFormat:(GET_MESSAGE_LIST),user_id,@"Activity",num];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        [self requestSuccess:responseStr direct:isDragDown pageNum:num];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        [view endRefresh];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];

}


- (void)requestSuccess:(NSString*)str direct:(BOOL)isDragDown pageNum:(NSInteger)num
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    [view endRefresh];
    if (jsonResponse) {
        MessageCenterListModel *m = [MessageCenterListModel mj_objectWithKeyValues:jsonResponse];
        if (m.notifications.count>0) {
            [self addToOrigin:m pageNum:num direct:isDragDown];
            [self doWithArr:originDatas pageNum:num];
            [self organizeData:isDragDown];
            if (showLoading) {
                showLoading = NO;
                [view begin];
            }else
            {
                [view update];
            }
        }
       
    }
}


//如果是推送进入此页，直接进h5
-(void)goH5
{
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:_pushUrl];
    [self.navigationController pushViewController:vc animated:NO];
}



- (void)addToOrigin:(MessageCenterListModel*)m pageNum:(NSInteger)num direct:(BOOL)isDragDown
{
    if (isDragDown) {
        [m.notifications enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NotifyOrActModel *m1 = (NotifyOrActModel*)obj;
            m1.pageNum = num;
            [originDatas addObject:obj];
        }];
    }else
    {
        NSArray* reversedArray = [[m.notifications reverseObjectEnumerator] allObjects];
        [reversedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NotifyOrActModel *m1 = (NotifyOrActModel*)obj;
            m1.pageNum = num;
            [originDatas insertObject:obj atIndex:0];
        }];
    }
}



- (void)doWithArr:(NSArray *)datas pageNum:(NSInteger)num
{
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *source = [datas mutableCopy];
    NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < source.count; i++) {
        NotifyOrActModel *m1 = source[0];
        if (i+1 >= source.count) {
            [set addIndex:0];
            [arr insertObject:m1 atIndex:0];
            NSArray* reversedArray = [[arr reverseObjectEnumerator] allObjects];  //服务端过来的数据从近到远最近的消息需要显示在最下端，所以将数据逆序一下
            [currents addObject:reversedArray];
            break;
        }
        NotifyOrActModel *m2 = source[i+1];
        if ([m1.sendDate isEqualToString:m2.sendDate]) {
            [set addIndex:i+1];
            [arr addObject:m2];
        }else
        {
            [set addIndex:0];
            [arr insertObject:m1 atIndex:0];
            NSArray* reversedArray = [[arr reverseObjectEnumerator] allObjects];
            [currents addObject:reversedArray];
            break;
        }
    }
    [source removeObjectsAtIndexes:set];

    if ([source count]> 0) {
        [self doWithArr:source pageNum:num];
    }
}


- (void)organizeData:(BOOL)isDragDown
{
    [totals removeAllObjects];
    NSArray* reversedArray = [[currents reverseObjectEnumerator] allObjects];
    if (isDragDown) {  //下拉刷新
        
        [totals insertObjects:reversedArray atIndex:0];
        view.datas = totals;
    }else
    {
        [reversedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [totals addObject:obj];
        }];
        view.datas = totals;
    }
    [currents removeAllObjects];
}

- (void)cleanData
{
    [currents removeAllObjects];
    [totals removeAllObjects];
    [originDatas removeAllObjects];
}

- (void)dealloc
{
    NSLog(@"dealloc");
}


@end
