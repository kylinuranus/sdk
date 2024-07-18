//
//  LBSOrderRecordListModel.h
//  Onstar
//
//  Created by jieke on 2019/6/20.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBSOrderRecordListModel : NSObject

@property (nonatomic ,copy) NSString *status;
@property (nonatomic ,copy) NSString *payTime;
/** 套餐名称 */
@property (nonatomic ,copy) NSString *offeringName;
@property (nonatomic ,copy) NSString *total;
@property (nonatomic ,copy) NSString *buyChannel;
/** 订单号 */
@property (nonatomic ,copy) NSString *buyOrderId;
@property (nonatomic ,copy) NSString *orderType;
@property (nonatomic ,copy) NSString *vin;
@property (nonatomic ,copy) NSString *buyerName;
@property (nonatomic ,copy) NSString *transactionId;
@property (nonatomic ,copy) NSString *offeringId;
@property (nonatomic ,copy) NSString *packageStartDate;
@property (nonatomic ,copy) NSString *expressNumber;
@property (nonatomic ,copy) NSString *productNumber;
@property (nonatomic ,copy) NSString *deliveryAddr;
@property (nonatomic ,copy) NSString *lastUpdateDate;
@property (nonatomic ,copy) NSString *payChannel;
@property (nonatomic ,copy) NSString *deliveryName;
@property (nonatomic ,copy) NSString *expressCompany;
@property (nonatomic ,copy) NSString *actualPrice;
@property (nonatomic ,copy) NSString *createDate;
@property (nonatomic ,copy) NSString *deliveryPhone;
@property (nonatomic ,copy) NSString *packageEndDate;
@property (nonatomic ,copy) NSString *accountId;

@property (nonatomic, copy) NSString *statusValue;
/** 是不是LBS套餐 */
@property (nonatomic, copy) NSString *isLBSPackage;
/**开关状态 */
@property (nonatomic,assign,) BOOL openSection;

@end
