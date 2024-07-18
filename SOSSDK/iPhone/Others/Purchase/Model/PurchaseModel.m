//
//  PurchaseModel.m
//  Onstar
//
//  Created by Joshua on 6/3/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "PurchaseModel.h"
#import "CustomerInfo.h"

static PurchaseModel *instance = nil;
@implementation PurchaseModel

+ (PurchaseModel *)sharedInstance     {
    static PurchaseModel *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
    });
    return sharedOBJ;
}

+ (void)purgeSharedInstance     {
    instance = nil;
}

- (id)init     {
    if (self = [super init]) {
        [self initPurchasePreparation];
    }
    return self;
}

- (void)initPurchasePreparation     {
    _payChannelArray = @[];
}

+ (UserType)getUserType     {
    UserType type;
    NSString *role = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.role;
    if (role &&
        ([role caseInsensitiveCompare:ROLE_OWNER] == NSOrderedSame ||
        [role caseInsensitiveCompare:ROLE_DRIVER] == NSOrderedSame ||
        [role caseInsensitiveCompare:ROLE_PROXY] == NSOrderedSame) )
    {
        type = UserTypeSubScriber; // 车主
    } else if (role && [role caseInsensitiveCompare:ROLE_VISITOR] == NSOrderedSame) {
        type = UserTypeVisitor; // 潜客, 登录 无车辆
    } else {
        type = UserTypeAnonymous; // 游客 未登录
    }
    return type;
}

//- (NSString *)currentVin     {
//    return [[CustomerInfo sharedInstance] vin];
//}

- (NSString *)currentMakeModel     {
    return [NSString stringWithFormat:@"%@%@", [[CustomerInfo sharedInstance] currentVehicle].make, [[CustomerInfo sharedInstance] currentVehicle].model];
}

- (NSString *)orderId     {
    return _createOrderResponse.buyOrderId ? _createOrderResponse.buyOrderId : @"";
}

- (NSString *)idpid {
    return [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
}

- (NSString *)invoiceId     {
//    if (_saveInvoieResponse && _saveInvoieResponse.invoiceId) {
//        return _saveInvoieResponse.invoiceId;
//    }
    return nil;
}

- (NSString *)migSessionKey     {
    return [CustomerInfo sharedInstance].mig_appSessionKey;
}


- (NSString *)accountId     {
    return [[CustomerInfo sharedInstance] userBasicInfo].currentSuite.account.accountId;
}

@end
