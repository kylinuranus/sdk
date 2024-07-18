//
//  SOSNotifyController.m
//  Onstar
//
//  Created by WQ on 2018/5/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSNotifyController.h"
#import "SOSNotifyView.h"
@interface SOSNotifyController ()
{
    SOSNotifyView *view;
    NSMutableArray *originDatas;   //当前页面总数据，保存所有未排序的数据
    NSMutableArray *totals;        //当前页面总数据，每个元素为section
    NSMutableArray *currents;      //当前请求的数据，根据上拉或下拉加入totals的头或尾
    NotifyOrActModel *unread;     //保存最远一条未读，用于确认隐藏XX条未读按钮
    BOOL showLoading;             //是否显示loading页面
}

@end

@implementation SOSNotifyController

- (void)testb
{
    NSLog(@"SOSNotifyController testb --------");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setTestNum:(NSInteger)testNum
{
    NSLog(@"setTestNum---%@",@(testNum));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    showLoading = YES;
    self.fd_prefersNavigationBarHidden = NO;
    
    
    self.backDaapFunctionID = My_massage_notificition_back;
    totals = [NSMutableArray array];
    currents = [NSMutableArray array];
    originDatas = [NSMutableArray array];
    view = [SOSNotifyView instanceView];
    view.unreadNum = _unreadNum;
    view.totalNum = _totalNum;
    view.parentVC = self;
    [self.view addSubview:view];
    if (self.notifyTitle) {
        self.title = self.notifyTitle;
    }
    if ([self.notifyCategory isEqualToString:@"FORUM"] || [self.notifyCategory isEqualToString:@"STARAST"]) {
        view.useCustomCell = YES;
    }
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self go:YES pageNum:1];
}

- (void)go:(BOOL)isDragDown pageNum:(NSInteger)num
{
    if (showLoading) {
        [Util showLoadingView];
    }
    NSString *url = [Util getConfigureURL];
    NSString *user_id = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    url = [url stringByAppendingFormat:(GET_MESSAGE_LIST),user_id,self.notifyCategory,num];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        //NSLog(@"responseStr %@",responseStr);
        [self requestSuccess:responseStr direct:isDragDown pageNum:num];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [view endRefresh];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
       
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}


- (void)requestSuccess:(NSString*)str direct:(BOOL)isDragDown pageNum:(NSInteger)num
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (jsonResponse) {
        MessageCenterListModel *m = [MessageCenterListModel mj_objectWithKeyValues:jsonResponse];
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
        //m1.pageNum = num;
        if (i+1 >= source.count) {  //数组里只有一个数据时
            [set addIndex:0];
            [arr insertObject:m1 atIndex:0];
            NSArray* reversedArray = [[arr reverseObjectEnumerator] allObjects];
            [currents addObject:reversedArray];
            break;
        }
        NotifyOrActModel *m2 = source[i+1];
        //m2.pageNum = num;
        if ([m1.sendDate isEqualToString:m2.sendDate]) {  //第一个依次与身后的比，相同则保存索引和内容
            [set addIndex:i+1];
            [arr addObject:m2];
        }else                                            //比到有不同，则保存第一个
        {
            [set addIndex:0];
            [arr insertObject:m1 atIndex:0];
            NSArray* reversedArray = [[arr reverseObjectEnumerator] allObjects];
            [currents addObject:reversedArray];
            break;
        }
    }
    [source removeObjectsAtIndexes:set];      //删除已比较完毕的
    if ([source count]> 0) {                //还有，继续比较
        [self doWithArr:source pageNum:num];
    }
}


//根据上拉还是下拉决定升序将序
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

