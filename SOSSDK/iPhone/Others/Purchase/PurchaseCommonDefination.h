//
//  PurchaseCommonDefination.h
//  Onstar
//
//  Created by Joshua on 6/3/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#ifndef Onstar_PurchaseCommonDefination_h
#define Onstar_PurchaseCommonDefination_h


typedef enum {
    PayChannelVoid
} PayChannel;

typedef enum {
    SelectionTypeVechicle           = 0,
    SelectionTypePayChannel,
} SelectionType;

typedef enum {
    RequestGetPackageListByVin      = 0,
    RequestCreateOrder,
    RequestSaveInvoice,
    RequestQueryOrderStatusById,
    RequestGetOrderHistory,
    
    // PPC related
    RequestGetAccountByVin          = 100,
    RequestValidateCardById,
    RequestActivateCardById,
    RequestGetActivateHistory,
    RequestGetActivatedetail,
    
    // Wap pay
    RequestGetWapPayURL,
} PurchaseRequestType;

typedef enum {
    ResponseGetPackageListByVin      = 0,
    ResponseCreateOrder,
    ResponseSaveInvoice,
    ResponseQueryOrderById,
    ResponseGetOrderHistory,
    ResponseGetOrderDetailById,
} PurchaseResponseType;

typedef enum {
    ///车主
    UserTypeSubScriber              = 0,
    ///访客
    UserTypeVisitor,
    ///未登录
    UserTypeAnonymous,
} UserType;


typedef enum {
    Pending                         = 1,
    Paid                            = 2,
    Finished                        = 3,
} OrderStatus;

typedef enum {
    ActivatePPCForMyself            = 0,
    ActivatePPCForOthers,
} PPCActivateType;
#endif
