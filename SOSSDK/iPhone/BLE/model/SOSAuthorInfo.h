//
//  AuthorInfo.h
//  BlueTools
//
//  Created by onstar on 2018/6/20.
//  Copyright © 2018年 onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSVKeys.h"

@interface SOSAuthorDetail : NSObject

@property (nonatomic,copy) NSString *authorizationId;
@property (nonatomic,copy) NSString *vin;
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,copy) NSString *endTime;
@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,copy) NSString *authorizationStatus;
@property (nonatomic,copy) NSString *authorizationType;
@property (nonatomic,copy) NSString *permission;
@property (nonatomic,copy) NSString *disclaimer;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *mobilePhone;
@property (nonatomic,copy) NSString *createBy;
@property (nonatomic,strong) NSArray<SOSVKeys *> *vkeys;
@property (nonatomic,copy) NSString *shareUrl;
@property (nonatomic, assign) BOOL exsitLocal;//
@property (nonatomic, assign) BOOL isOwner;//
@end

@interface SOSAuthorInfo : NSObject
@property (nonatomic,copy) NSString *statusCode;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,strong) NSArray *resultData;
@property (nonatomic,copy) NSString *shareUrl;
@end


