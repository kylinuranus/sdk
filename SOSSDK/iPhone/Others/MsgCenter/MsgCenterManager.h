//
//  MsgCenterManager.h
//  Onstar
//
//  Created by WQ on 2018/6/7.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Complete)(NSInteger messageNum, id model);

@interface MsgCenterManager : NSObject

@property(nonatomic,assign)NSInteger msgNum;
@property(nonatomic,copy)Complete completeBlock;

+ (MsgCenterManager *)shareInstance;

- (void)getMessage:(Complete)finishBlock;
+ (void)updateMessageList:(MessageCenterModel *)list;
+ (MessageCenterModel *)getMessageList;



/// 跳转至论坛消息页面
+ (void)jumpToForumMessage;
@end
