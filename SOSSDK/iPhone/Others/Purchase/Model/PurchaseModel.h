//
//  PurchaseModel.h
//  Onstar
//
//  Created by Joshua on 6/3/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PurchaseCommonDefination.h"
#import "AppPreferences.h"
#import "ResponseDataObject.h"

typedef enum PurchaseType     {
    PurchaseTypePackage = 1,
    PurchaseTypeData,
} PurchaseType;

@interface PurchaseModel : NSObject

@property (nonatomic, strong) NSArray *vehicleArray;
@property (strong, nonatomic, readonly) NSArray *payChannelArray;

@property (strong, nonatomic, readonly) NSString *accountId;
//@property (strong, nonatomic, readonly) NSString *currentVin;
@property (strong, nonatomic, readonly) NSString *currentMakeModel;
@property (strong, nonatomic, readonly) NSString *migSessionKey;
@property (strong, nonatomic, readonly) NSString *idpid;

@property (nonatomic, strong) PackageInfos *selectPackageInfo;

@property (nonatomic, strong) NSString *selectedPackageId;
@property (nonatomic, strong) NSString *selectedPackageDiscountAmount;

@property (nonatomic, strong) NSIndexPath *selectedIndex;

@property (strong, nonatomic, readonly) NSString *orderId;

@property (strong, nonatomic, readonly) NSString *invoiceId;
@property (nonatomic, strong) NSString *invoiceTitle;
@property (nonatomic, strong) NSString *invoiceReceipt;
@property (nonatomic, strong) NSString *invoiceAddress;
@property (nonatomic, strong) NSString *zipCode;
@property (nonatomic, strong) NSString *invoiceMobile;

@property (nonatomic, strong) NSDictionary *createOrderResDic;

@property (nonatomic, strong) PackageListResponse *packageListResponse;
@property (nonatomic, strong) NNCreateOrderResponse *createOrderResponse;
@property (nonatomic, strong) NNGetOrderHistoryResponse *getOrderHistoryResponse;
@property (nonatomic, strong) NNQueryOrderStatusResponse *queryOrderStatusResponse;


// PPC
@property (nonatomic, strong) NSString *ppcCardNo;
@property (nonatomic, strong) NSString *ppcCardPasswd;
@property (nonatomic, strong) NSString *ppcPhone;
@property (nonatomic, strong) NNVehicle *ppcVehicle;

@property (nonatomic, strong) NNExtendedSubscriber *getAccountInfoResponse;
@property (nonatomic, strong) NNActivatePPCResponse *validateResponse;
@property (nonatomic, strong) NNActivatePPCResponse *activatePPCResponse;
@property (nonatomic, strong) NNGetActivateHistoryResponse *getActivateHistoryResponse;


// Wap pay
@property (nonatomic, strong) NNGetWapPayUrlResponse *getWapPayUrlResponse;

@property (nonatomic, assign) PurchaseType purchaseType;
+ (PurchaseModel*)sharedInstance;
+ (void)purgeSharedInstance;

+ (UserType)getUserType;



@property (nonatomic ,strong) NNPreferDealerDataResponse *preferDealerResponse;



@end
