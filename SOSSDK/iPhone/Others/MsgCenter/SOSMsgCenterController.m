//
//  SOSMsgCenterController.m
//  Onstar
//
//  Created by WQ on 2018/5/21.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMsgCenterController.h"
#import "SOSMsgCenterView.h"
#import "SOSMsgHotActivityController.h"
#import "SOSNotifyController.h"
#import "SOSStarASTViewController.h"

@interface SOSMsgCenterController ()
{
    SOSMsgCenterView *view;
    MessageCenterModel *model;
    NSInteger unreadNumOfAct;
    NSInteger unreadNumOfnotify;
    NSInteger totalNumOfAct;
    NSInteger totalNumOfnotify;
    
    NSInteger unreadNumOfForum;
    NSInteger totalNumOfForum;

    NSArray *data_banners;
}

@end

@implementation SOSMsgCenterController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
}

- (void)go
{
    NSString *url = [Util getConfigureURL];
    NSString *user_id = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    url = [url stringByAppendingFormat:(GET_TOTAL_MESSAGE),user_id,SOSSDK_VERSION];
    [Util showLoadingView];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        [self requestSucess:responseStr];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
         [view update];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
    
}

- (void)requestSucess:(NSString*)str
{
    __block NSInteger count = 0;
    NSMutableArray *arr = [NSMutableArray array];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (jsonResponse) {
        model = [MessageCenterModel mj_objectWithKeyValues:jsonResponse];
        [model.notificationStatusList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MessageModel *m = (MessageModel*)obj;
            if ([m.category isEqualToString:@"ACTIVITY"]) {
                unreadNumOfAct = m.count;
                totalNumOfAct = m.totalCount;
            }else if ([m.category isEqualToString:@"NOTICE"])
            {
                unreadNumOfnotify = m.count;
                totalNumOfnotify = m.totalCount;
            }
            else if ([m.category isEqualToString:@"FORUM"]) {
                unreadNumOfForum = m.count;
                totalNumOfForum = m.totalCount;
            }
            count = count + m.count;
            if (m.totalCount > 0) {        //有消息
                [arr addObject:obj];
            }
        }];
        [MsgCenterManager shareInstance].msgNum = count;
        [MsgCenterManager updateMessageList:model];

        model.notificationStatusList = arr;
        view.model = model;
        [view update];
    }
}

- (void)delMsg:(NSString*)category
{
    NSString *url = [Util getConfigureURL];
    NSString *user_id = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    url = [url stringByAppendingFormat:(DEL_MESSAGE),user_id,category];
    [Util showLoadingView];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        NSLog(@"responseStr %@",responseStr);
        NSString *str = (NSString*)responseStr;
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (jsonResponse) {
            NSLog(@"%@",jsonResponse);
            [self delSuccess:category];
        }
            
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [sosOperation setHttpMethod:@"DElETE"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];

}

- (void)delSuccess:(NSString*)category
{
    NSMutableArray *arr = [NSMutableArray array];
    [model.notificationStatusList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MessageModel *m = (MessageModel*)obj;
        if (![m.category isEqualToString:category]) {
            [arr addObject:obj];
        }
    }];
    NSArray *arr1 = [NSArray arrayWithArray:arr];
    view.model.notificationStatusList = arr1;
    [view update];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"消息中心";
    
    view = [SOSMsgCenterView instanceView];
    view.parent = self;
    view.frame = self.view.frame;
    [self.view addSubview:view];
    view.banners = @[];
    [self getBannerResp];
    [self go];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [view viewDidLayout];
}

- (void)goActivity
{
    [SOSDaapManager sendActionInfo:My_massage_activity];
    SOSMsgHotActivityController *vc = [[SOSMsgHotActivityController alloc]init];
    vc.unreadNum = unreadNumOfAct;
    vc.totalNum = totalNumOfAct;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)goStarAst{
//    [SOSDaapManager sendActionInfo:My_massage_notificition];
    SOSStarASTViewController *vc = [[SOSStarASTViewController alloc]init];

    [self.navigationController pushViewController:vc animated:YES];
}
- (void)goNotifyWithCategory:(NSString *)cat categoryTitle:(NSString *)title;
{
    [SOSDaapManager sendActionInfo:My_massage_notificition];
    SOSNotifyController *vc = [[SOSNotifyController alloc]init];
    vc.notifyCategory = cat;
    vc.notifyTitle = title;
    if ([cat.uppercaseString isEqualToString:@"FORUM"]) {
        vc.unreadNum = unreadNumOfForum;
        vc.totalNum = totalNumOfForum;
    }else {
        vc.unreadNum = unreadNumOfnotify;
        vc.totalNum = totalNumOfnotify;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getBannerResp {
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970] ;
    [OthersUtil getBannerByCategory:BANNER_HOME SuccessHandle:^(NSArray *banners) {
        if (banners.count<=0) {
            [view hiddenBanner];
        }else
        {
            dispatch_async_on_main_queue(^{
                view.banners = banners;
                [view updateBanner];
            });
        }
        [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES funcId:MY_Message_banner_loadtime];
    } failureHandler:^(NSString *responseStr, NSError *error) {
        NSLog(@"banner error %@",responseStr);
        [view hiddenBanner];
        [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO funcId:MY_Message_banner_loadtime];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    NSLog(@"dealloc");
}






@end
