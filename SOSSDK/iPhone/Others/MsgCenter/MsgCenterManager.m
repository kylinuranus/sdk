//
//  MsgCenterManager.m
//  Onstar
//
//  Created by WQ on 2018/6/7.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "MsgCenterManager.h"
#import "SOSNotifyController.h"

static MessageCenterModel * messageList;//全部消息

@implementation MsgCenterManager

static MsgCenterManager * _instance = nil;


+ (MsgCenterManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MsgCenterManager alloc] init];
        _instance.msgNum = 0;
    });
    return _instance;
}

- (void)getMessage:(Complete)finishBlock
{
    self.msgNum = 0;
    self.completeBlock = finishBlock;
    NSString *url = [Util getConfigureURL];
    NSString *user_id = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    url = [url stringByAppendingFormat:(GET_TOTAL_MESSAGE),user_id,SOSSDK_VERSION];
    
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [self requestSucess:responseStr];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        //[Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

- (void)requestSucess:(NSString*)str
{
    __block NSInteger count = 0;
    __block MessageCenterModel* model;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (jsonResponse) {
        model = [MessageCenterModel mj_objectWithKeyValues:jsonResponse];
        [model.notificationStatusList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MessageModel *m = (MessageModel*)obj;
            count = count + m.count;
        }];
        messageList = model;
        self.msgNum = count;
        self.completeBlock(count, model);
    }else
    {
        self.completeBlock(0, nil);
    }
}
+ (void)updateMessageList:(MessageCenterModel *)list{
    messageList = list;
}
+ (MessageCenterModel *)getMessageList{
    return messageList;
}

+ (void)jumpToForumMessage {
    NSString *url = [BASE_URL stringByAppendingFormat:(GET_TOTAL_MESSAGE), CustomerInfo.sharedInstance.userBasicInfo.idpUserId ? : @"", SOSSDK_VERSION];
    [Util showLoadingView];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        MessageCenterModel *model = [MessageCenterModel mj_objectWithKeyValues:responseStr];
        __block BOOL hitCategoryForum;
        [model.notificationStatusList enumerateObjectsUsingBlock:^(MessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.category isEqualToString:@"FORUM"]) {
                SOSNotifyController *vc = [[SOSNotifyController alloc]init];
                vc.notifyCategory = obj.category;
                vc.notifyTitle = obj.categoryZh;
                vc.unreadNum = obj.count;
                vc.totalNum = obj.totalCount;
                [SOS_APP_DELEGATE.fetchMainNavigationController pushViewController:vc animated:YES];
                hitCategoryForum = YES;
                *stop = YES;
                return;
            }
        }];
        if (!hitCategoryForum) {
            [Util showErrorHUDWithStatus:@"获取消息失败"];
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];

}
@end
