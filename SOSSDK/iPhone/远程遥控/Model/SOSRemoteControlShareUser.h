//
//  SOSRemoteControlShareUser.h
//  Onstar
//
//  Created by lizhipan on 2017/5/16.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SOSRemoteControlShareUser : NSObject
@property(nonatomic,copy)NSString * subscriberId;
@property(nonatomic,copy)NSString * roleType;
@property(nonatomic,assign)BOOL authorizeStatus;

@property(nonatomic,copy)NSString * vin;
@property(nonatomic,copy)NSString * idpUserId;
@property(nonatomic,copy)NSString * context;
@property(nonatomic,assign)NSInteger limit;
@property(nonatomic,copy)NSString * endDate;
@property(nonatomic,copy)NSString * faceUrl;

@property(nonatomic,copy)NSString * ownerSubscriberId;
@property(nonatomic,copy)NSString * ownerAccountId;
@end

@interface SOSRemoteControlShareUserList : NSObject
@property (nonatomic, strong) NSArray *shareList;
@end

//后端指定字段传递，所以只能再抽出一部分SOSRemoteControlShareUser的属性
@interface RemoteControlSharePostUser: NSObject
@property(nonatomic,copy)NSString * context;
@property(nonatomic,copy)NSString * faceUrl;
@property(nonatomic,copy)NSString * idpUserId;
@property(nonatomic,assign)NSInteger limit;
@property(nonatomic,copy)NSString * roleType;
@property(nonatomic,copy)NSString * subscriberId;
@property(nonatomic,copy)NSString * authorizeStatus;
@end
